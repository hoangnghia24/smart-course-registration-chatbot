import '../domain/chatbot_conversation.dart';
import '../domain/chatbot_message.dart';
import '../domain/chatbot_repository_exception.dart';
import '../domain/chatbot_response.dart';
import 'chatbot_data_source.dart';
import 'chatbot_data_source_exception.dart';

typedef FakeChatbotAssistantResponder = Future<String> Function(String message);

/// In-memory data source for development and automated tests.
///
/// This class is not a production Backend and its responses must not be
/// presented as real academic advice or persisted system history.
class FakeChatbotDataSource implements ChatbotDataSource {
  FakeChatbotDataSource({
    DateTime Function()? clock,
    String Function()? idGenerator,
    FakeChatbotAssistantResponder? assistantResponder,
  })  : _clock = clock ?? DateTime.now,
        _idGenerator = idGenerator,
        _assistantResponder = assistantResponder ?? _defaultAssistantResponse;

  final DateTime Function() _clock;
  final String Function()? _idGenerator;
  final FakeChatbotAssistantResponder _assistantResponder;
  final Map<String, _FakeConversationRecord> _records = <String, _FakeConversationRecord>{};

  int _generatedId = 0;

  static Future<String> _defaultAssistantResponse(String message) async {
    return 'Đây là phản hồi mô phỏng cho nội dung: "$message". '
        'Khi Backend được tích hợp, câu trả lời sẽ được cung cấp từ hệ thống tư vấn.';
  }

  String _nextId(String prefix) {
    final customId = _idGenerator?.call();
    if (customId != null && customId.isNotEmpty) {
      return customId;
    }
    _generatedId += 1;
    return '$prefix-$_generatedId';
  }

  ChatbotDataSourceException _notFound(String conversationId) {
    return ChatbotDataSourceException(
      code: ChatbotFailureCode.conversationNotFound,
      message: 'Không tìm thấy hội thoại "$conversationId" trong dữ liệu mô phỏng.',
    );
  }

  ChatbotDataSourceException _validation(String message) {
    return ChatbotDataSourceException(
      code: ChatbotFailureCode.validationError,
      message: message,
    );
  }

  @override
  Future<ChatbotSendMessageResult> sendMessage({
    required String message,
    String? conversationId,
    String? clientRequestId,
  }) async {
    final normalizedMessage = message.trim();
    if (normalizedMessage.isEmpty) {
      throw _validation('Nội dung tin nhắn không được để trống.');
    }

    // Generate the simulated response before mutating the in-memory history.
    final assistantContent = await _assistantResponder(normalizedMessage);
    final now = _clock();

    late final _FakeConversationRecord record;
    if (conversationId == null) {
      final newConversationId = _nextId('fake-conversation');
      final initialConversation = ChatbotConversation(
        id: newConversationId,
        title: _conversationTitle(normalizedMessage),
        createdAt: now,
        updatedAt: now,
        messageCount: 0,
      );
      record = _FakeConversationRecord(conversation: initialConversation);
      _records[newConversationId] = record;
    } else {
      final existingRecord = _records[conversationId];
      if (existingRecord == null) {
        throw _notFound(conversationId);
      }
      record = existingRecord;
    }

    final currentConversation = record.conversation;
    final userMessage = ChatbotMessage(
      id: _nextId('fake-message'),
      conversationId: currentConversation.id,
      role: ChatbotMessageRole.user,
      content: normalizedMessage,
      createdAt: now,
    );
    final assistantMessage = ChatbotMessage(
      id: _nextId('fake-message'),
      conversationId: currentConversation.id,
      role: ChatbotMessageRole.assistant,
      content: assistantContent,
      createdAt: now,
      evidenceStatus: ChatbotEvidenceStatus.none,
    );

    record.messages
      ..add(userMessage)
      ..add(assistantMessage);

    record.conversation = ChatbotConversation(
      id: currentConversation.id,
      title: currentConversation.title,
      createdAt: currentConversation.createdAt,
      updatedAt: now,
      messageCount: record.messages.length,
      lastMessagePreview: assistantMessage.content,
    );

    return ChatbotSendMessageResult(
      conversation: record.conversation,
      userMessage: userMessage,
      assistantMessage: assistantMessage,
    );
  }

  @override
  Future<ChatbotConversationPage> getConversations({
    int page = 1,
    int pageSize = 20,
  }) async {
    if (page < 1 || pageSize < 1) {
      throw _validation('Số trang và kích thước trang phải lớn hơn 0.');
    }

    final allConversations = _records.values
        .map((record) => record.conversation)
        .toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    final total = allConversations.length;
    final start = (page - 1) * pageSize;
    final end = (start + pageSize).clamp(0, total).toInt();
    final items = start >= total
        ? <ChatbotConversation>[]
        : allConversations.sublist(start, end);

    return ChatbotConversationPage(
      conversations: List<ChatbotConversation>.unmodifiable(items),
      page: page,
      pageSize: pageSize,
      total: total,
      hasMore: start + items.length < total,
    );
  }

  @override
  Future<ChatbotMessagePage> getMessages({
    required String conversationId,
    String? cursor,
    int limit = 30,
  }) async {
    if (conversationId.trim().isEmpty) {
      throw _validation('Mã hội thoại không được để trống.');
    }
    if (limit < 1) {
      throw _validation('Số lượng tin nhắn mỗi trang phải lớn hơn 0.');
    }

    final record = _records[conversationId];
    if (record == null) {
      throw _notFound(conversationId);
    }

    final messages = record.messages;
    final end = cursor == null ? messages.length : int.tryParse(cursor);
    if (end == null || end < 0 || end > messages.length) {
      throw _validation('Con trỏ lịch sử tin nhắn không hợp lệ.');
    }

    // The first request returns the newest messages. Subsequent cursors move
    // backwards through older messages.
    final start = (end - limit).clamp(0, end).toInt();
    final pageMessages = messages.sublist(start, end);
    final hasMore = start > 0;

    return ChatbotMessagePage(
      conversationId: conversationId,
      messages: List<ChatbotMessage>.unmodifiable(pageMessages),
      nextCursor: hasMore ? '$start' : null,
      hasMore: hasMore,
    );
  }

  @override
  Future<void> deleteConversation({
    required String conversationId,
  }) async {
    if (conversationId.trim().isEmpty) {
      throw _validation('Mã hội thoại không được để trống.');
    }
    if (_records.remove(conversationId) == null) {
      throw _notFound(conversationId);
    }
  }

  String _conversationTitle(String message) {
    const maxLength = 48;
    if (message.length <= maxLength) {
      return message;
    }
    return '${message.substring(0, maxLength - 3)}...';
  }
}

class _FakeConversationRecord {
  _FakeConversationRecord({required this.conversation});

  ChatbotConversation conversation;
  final List<ChatbotMessage> messages = <ChatbotMessage>[];
}
