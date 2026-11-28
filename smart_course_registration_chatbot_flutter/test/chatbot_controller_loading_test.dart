import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:smart_course_registration_chatbot_flutter/features/chat/domain/chatbot_repository_exception.dart';
import 'package:smart_course_registration_chatbot_flutter/features/chat/domain/chatbot_response.dart';
import 'package:smart_course_registration_chatbot_flutter/features/chat/presentation/chatbot_controller.dart';
import 'package:smart_course_registration_chatbot_flutter/features/chat/presentation/chatbot_state.dart';

import 'helpers/chatbot_test_support.dart';

void main() {
  group('ChatbotController loading and error states', () {
    late ChatbotController controller;

    tearDown(() {
      controller.dispose();
    });

    test('conversation list loading is independent from message history loading',
        () async {
      final repository = TestChatbotRepository();
      final conversations = Completer<ChatbotConversationPage>();
      final messages = Completer<ChatbotMessagePage>();
      repository.onGetConversations = ({required page, required pageSize}) =>
          conversations.future;
      repository.onGetMessages = ({
        required conversationId,
        required cursor,
        required limit,
      }) => messages.future;
      controller = ChatbotController(repository: repository);

      final initializing = controller.initialize();
      expect(controller.state.conversationsStatus, ChatbotRequestStatus.loading);
      expect(controller.state.messagesStatus, ChatbotRequestStatus.idle);

      conversations.complete(
        const ChatbotConversationPage(
          conversations: [],
          page: 1,
          pageSize: 20,
          total: 0,
          hasMore: false,
        ),
      );
      await initializing;
      expect(controller.state.conversationsStatus, ChatbotRequestStatus.loaded);
      expect(controller.state.isConversationListEmpty, isTrue);

      final loadingHistory = controller.selectConversation('conversation-1');
      expect(controller.state.conversationsStatus, ChatbotRequestStatus.loaded);
      expect(controller.state.messagesStatus, ChatbotRequestStatus.loading);
      messages.complete(testMessagePage('conversation-1', const []));
      await loadingHistory;
      expect(controller.state.messagesStatus, ChatbotRequestStatus.loaded);
    });

    test('conversation list failure can be retried', () async {
      final repository = TestChatbotRepository();
      var attempts = 0;
      repository.onGetConversations = ({required page, required pageSize}) async {
        attempts += 1;
        if (attempts == 1) {
          throw const ChatbotRepositoryException(
            code: ChatbotFailureCode.networkUnavailable,
            message: 'Mất kết nối mạng.',
            isRetryable: true,
          );
        }
        return const ChatbotConversationPage(
          conversations: [],
          page: 1,
          pageSize: 20,
          total: 0,
          hasMore: false,
        );
      };
      controller = ChatbotController(repository: repository);

      await controller.loadConversations();
      expect(controller.state.conversationsStatus, ChatbotRequestStatus.error);
      expect(controller.state.conversationsError?.isRetryable, isTrue);

      await controller.retryConversations();
      expect(controller.state.conversationsStatus, ChatbotRequestStatus.loaded);
      expect(controller.state.conversationsError, isNull);
      expect(attempts, 2);
    });

    test('message history failure can be retried independently', () async {
      final repository = TestChatbotRepository();
      var attempts = 0;
      repository.onGetMessages = ({
        required conversationId,
        required cursor,
        required limit,
      }) async {
        attempts += 1;
        if (attempts == 1) {
          throw const ChatbotRepositoryException(
            code: ChatbotFailureCode.networkUnavailable,
            message: 'Không tải được lịch sử.',
            isRetryable: true,
          );
        }
        return testMessagePage(conversationId, const []);
      };
      controller = ChatbotController(repository: repository);

      await controller.selectConversation('conversation-1');
      expect(controller.state.messagesStatus, ChatbotRequestStatus.error);
      expect(controller.state.messagesError?.isRetryable, isTrue);

      await controller.retryMessages();
      expect(controller.state.messagesStatus, ChatbotRequestStatus.loaded);
      expect(controller.state.messagesError, isNull);
      expect(attempts, 2);
    });
  });
}