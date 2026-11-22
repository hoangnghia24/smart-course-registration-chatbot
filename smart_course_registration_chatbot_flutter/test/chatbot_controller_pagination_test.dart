import 'package:flutter_test/flutter_test.dart';
import 'package:smart_course_registration_chatbot_flutter/features/chat/data/chatbot_repository_impl.dart';
import 'package:smart_course_registration_chatbot_flutter/features/chat/data/fake_chatbot_data_source.dart';
import 'package:smart_course_registration_chatbot_flutter/features/chat/presentation/chatbot_controller.dart';

void main() {
  test('loads newest messages first, then prepends older messages by cursor',
      () async {
    final repository = ChatbotRepositoryImpl(
      dataSource: FakeChatbotDataSource(
        assistantResponder: (message) async => 'Trả lời: $message',
      ),
    );
    final first = await repository.sendMessage(message: 'Tin nhắn 1');
    await repository.sendMessage(
      message: 'Tin nhắn 2',
      conversationId: first.conversation.id,
    );
    await repository.sendMessage(
      message: 'Tin nhắn 3',
      conversationId: first.conversation.id,
    );

    final controller = ChatbotController(
      repository: repository,
      messagePageSize: 2,
    );
    addTearDown(controller.dispose);

    await controller.selectConversation(first.conversation.id);
    expect(controller.state.messages, hasLength(2));
    expect(controller.state.hasMoreMessages, isTrue);
    expect(controller.state.canLoadOlderMessages, isTrue);

    await controller.loadOlderMessages();
    expect(controller.state.messages, hasLength(4));
    expect(controller.state.messages.first.content, 'Tin nhắn 2');
    expect(controller.state.hasMoreMessages, isTrue);

    await controller.loadOlderMessages();
    expect(controller.state.messages, hasLength(6));
    expect(controller.state.messages.first.content, 'Tin nhắn 1');
    expect(controller.state.hasMoreMessages, isFalse);
    expect(controller.state.canLoadOlderMessages, isFalse);

    final ids = controller.state.messages.map((message) => message.id).toList();
    expect(ids.toSet(), hasLength(6));
  });
}
