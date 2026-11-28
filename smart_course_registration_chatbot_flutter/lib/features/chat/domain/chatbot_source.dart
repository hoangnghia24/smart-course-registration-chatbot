enum ChatbotSourceType { courseCatalog, curriculum, academicProgress, regulation, other }

class ChatbotSource {
  const ChatbotSource({
    required this.id,
    required this.title,
    required this.sourceType,
    this.reference,
    this.excerpt,
  });

  final String id;
  final String title;
  final ChatbotSourceType sourceType;
  final String? reference;
  final String? excerpt;
}
