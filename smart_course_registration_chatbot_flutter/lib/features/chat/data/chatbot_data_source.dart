import '../domain/chatbot_response.dart';

/// Transport boundary for chatbot data.
///
/// Implementations may use an in-memory fake or a remote Serverpod client.
/// The data source returns domain models so the repository/UI contract stays
/// stable when the Backend API is introduced.
abstract interface class ChatbotDataSource {
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
