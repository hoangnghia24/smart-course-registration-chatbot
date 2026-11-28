import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_course_registration_chatbot_flutter/features/chat/chatbot_repository_scope.dart';
import 'package:smart_course_registration_chatbot_flutter/features/chat/data/chatbot_repository_impl.dart';
import 'package:smart_course_registration_chatbot_flutter/features/chat/data/fake_chatbot_data_source.dart';
import 'package:smart_course_registration_chatbot_flutter/features/chat/data/chatbot_repository.dart';

void main() {
  testWidgets('maybeOf returns the repository from the nearest scope',
      (tester) async {
    final repository = ChatbotRepositoryImpl(
      dataSource: FakeChatbotDataSource(),
    );
    ChatbotRepository? found;

    await tester.pumpWidget(
      ChatbotRepositoryScope(
        repository: repository,
        child: Builder(
          builder: (context) {
            found = ChatbotRepositoryScope.maybeOf(context);
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(found, same(repository));
  });

  testWidgets('maybeOf returns null when no scope exists', (tester) async {
    ChatbotRepository? found;

    await tester.pumpWidget(
      Builder(
        builder: (context) {
          found = ChatbotRepositoryScope.maybeOf(context);
          return const SizedBox.shrink();
        },
      ),
    );

    expect(found, isNull);
  });

  testWidgets('of returns the repository from the scope', (tester) async {
    final repository = ChatbotRepositoryImpl(
      dataSource: FakeChatbotDataSource(),
    );
    ChatbotRepository? found;

    await tester.pumpWidget(
      ChatbotRepositoryScope(
        repository: repository,
        child: Builder(
          builder: (context) {
            found = ChatbotRepositoryScope.of(context);
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(found, same(repository));
  });
}
