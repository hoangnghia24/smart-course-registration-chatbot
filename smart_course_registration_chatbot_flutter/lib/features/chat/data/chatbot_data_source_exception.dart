import '../domain/chatbot_repository_exception.dart';

/// Error raised by a chatbot data-source implementation before it is mapped
/// to the repository-facing exception.
class ChatbotDataSourceException implements Exception {
  const ChatbotDataSourceException({
    required this.code,
    required this.message,
    this.isRetryable = false,
    this.cause,
  });

  final ChatbotFailureCode code;
  final String message;
  final bool isRetryable;
  final Object? cause;

  @override
  String toString() => 'ChatbotDataSourceException($code): $message';
}
