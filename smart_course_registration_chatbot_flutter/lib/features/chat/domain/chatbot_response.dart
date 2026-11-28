import 'chatbot_conversation.dart';
import 'chatbot_message.dart';

class ChatbotSendMessageResult {
  const ChatbotSendMessageResult({
    required this.conversation,
    required this.userMessage,
    required this.assistantMessage,
  });

  final ChatbotConversation conversation;
  final ChatbotMessage userMessage;
  final ChatbotMessage assistantMessage;
}

class ChatbotConversationPage {
  const ChatbotConversationPage({
    required this.conversations,
    required this.page,
    required this.pageSize,
    required this.total,
    required this.hasMore,
  });

  final List<ChatbotConversation> conversations;
  final int page;
  final int pageSize;
  final int total;
  final bool hasMore;
}

class ChatbotMessagePage {
  const ChatbotMessagePage({
    required this.conversationId,
    required this.messages,
    required this.hasMore,
    this.nextCursor,
  });

  final String conversationId;
  final List<ChatbotMessage> messages;
  final String? nextCursor;
  final bool hasMore;
}
