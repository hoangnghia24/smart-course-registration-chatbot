enum ChatbotFailureCode {
  unauthenticated,
  forbidden,
  validationError,
  conversationNotFound,
  rateLimited,
  aiUnavailable,
  aiTimeout,
  contextUnavailable,
  networkUnavailable,
  internalError,
  unknown,
}

class ChatbotRepositoryException implements Exception {
  const ChatbotRepositoryException({
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
  String toString() => 'ChatbotRepositoryException($code): $message';
}
