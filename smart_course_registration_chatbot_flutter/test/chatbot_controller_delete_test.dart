import 'package:flutter_test/flutter_test.dart';
import 'package:smart_course_registration_chatbot_flutter/features/chat/data/chatbot_repository_impl.dart';
import 'package:smart_course_registration_chatbot_flutter/features/chat/data/fake_chatbot_data_source.dart';
import 'package:smart_course_registration_chatbot_flutter/features/chat/presentation/chatbot_controller.dart';
import 'package:smart_course_registration_chatbot_flutter/features/chat/presentation/chatbot_state.dart';

void main() {
  group('ChatbotController delete conversation', () {
    test('deleting a non-active conversation keeps the active one', () async {
      final repository = ChatbotRepositoryImpl(
        dataSource: FakeChatbotDataSource(),
      );
      final first = await repository.sendMessage(message: 'Hội thoại 1');
      final second = await repository.sendMessage(message: 'Hội thoại 2');
      final controller = ChatbotController(repository: repository);
      addTearDown(controller.dispose);
      await controller.initialize();
      await controller.selectConversation(first.conversation.id);

      await controller.deleteConversation(second.conversation.id);

      expect(controller.state.activeConversationId, first.conversation.id);
      expect(controller.state.conversations, hasLength(1));
      expect(controller.state.conversations.single.id, first.conversation.id);
      expect(controller.state.deleteError, isNull);
    });

    test('deleting the active conversation resets to a new draft', () async {
      final repository = ChatbotRepositoryImpl(
        dataSource: FakeChatbotDataSource(),
      );
      final first = await repository.sendMessage(message: 'Hội thoại cần xóa');
      final controller = ChatbotController(repository: repository);
      addTearDown(controller.dispose);
      await controller.initialize();
      await controller.selectConversation(first.conversation.id);

      await controller.deleteConversation(first.conversation.id);

      expect(controller.state.activeConversationId, isNull);
      expect(controller.state.messages, isEmpty);
      expect(controller.state.messagesStatus, ChatbotRequestStatus.loaded);
      expect(controller.state.conversations, isEmpty);
      expect(controller.state.totalConversations, 0);
      expect(controller.state.deletingConversationIds, isEmpty);
    });
  });
}
