import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:smart_course_registration_chatbot_flutter/features/chat/data/chatbot_repository_impl.dart';
import 'package:smart_course_registration_chatbot_flutter/features/chat/data/fake_chatbot_data_source.dart';
import 'package:smart_course_registration_chatbot_flutter/features/chat/domain/chatbot_repository_exception.dart';
import 'package:smart_course_registration_chatbot_flutter/features/chat/domain/chatbot_response.dart';
import 'package:smart_course_registration_chatbot_flutter/features/chat/presentation/chatbot_controller.dart';
import 'package:smart_course_registration_chatbot_flutter/features/chat/presentation/chatbot_state.dart';

import 'helpers/chatbot_test_support.dart';

void main() {
  group('ChatbotController', () {
    late ChatbotController controller;

    tearDown(() {
      controller.dispose();
    });

    test('initialize loads conversations and optional initial history', () async {
      final repository = ChatbotRepositoryImpl(
        dataSource: FakeChatbotDataSource(
          assistantResponder: (message) async => 'Đã nhận: $message',
        ),
      );
      final seeded = await repository.sendMessage(message: 'Hội thoại đã có');
      controller = ChatbotController(
        repository: repository,
        initialConversationId: seeded.conversation.id,
      );

      await controller.initialize();

      expect(controller.state.isInitialized, isTrue);
      expect(controller.state.conversationsStatus, ChatbotRequestStatus.loaded);
      expect(controller.state.conversations, hasLength(1));
      expect(controller.state.activeConversationId, seeded.conversation.id);
      expect(controller.state.messages, hasLength(2));
      expect(controller.state.messagesStatus, ChatbotRequestStatus.loaded);
    });

    test('createNewConversation clears active history without creating backend data',
        () async {
      final repository = ChatbotRepositoryImpl(
        dataSource: FakeChatbotDataSource(),
      );
      final seeded = await repository.sendMessage(message: 'Hội thoại cũ');
      controller = ChatbotController(repository: repository);
      await controller.selectConversation(seeded.conversation.id);

      controller.createNewConversation();

      expect(controller.state.activeConversationId, isNull);
      expect(controller.state.messages, isEmpty);
      expect(controller.state.messagesStatus, ChatbotRequestStatus.loaded);
      final page = await repository.getConversations();
      expect(page.total, 1, reason: 'Tạo mới chỉ reset trạng thái giao diện.');
    });

    test('loadMoreConversations appends the next page without duplicates',
        () async {
      final repository = ChatbotRepositoryImpl(
        dataSource: FakeChatbotDataSource(),
      );
      await repository.sendMessage(message: 'Hội thoại một');
      await repository.sendMessage(message: 'Hội thoại hai');
      await repository.sendMessage(message: 'Hội thoại ba');
      controller = ChatbotController(
        repository: repository,
        conversationPageSize: 2,
      );

      await controller.initialize();
      expect(controller.state.conversations, hasLength(2));
      expect(controller.state.canLoadMoreConversations, isTrue);

      await controller.loadMoreConversations();

      expect(controller.state.conversations, hasLength(3));
      expect(controller.state.hasMoreConversations, isFalse);
      expect(controller.state.conversations.map((item) => item.id).toSet(),
          hasLength(3));
    });

    test('sending in an existing conversation continues its history',
        () async {
      final repository = ChatbotRepositoryImpl(
        dataSource: FakeChatbotDataSource(
          assistantResponder: (message) async => 'Phản hồi: $message',
        ),
      );
      final seeded = await repository.sendMessage(message: 'Tin nhắn trước');
      controller = ChatbotController(repository: repository);
      await controller.selectConversation(seeded.conversation.id);

      await controller.sendMessage('Tin nhắn tiếp theo');

      expect(controller.state.activeConversationId, seeded.conversation.id);
      expect(controller.state.messages, hasLength(4));
      expect(controller.state.messages[2].content, 'Tin nhắn tiếp theo');
      expect(controller.state.messages.last.isFromAssistant, isTrue);
    });

    test('sending the first message creates and activates a conversation',
        () async {
      final repository = ChatbotRepositoryImpl(
        dataSource: FakeChatbotDataSource(
          assistantResponder: (message) async => 'Phản hồi: $message',
        ),
      );
      controller = ChatbotController(repository: repository);
      await controller.initialize();

      await controller.sendMessage('Tôi cần tư vấn học phần.');

      expect(controller.state.activeConversationId, isNotNull);
      expect(controller.state.messages, hasLength(2));
      expect(controller.state.messages.first.isFromUser, isTrue);
      expect(controller.state.messages.last.isFromAssistant, isTrue);
      expect(controller.state.conversations, hasLength(1));
      expect(controller.state.isSending, isFalse);
    });

    test('does not send a second message while the active conversation is sending',
        () async {
      final repository = TestChatbotRepository();
      final response = Completer<ChatbotSendMessageResult>();
      repository.onSendMessage = ({
        required message,
        conversationId,
        clientRequestId,
      }) => response.future;
      controller = ChatbotController(repository: repository);

      final firstSend = controller.sendMessage('Tin nhắn thứ nhất');
      await Future<void>.delayed(Duration.zero);
      await controller.sendMessage('Tin nhắn trùng');

      expect(repository.sendMessageCalls, 1);
      expect(controller.state.isSending, isTrue);

      response.complete(testSendResult('conversation-1'));
      await firstSend;
      expect(controller.state.messages, hasLength(2));
      expect(controller.state.isSending, isFalse);
    });

    test('retrySendMessage retries a retryable failure', () async {
      final repository = TestChatbotRepository();
      var attempts = 0;
      repository.onSendMessage = ({
        required message,
        conversationId,
        clientRequestId,
      }) async {
        attempts += 1;
        if (attempts == 1) {
          throw const ChatbotRepositoryException(
            code: ChatbotFailureCode.aiTimeout,
            message: 'AI phản hồi quá thời gian.',
            isRetryable: true,
          );
        }
        return testSendResult('conversation-retry', message: message);
      };
      controller = ChatbotController(repository: repository);

      await controller.sendMessage('Hãy tư vấn giúp tôi.');
      expect(controller.state.sendError?.code, ChatbotFailureCode.aiTimeout);
      expect(controller.state.failedMessage, 'Hãy tư vấn giúp tôi.');

      await controller.retrySendMessage();

      expect(attempts, 2);
      expect(controller.state.sendError, isNull);
      expect(controller.state.messages, hasLength(2));
      expect(controller.state.activeConversationId, 'conversation-retry');
    });

    test('rejects empty message without calling repository', () async {
      final repository = TestChatbotRepository();
      controller = ChatbotController(repository: repository);

      await controller.sendMessage('   ');

      expect(repository.sendMessageCalls, 0);
      expect(controller.state.sendError?.code,
          ChatbotFailureCode.validationError);
    });
  });
}
