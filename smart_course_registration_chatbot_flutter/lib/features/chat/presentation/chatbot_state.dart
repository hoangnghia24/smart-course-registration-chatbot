import '../domain/chatbot_conversation.dart';
import '../domain/chatbot_message.dart';
import '../domain/chatbot_repository_exception.dart';

/// Trạng thái tải dữ liệu dùng chung cho danh sách hội thoại và lịch sử chat.
enum ChatbotRequestStatus { idle, loading, loaded, error }

/// Snapshot bất biến của toàn bộ trạng thái nghiệp vụ FE-08.
///
/// Trạng thái danh sách hội thoại, lịch sử tin nhắn và gửi tin nhắn được tách
/// riêng để một thao tác tải không khóa hoặc ghi đè thao tác khác.
class ChatbotState {
  ChatbotState({
    List<ChatbotConversation> conversations = const [],
    this.conversationPage = 1,
    this.totalConversations = 0,
    this.hasMoreConversations = false,
    this.conversationsStatus = ChatbotRequestStatus.idle,
    this.isLoadingMoreConversations = false,
    this.conversationsError,
    this.activeConversationId,
    List<ChatbotMessage> messages = const [],
    this.messagesStatus = ChatbotRequestStatus.idle,
    this.nextMessagesCursor,
    this.hasMoreMessages = false,
    this.isLoadingOlderMessages = false,
    this.messagesError,
    this.olderMessagesError,
    this.isSending = false,
    this.sendError,
    this.failedMessage,
    Set<String> deletingConversationIds = const {},
    this.deleteError,
    this.isInitialized = false,
  })  : conversations = List<ChatbotConversation>.unmodifiable(conversations),
        messages = List<ChatbotMessage>.unmodifiable(messages),
        deletingConversationIds = Set<String>.unmodifiable(
          deletingConversationIds,
        );

  static const Object _unset = Object();

  final List<ChatbotConversation> conversations;
  final int conversationPage;
  final int totalConversations;
  final bool hasMoreConversations;
  final ChatbotRequestStatus conversationsStatus;
  final bool isLoadingMoreConversations;
  final ChatbotRepositoryException? conversationsError;

  final String? activeConversationId;
  final List<ChatbotMessage> messages;
  final ChatbotRequestStatus messagesStatus;
  final String? nextMessagesCursor;
  final bool hasMoreMessages;
  final bool isLoadingOlderMessages;
  final ChatbotRepositoryException? messagesError;
  final ChatbotRepositoryException? olderMessagesError;

  /// Chỉ phản ánh trạng thái gửi của hội thoại đang mở.
  final bool isSending;
  final ChatbotRepositoryException? sendError;
  final String? failedMessage;

  final Set<String> deletingConversationIds;
  final ChatbotRepositoryException? deleteError;
  final bool isInitialized;

  bool get hasActiveConversation => activeConversationId != null;

  bool get isConversationListEmpty =>
      conversationsStatus == ChatbotRequestStatus.loaded &&
      conversations.isEmpty;

  bool get isMessageHistoryEmpty =>
      messagesStatus == ChatbotRequestStatus.loaded && messages.isEmpty;

  bool get canLoadMoreConversations =>
      hasMoreConversations &&
      conversationsStatus == ChatbotRequestStatus.loaded &&
      !isLoadingMoreConversations;

  bool get canLoadOlderMessages =>
      activeConversationId != null &&
      hasMoreMessages &&
      nextMessagesCursor != null &&
      !isLoadingOlderMessages;

  ChatbotState copyWith({
    List<ChatbotConversation>? conversations,
    int? conversationPage,
    int? totalConversations,
    bool? hasMoreConversations,
    ChatbotRequestStatus? conversationsStatus,
    bool? isLoadingMoreConversations,
    Object? conversationsError = _unset,
    Object? activeConversationId = _unset,
    List<ChatbotMessage>? messages,
    ChatbotRequestStatus? messagesStatus,
    Object? nextMessagesCursor = _unset,
    bool? hasMoreMessages,
    bool? isLoadingOlderMessages,
    Object? messagesError = _unset,
    Object? olderMessagesError = _unset,
    bool? isSending,
    Object? sendError = _unset,
    Object? failedMessage = _unset,
    Set<String>? deletingConversationIds,
    Object? deleteError = _unset,
    bool? isInitialized,
  }) {
    return ChatbotState(
      conversations: conversations ?? this.conversations,
      conversationPage: conversationPage ?? this.conversationPage,
      totalConversations: totalConversations ?? this.totalConversations,
      hasMoreConversations:
          hasMoreConversations ?? this.hasMoreConversations,
      conversationsStatus:
          conversationsStatus ?? this.conversationsStatus,
      isLoadingMoreConversations:
          isLoadingMoreConversations ?? this.isLoadingMoreConversations,
      conversationsError: identical(conversationsError, _unset)
          ? this.conversationsError
          : conversationsError as ChatbotRepositoryException?,
      activeConversationId: identical(activeConversationId, _unset)
          ? this.activeConversationId
          : activeConversationId as String?,
      messages: messages ?? this.messages,
      messagesStatus: messagesStatus ?? this.messagesStatus,
      nextMessagesCursor: identical(nextMessagesCursor, _unset)
          ? this.nextMessagesCursor
          : nextMessagesCursor as String?,
      hasMoreMessages: hasMoreMessages ?? this.hasMoreMessages,
      isLoadingOlderMessages:
          isLoadingOlderMessages ?? this.isLoadingOlderMessages,
      messagesError: identical(messagesError, _unset)
          ? this.messagesError
          : messagesError as ChatbotRepositoryException?,
      olderMessagesError: identical(olderMessagesError, _unset)
          ? this.olderMessagesError
          : olderMessagesError as ChatbotRepositoryException?,
      isSending: isSending ?? this.isSending,
      sendError: identical(sendError, _unset)
          ? this.sendError
          : sendError as ChatbotRepositoryException?,
      failedMessage: identical(failedMessage, _unset)
          ? this.failedMessage
          : failedMessage as String?,
      deletingConversationIds:
          deletingConversationIds ?? this.deletingConversationIds,
      deleteError: identical(deleteError, _unset)
          ? this.deleteError
          : deleteError as ChatbotRepositoryException?,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }
}
