import 'package:flutter/foundation.dart';

import '../data/chatbot_repository.dart';
import '../domain/chatbot_conversation.dart';
import '../domain/chatbot_message.dart';
import '../domain/chatbot_repository_exception.dart';
import 'chatbot_state.dart';

/// Điều phối nghiệp vụ Chatbot và phát trạng thái cho giao diện.
///
/// Controller chỉ phụ thuộc Repository, không gọi Serverpod Client trực tiếp.
/// Có thể dùng FakeChatbotDataSource trong giai đoạn Backend chưa hoàn thiện.
class ChatbotController extends ChangeNotifier {
  ChatbotController({
    required ChatbotRepository repository,
    String? initialConversationId,
    this.conversationPageSize = 20,
    this.messagePageSize = 30,
  })  : _repository = repository,
        _initialConversationId = initialConversationId {
    if (conversationPageSize < 1) {
      throw ArgumentError.value(
        conversationPageSize,
        'conversationPageSize',
        'Phải lớn hơn 0.',
      );
    }
    if (messagePageSize < 1) {
      throw ArgumentError.value(
        messagePageSize,
        'messagePageSize',
        'Phải lớn hơn 0.',
      );
    }
  }

  final ChatbotRepository _repository;
  final String? _initialConversationId;

  final int conversationPageSize;
  final int messagePageSize;

  ChatbotState _state = ChatbotState();
  ChatbotState get state => _state;

  bool _disposed = false;
  Future<void>? _initializationFuture;

  int _conversationGeneration = 0;
  int _messageGeneration = 0;
  int _olderMessagesGeneration = 0;
  int _draftSequence = 0;
  int _clientRequestSequence = 0;

  String _activeDraftKey = 'draft-0';
  final Set<String> _sendingKeys = <String>{};
  final Map<String, _FailedChatbotSend> _failedSends =
      <String, _FailedChatbotSend>{};
  final Set<String> _deletingIds = <String>{};
  final Set<String> _deletedConversationIds = <String>{};

  String get _activeContextKey =>
      _state.activeConversationId ?? _activeDraftKey;

  void _emit(ChatbotState next) {
    if (_disposed) return;
    _state = next;
    notifyListeners();
  }

  /// Tải danh sách hội thoại và mở hội thoại ban đầu nếu được truyền vào.
  /// Gọi nhiều lần sẽ dùng chung Future khởi tạo, tránh tải trùng.
  Future<void> initialize() {
    return _initializationFuture ??= _initialize();
  }

  Future<void> _initialize() async {
    await loadConversations(refresh: true);
    if (_disposed) return;

    final initialId = _initialConversationId?.trim();
    if (initialId != null && initialId.isNotEmpty) {
      await selectConversation(initialId);
    } else {
      _emit(
        _state.copyWith(
          messagesStatus: ChatbotRequestStatus.loaded,
          isInitialized: true,
        ),
      );
    }

    if (!_disposed && !_state.isInitialized) {
      _emit(_state.copyWith(isInitialized: true));
    }
  }

  /// Tải hoặc làm mới trang đầu tiên của danh sách hội thoại.
  Future<void> loadConversations({bool refresh = false}) async {
    if (_state.conversationsStatus == ChatbotRequestStatus.loading &&
        !refresh) {
      return;
    }

    final generation = ++_conversationGeneration;
    _emit(
      _state.copyWith(
        conversationsStatus: ChatbotRequestStatus.loading,
        isLoadingMoreConversations: false,
        conversationsError: null,
      ),
    );

    try {
      final page = await _repository.getConversations(
        page: 1,
        pageSize: conversationPageSize,
      );
      if (!_isCurrentConversationRequest(generation)) return;

      final removedCount = page.conversations
          .where((item) => _deletedConversationIds.contains(item.id))
          .length;
      final conversations = page.conversations
          .where((item) => !_deletedConversationIds.contains(item.id))
          .toList(growable: false);
      _emit(
        _state.copyWith(
          conversations: conversations,
          conversationPage: page.page,
          totalConversations:
              (page.total - removedCount).clamp(0, 1 << 30).toInt(),
          hasMoreConversations: page.hasMore,
          conversationsStatus: ChatbotRequestStatus.loaded,
          isLoadingMoreConversations: false,
          conversationsError: null,
        ),
      );
    } catch (error) {
      if (!_isCurrentConversationRequest(generation)) return;
      _emit(
        _state.copyWith(
          conversationsStatus: ChatbotRequestStatus.error,
          isLoadingMoreConversations: false,
          conversationsError: _asRepositoryException(
            error,
            fallbackMessage: 'Không thể tải danh sách hội thoại.',
          ),
        ),
      );
    }
  }

  /// Tải trang hội thoại tiếp theo nếu còn dữ liệu.
  Future<void> loadMoreConversations() async {
    if (!_state.canLoadMoreConversations) return;

    final generation = ++_conversationGeneration;
    final nextPage = _state.conversationPage + 1;
    _emit(
      _state.copyWith(
        isLoadingMoreConversations: true,
        conversationsError: null,
      ),
    );

    try {
      final page = await _repository.getConversations(
        page: nextPage,
        pageSize: conversationPageSize,
      );
      if (!_isCurrentConversationRequest(generation)) return;

      final additions = page.conversations
          .where((item) => !_deletedConversationIds.contains(item.id))
          .toList(growable: false);
      _emit(
        _state.copyWith(
          conversations: _mergeConversations(_state.conversations, additions),
          conversationPage: page.page,
          totalConversations: page.total,
          hasMoreConversations: page.hasMore,
          conversationsStatus: ChatbotRequestStatus.loaded,
          isLoadingMoreConversations: false,
          conversationsError: null,
        ),
      );
    } catch (error) {
      if (!_isCurrentConversationRequest(generation)) return;
      _emit(
        _state.copyWith(
          isLoadingMoreConversations: false,
          conversationsError: _asRepositoryException(
            error,
            fallbackMessage: 'Không thể tải thêm hội thoại.',
          ),
        ),
      );
    }
  }

  Future<void> retryConversations() => loadConversations(refresh: true);

  /// Tạo một vùng hội thoại mới ở phía giao diện.
  /// Backend chỉ tạo conversation thật khi gửi tin nhắn đầu tiên.
  void createNewConversation() {
    _draftSequence += 1;
    _activeDraftKey = 'draft-$_draftSequence';
    _messageGeneration += 1;
    _olderMessagesGeneration += 1;

    final failed = _failedSends[_activeDraftKey];
    _emit(
      _state.copyWith(
        activeConversationId: null,
        messages: const [],
        messagesStatus: ChatbotRequestStatus.loaded,
        nextMessagesCursor: null,
        hasMoreMessages: false,
        isLoadingOlderMessages: false,
        messagesError: null,
        olderMessagesError: null,
        isSending: _sendingKeys.contains(_activeDraftKey),
        sendError: failed?.error,
        failedMessage: failed?.message,
      ),
    );
  }

  /// Chọn một hội thoại và tải lịch sử mới nhất.
  Future<void> selectConversation(
    String conversationId, {
    bool forceReload = false,
  }) async {
    final normalizedId = conversationId.trim();
    if (normalizedId.isEmpty) {
      _emit(
        _state.copyWith(
          messagesStatus: ChatbotRequestStatus.error,
          messagesError: const ChatbotRepositoryException(
            code: ChatbotFailureCode.validationError,
            message: 'Mã hội thoại không hợp lệ.',
          ),
        ),
      );
      return;
    }

    if (!forceReload &&
        _state.activeConversationId == normalizedId &&
        _state.messagesStatus == ChatbotRequestStatus.loaded) {
      return;
    }

    final generation = ++_messageGeneration;
    _olderMessagesGeneration += 1;
    final failed = _failedSends[normalizedId];
    final retainedMessages =
        forceReload && _state.activeConversationId == normalizedId
            ? _state.messages
            : const <ChatbotMessage>[];
    _emit(
      _state.copyWith(
        activeConversationId: normalizedId,
        messages: retainedMessages,
        messagesStatus: ChatbotRequestStatus.loading,
        nextMessagesCursor: null,
        hasMoreMessages: false,
        isLoadingOlderMessages: false,
        messagesError: null,
        olderMessagesError: null,
        isSending: _sendingKeys.contains(normalizedId),
        sendError: failed?.error,
        failedMessage: failed?.message,
      ),
    );

    try {
      final page = await _repository.getMessages(
        conversationId: normalizedId,
        limit: messagePageSize,
      );
      if (!_isCurrentMessageRequest(generation, normalizedId)) return;
      if (page.conversationId != normalizedId) {
        throw const ChatbotRepositoryException(
          code: ChatbotFailureCode.internalError,
          message: 'Dữ liệu lịch sử trả về không khớp hội thoại đang mở.',
        );
      }

      _emit(
        _state.copyWith(
          messages: page.messages,
          messagesStatus: ChatbotRequestStatus.loaded,
          nextMessagesCursor: page.nextCursor,
          hasMoreMessages: page.hasMore,
          messagesError: null,
          olderMessagesError: null,
        ),
      );
    } catch (error) {
      if (!_isCurrentMessageRequest(generation, normalizedId)) return;
      _emit(
        _state.copyWith(
          messagesStatus: ChatbotRequestStatus.error,
          messagesError: _asRepositoryException(
            error,
            fallbackMessage: 'Không thể tải lịch sử hội thoại.',
          ),
        ),
      );
    }
  }

  /// Gửi tin nhắn trong hội thoại hiện tại.
  /// Một hội thoại không thể gửi hai request đồng thời; các hội thoại khác
  /// vẫn có thể tiếp tục hoạt động độc lập.
  Future<void> sendMessage(String message) async {
    final normalizedMessage = message.trim();
    final contextKey = _activeContextKey;
    final conversationId = _state.activeConversationId;

    if (_sendingKeys.contains(contextKey)) return;
    if (conversationId != null &&
        _state.messagesStatus == ChatbotRequestStatus.loading) {
      return;
    }

    if (normalizedMessage.isEmpty) {
      _emit(
        _state.copyWith(
          sendError: const ChatbotRepositoryException(
            code: ChatbotFailureCode.validationError,
            message: 'Nội dung tin nhắn không được để trống.',
          ),
          failedMessage: null,
        ),
      );
      return;
    }
    if (normalizedMessage.length > 2000) {
      _emit(
        _state.copyWith(
          sendError: const ChatbotRepositoryException(
            code: ChatbotFailureCode.validationError,
            message: 'Nội dung tin nhắn không được vượt quá 2000 ký tự.',
          ),
          failedMessage: null,
        ),
      );
      return;
    }

    _sendingKeys.add(contextKey);
    _failedSends.remove(contextKey);
    _emitForActiveContext(
      contextKey,
      _state.copyWith(
        isSending: true,
        sendError: null,
        failedMessage: null,
      ),
    );

    final clientRequestId = 'fe08-request-${++_clientRequestSequence}';
    try {
      final result = await _repository.sendMessage(
        message: normalizedMessage,
        conversationId: conversationId,
        clientRequestId: clientRequestId,
      );
      if (_disposed) return;

      if (!_deletedConversationIds.contains(result.conversation.id)) {
        _conversationGeneration += 1;
        var next = _state.copyWith(
          conversations: _upsertConversation(
            _state.conversations,
            result.conversation,
          ),
          totalConversations: _containsConversation(
            _state.conversations,
            result.conversation.id,
          )
              ? _state.totalConversations
              : _state.totalConversations + 1,
          conversationsStatus: ChatbotRequestStatus.loaded,
          isLoadingMoreConversations: false,
          conversationsError: null,
        );

        if (_activeContextKey == contextKey) {
          if (_state.messagesStatus == ChatbotRequestStatus.loading) {
            _messageGeneration += 1;
            _olderMessagesGeneration += 1;
          }
          next = next.copyWith(
            activeConversationId: result.conversation.id,
            messages: _mergeMessages(
              _state.messages,
              [result.userMessage, result.assistantMessage],
            ),
            messagesStatus: ChatbotRequestStatus.loaded,
            isLoadingOlderMessages: false,
            messagesError: null,
            olderMessagesError: null,
            sendError: null,
            failedMessage: null,
            isSending: _sendingKeys.contains(result.conversation.id),
          );
        }
        _emit(next);
      }
    } catch (error) {
      if (_disposed) return;
      final exception = _asRepositoryException(
        error,
        fallbackMessage: 'Không thể gửi tin nhắn chatbot.',
      );
      _failedSends[contextKey] = _FailedChatbotSend(
        message: normalizedMessage,
        error: exception,
      );
      _emitForActiveContext(
        contextKey,
        _state.copyWith(
          sendError: exception,
          failedMessage: normalizedMessage,
        ),
      );
    } finally {
      _sendingKeys.remove(contextKey);
      if (!_disposed) {
        _emit(
          _state.copyWith(
            isSending: _sendingKeys.contains(_activeContextKey),
          ),
        );
      }
    }
  }

  /// Gửi lại tin nhắn thất bại gần nhất của hội thoại đang mở.
  Future<void> retrySendMessage() async {
    final failed = _failedSends[_activeContextKey];
    if (failed == null || !failed.error.isRetryable) return;
    await sendMessage(failed.message);
  }

  /// Tải thêm các tin nhắn cũ hơn theo cursor, chèn vào đầu lịch sử.
  Future<void> loadOlderMessages() async {
    final conversationId = _state.activeConversationId;
    final cursor = _state.nextMessagesCursor;
    if (conversationId == null ||
        cursor == null ||
        !_state.hasMoreMessages ||
        _state.isLoadingOlderMessages) {
      return;
    }

    final messageGeneration = _messageGeneration;
    final generation = ++_olderMessagesGeneration;
    _emit(
      _state.copyWith(
        isLoadingOlderMessages: true,
        olderMessagesError: null,
      ),
    );

    try {
      final page = await _repository.getMessages(
        conversationId: conversationId,
        cursor: cursor,
        limit: messagePageSize,
      );
      if (!_isCurrentOlderRequest(
        generation,
        messageGeneration,
        conversationId,
      )) {
        return;
      }
      if (page.conversationId != conversationId) {
        throw const ChatbotRepositoryException(
          code: ChatbotFailureCode.internalError,
          message: 'Dữ liệu tin nhắn cũ không khớp hội thoại đang mở.',
        );
      }

      _emit(
        _state.copyWith(
          messages: _mergeMessages(page.messages, _state.messages),
          nextMessagesCursor: page.nextCursor,
          hasMoreMessages: page.hasMore,
          isLoadingOlderMessages: false,
          olderMessagesError: null,
        ),
      );
    } catch (error) {
      if (!_isCurrentOlderRequest(
        generation,
        messageGeneration,
        conversationId,
      )) {
        return;
      }
      _emit(
        _state.copyWith(
          isLoadingOlderMessages: false,
          olderMessagesError: _asRepositoryException(
            error,
            fallbackMessage: 'Không thể tải thêm tin nhắn cũ.',
          ),
        ),
      );
    }
  }

  Future<void> retryOlderMessages() => loadOlderMessages();

  Future<void> retryMessages() async {
    final conversationId = _state.activeConversationId;
    if (conversationId == null) return;
    await selectConversation(conversationId, forceReload: true);
  }

  /// Làm mới danh sách và lịch sử của hội thoại đang mở.
  Future<void> refresh() async {
    final activeId = _state.activeConversationId;
    await loadConversations(refresh: true);
    if (_disposed || activeId == null) return;
    if (_state.activeConversationId == activeId) {
      await selectConversation(activeId, forceReload: true);
    }
  }

  /// Xóa hội thoại. Nếu đang mở hội thoại đó, chuyển về bản nháp mới.
  Future<void> deleteConversation(String conversationId) async {
    final normalizedId = conversationId.trim();
    if (normalizedId.isEmpty || _deletingIds.contains(normalizedId)) return;

    _deletingIds.add(normalizedId);
    _deletedConversationIds.add(normalizedId);
    _emit(
      _state.copyWith(
        deletingConversationIds: _deletingIds,
        deleteError: null,
      ),
    );

    try {
      await _repository.deleteConversation(conversationId: normalizedId);
      if (_disposed) return;

      _conversationGeneration += 1;
      final remaining = _state.conversations
          .where((item) => item.id != normalizedId)
          .toList(growable: false);
      final wasInLoadedList = _containsConversation(
        _state.conversations,
        normalizedId,
      );
      final nextTotal = wasInLoadedList
          ? (_state.totalConversations - 1).clamp(0, 1 << 30).toInt()
          : _state.totalConversations;
      _emit(
        _state.copyWith(
          conversations: remaining,
          totalConversations: nextTotal,
          conversationsStatus: ChatbotRequestStatus.loaded,
          isLoadingMoreConversations: false,
          hasMoreConversations: _state.hasMoreConversations,
          deleteError: null,
        ),
      );

      _failedSends.remove(normalizedId);
      if (_state.activeConversationId == normalizedId) {
        createNewConversation();
      }
    } catch (error) {
      if (_disposed) return;
      _deletedConversationIds.remove(normalizedId);
      _emit(
        _state.copyWith(
          deleteError: _asRepositoryException(
            error,
            fallbackMessage: 'Không thể xóa hội thoại.',
          ),
        ),
      );
      await loadConversations(refresh: true);
    } finally {
      _deletingIds.remove(normalizedId);
      if (!_disposed) {
        _emit(_state.copyWith(deletingConversationIds: _deletingIds));
      }
    }
  }

  bool _isCurrentConversationRequest(int generation) =>
      !_disposed && generation == _conversationGeneration;

  bool _isCurrentMessageRequest(int generation, String conversationId) =>
      !_disposed &&
      generation == _messageGeneration &&
      _state.activeConversationId == conversationId;

  bool _isCurrentOlderRequest(
    int generation,
    int messageGeneration,
    String conversationId,
  ) =>
      !_disposed &&
      generation == _olderMessagesGeneration &&
      messageGeneration == _messageGeneration &&
      _state.activeConversationId == conversationId;

  void _emitForActiveContext(String contextKey, ChatbotState next) {
    if (_activeContextKey == contextKey) _emit(next);
  }

  ChatbotRepositoryException _asRepositoryException(
    Object error, {
    required String fallbackMessage,
  }) {
    if (error is ChatbotRepositoryException) return error;
    return ChatbotRepositoryException(
      code: ChatbotFailureCode.unknown,
      message: fallbackMessage,
      cause: error,
    );
  }

  List<ChatbotConversation> _mergeConversations(
    List<ChatbotConversation> current,
    List<ChatbotConversation> additions,
  ) {
    final byId = <String, ChatbotConversation>{
      for (final item in current) item.id: item,
    };
    for (final item in additions) {
      if (!_deletedConversationIds.contains(item.id)) {
        byId[item.id] = item;
      }
    }
    final merged = byId.values.toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return merged;
  }

  List<ChatbotConversation> _upsertConversation(
    List<ChatbotConversation> current,
    ChatbotConversation conversation,
  ) =>
      _mergeConversations(current, [conversation]);

  bool _containsConversation(
    List<ChatbotConversation> conversations,
    String id,
  ) =>
      conversations.any((item) => item.id == id);

  List<ChatbotMessage> _mergeMessages(
    List<ChatbotMessage> first,
    List<ChatbotMessage> second,
  ) {
    final seen = <String>{};
    final merged = <ChatbotMessage>[];
    for (final message in [...first, ...second]) {
      if (seen.add(message.id)) merged.add(message);
    }
    return merged;
  }

  @override
  void dispose() {
    _disposed = true;
    _conversationGeneration += 1;
    _messageGeneration += 1;
    _olderMessagesGeneration += 1;
    super.dispose();
  }
}

class _FailedChatbotSend {
  const _FailedChatbotSend({required this.message, required this.error});

  final String message;
  final ChatbotRepositoryException error;
}
