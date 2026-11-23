import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:smart_course_registration_chatbot_flutter/features/chat/domain/chatbot_response.dart';
import 'package:smart_course_registration_chatbot_flutter/features/chat/presentation/chatbot_controller.dart';

import 'helpers/chatbot_test_support.dart';

void main() {
  group('ChatbotController request race protection', () {
    late ChatbotController controller;
    var controllerWasDisposed = false;

    setUp(() {
      controllerWasDisposed = false;
    });

    tearDown(() {
      if (!controllerWasDisposed) controller.dispose();
    });

    test('late history response from previous conversation is ignored', () async {
      final repository = TestChatbotRepository();
      final firstResponse = Completer<ChatbotMessagePage>();
      final secondResponse = Completer<ChatbotMessagePage>();
      repository.onGetMessages = ({
        required conversationId,
        required cursor,
        required limit,
      }) {
        if (conversationId == 'conversation-A') return firstResponse.future;
        return secondResponse.future;
      };
      controller = ChatbotController(repository: repository);

      final firstLoad = controller.selectConversation('conversation-A');
      final secondLoad = controller.selectConversation('conversation-B');

      secondResponse.complete(
        testMessagePage(
          'conversation-B',
          [testMessage('message-B', 'conversation-B', 'Tin nhắn B')],
        ),
      );
      await secondLoad;
      firstResponse.complete(
        testMessagePage(
          'conversation-A',
          [testMessage('message-A', 'conversation-A', 'Tin nhắn A')],
        ),
      );
      await firstLoad;

      expect(controller.state.activeConversationId, 'conversation-B');
      expect(controller.state.messages, hasLength(1));
      expect(controller.state.messages.single.id, 'message-B');
    });

    test('late send response does not enter a newly-created conversation',
        () async {
      final repository = TestChatbotRepository();
      final firstSendResponse = Completer<ChatbotSendMessageResult>();
      repository.onSendMessage = ({
        required message,
        conversationId,
        clientRequestId,
      }) {
        if (message == 'Tin nhắn cũ') return firstSendResponse.future;
        return Future.value(
          testSendResult(
            'conversation-new',
            message: message,
            answer: 'Phản hồi hội thoại mới.',
          ),
        );
      };
      controller = ChatbotController(repository: repository);

      final oldSend = controller.sendMessage('Tin nhắn cũ');
      await Future<void>.delayed(Duration.zero);
      controller.createNewConversation();
      await controller.sendMessage('Tin nhắn mới');

      expect(controller.state.activeConversationId, 'conversation-new');
      expect(controller.state.messages, hasLength(2));
      expect(controller.state.messages.first.content, 'Tin nhắn mới');

      firstSendResponse.complete(
        testSendResult(
          'conversation-old',
          message: 'Tin nhắn cũ',
          answer: 'Phản hồi hội thoại cũ.',
        ),
      );
      await oldSend;

      expect(controller.state.activeConversationId, 'conversation-new');
      expect(
        controller.state.messages.map((message) => message.id),
        containsAll(['conversation-new-user-1', 'conversation-new-assistant-1']),
      );
      expect(
        controller.state.messages.where(
          (message) => message.conversationId == 'conversation-old',
        ),
        isEmpty,
      );
      expect(
        controller.state.conversations.map((conversation) => conversation.id),
        containsAll(['conversation-old', 'conversation-new']),
      );
    });

    test('disposed controller ignores a pending history response', () async {
      final repository = TestChatbotRepository();
      final response = Completer<ChatbotMessagePage>();
      repository.onGetMessages = ({
        required conversationId,
        required cursor,
        required limit,
      }) => response.future;
      final disposableController =
          ChatbotController(repository: repository);
      controller = disposableController;

      final pending = disposableController.selectConversation(
        'conversation-dispose',
      );
      disposableController.dispose();
      controllerWasDisposed = true;
      response.complete(testMessagePage('conversation-dispose', const []));

      await expectLater(pending, completes);
    });
  });
}
