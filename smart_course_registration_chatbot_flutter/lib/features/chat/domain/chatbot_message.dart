import 'chatbot_related_course.dart';
import 'chatbot_source.dart';

enum ChatbotMessageRole { user, assistant }
enum ChatbotEvidenceStatus { supported, partial, none }

class ChatbotMessage {
  const ChatbotMessage({
    required this.id,
    required this.conversationId,
    required this.role,
    required this.content,
    required this.createdAt,
    this.evidenceStatus,
    this.sources = const [],
    this.relatedCourses = const [],
  });

  final String id;
  final String conversationId;
  final ChatbotMessageRole role;
  final String content;
  final DateTime createdAt;
  final ChatbotEvidenceStatus? evidenceStatus;
  final List<ChatbotSource> sources;
  final List<ChatbotRelatedCourse> relatedCourses;

  bool get isFromUser => role == ChatbotMessageRole.user;
  bool get isFromAssistant => role == ChatbotMessageRole.assistant;
}
