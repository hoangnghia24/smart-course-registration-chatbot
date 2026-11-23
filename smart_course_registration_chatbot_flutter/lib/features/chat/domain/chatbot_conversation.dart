class ChatbotConversation {
  const ChatbotConversation({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    required this.messageCount,
    this.lastMessagePreview,
  });

  final String id;
  final String title;
  final String? lastMessagePreview;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int messageCount;
}
