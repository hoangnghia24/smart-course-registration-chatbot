import 'package:flutter/widgets.dart';

import 'data/chatbot_repository.dart';

/// Provides one ChatbotRepository instance to the chatbot feature subtree.
class ChatbotRepositoryScope extends InheritedWidget {
  const ChatbotRepositoryScope({
    super.key,
    required this.repository,
    required super.child,
  });

  final ChatbotRepository repository;

  static ChatbotRepository? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<ChatbotRepositoryScope>()
        ?.repository;
  }

  static ChatbotRepository of(BuildContext context) {
    final repository = maybeOf(context);
    if (repository == null) {
      throw FlutterError(
        'ChatbotRepositoryScope.of() called with a context that does not '
        'contain a ChatbotRepositoryScope.',
      );
    }
    return repository;
  }

  @override
  bool updateShouldNotify(ChatbotRepositoryScope oldWidget) {
    return repository != oldWidget.repository;
  }
}
