import '../domain/chatbot_response.dart';

abstract interface class ChatbotRepository {
  /// Null conversationId creates a new conversation.
  /// A non-null conversationId continues an existing conversation.
  Future<ChatbotSendMessageResult> sendMessage({
    required String message,
    String? conversationId,
    String? clientRequestId,
  });

  Future<ChatbotConversationPage> getConversations({
    int page = 1,
    int pageSize = 20,
  });

  Future<ChatbotMessagePage> getMessages({
    required String conversationId,
    String? cursor,
    int limit = 30,
  });

  Future<void> deleteConversation({
    required String conversationId,
  });
}
