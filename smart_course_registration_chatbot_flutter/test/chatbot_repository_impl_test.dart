import 'package:flutter_test/flutter_test.dart';
import 'package:smart_course_registration_chatbot_flutter/features/chat/data/chatbot_data_source.dart';
import 'package:smart_course_registration_chatbot_flutter/features/chat/data/chatbot_data_source_exception.dart';
import 'package:smart_course_registration_chatbot_flutter/features/chat/data/chatbot_repository_impl.dart';
import 'package:smart_course_registration_chatbot_flutter/features/chat/data/fake_chatbot_data_source.dart';
import 'package:smart_course_registration_chatbot_flutter/features/chat/domain/chatbot_repository_exception.dart';
import 'package:smart_course_registration_chatbot_flutter/features/chat/domain/chatbot_response.dart';

void main() {
  group('ChatbotRepositoryImpl with FakeChatbotDataSource', () {
    late FakeChatbotDataSource dataSource;
    late ChatbotRepositoryImpl repository;

    setUp(() {
      var tick = 0;
      dataSource = FakeChatbotDataSource(
        clock: () => DateTime.utc(2026, 11, 17).add(Duration(seconds: tick++)),
        assistantResponder: (message) async => 'Phản hồi mô phỏng: $message',
      );
      repository = ChatbotRepositoryImpl(dataSource: dataSource);
    });

    test('creates a conversation and stores user/assistant messages', () async {
      final result = await repository.sendMessage(
        message: '  Tôi cần tư vấn học phần  ',
      );

      expect(result.conversation.id, isNotEmpty);
      expect(result.conversation.title, 'Tôi cần tư vấn học phần');
      expect(result.conversation.messageCount, 2);
      expect(result.userMessage.content, 'Tôi cần tư vấn học phần');
      expect(result.assistantMessage.content,
          'Phản hồi mô phỏng: Tôi cần tư vấn học phần');
      expect(result.assistantMessage.evidenceStatus, isNotNull);
    });

    test('continues an existing conversation', () async {
      final first = await repository.sendMessage(message: 'Tin nhắn thứ nhất');
      final second = await repository.sendMessage(
        message: 'Tin nhắn thứ hai',
        conversationId: first.conversation.id,
      );

      expect(second.conversation.id, first.conversation.id);
      expect(second.conversation.messageCount, 4);
      expect(second.userMessage.conversationId, first.conversation.id);
    });

    test('returns paginated conversations', () async {
      await repository.sendMessage(message: 'Hội thoại một');
      await repository.sendMessage(message: 'Hội thoại hai');
      await repository.sendMessage(message: 'Hội thoại ba');

      final firstPage = await repository.getConversations(
        page: 1,
        pageSize: 2,
      );
      final secondPage = await repository.getConversations(
        page: 2,
        pageSize: 2,
      );

      expect(firstPage.conversations, hasLength(2));
      expect(firstPage.total, 3);
      expect(firstPage.hasMore, isTrue);
      expect(secondPage.conversations, hasLength(1));
      expect(secondPage.hasMore, isFalse);
    });

    test('returns newest messages first and supports older-message cursor',
        () async {
      final sent = await repository.sendMessage(message: 'Tin nhắn đầu');
      await repository.sendMessage(
        message: 'Tin nhắn tiếp theo',
        conversationId: sent.conversation.id,
      );
      await repository.sendMessage(
        message: 'Tin nhắn cuối',
        conversationId: sent.conversation.id,
      );

      final newest = await repository.getMessages(
        conversationId: sent.conversation.id,
        limit: 2,
      );
      final older = await repository.getMessages(
        conversationId: sent.conversation.id,
        cursor: newest.nextCursor,
        limit: 2,
      );

      expect(newest.messages, hasLength(2));
      expect(newest.hasMore, isTrue);
      expect(older.messages, hasLength(2));
      expect(older.hasMore, isTrue);
      expect(older.messages.first.content, 'Tin nhắn tiếp theo');
    });

    test('deletes a conversation and its messages', () async {
      final sent = await repository.sendMessage(message: 'Cần xóa');
      await repository.deleteConversation(
        conversationId: sent.conversation.id,
      );

      final page = await repository.getConversations();
      expect(page.total, 0);

      await expectLater(
        repository.getMessages(conversationId: sent.conversation.id),
        throwsA(
          isA<ChatbotRepositoryException>().having(
            (error) => error.code,
            'code',
            ChatbotFailureCode.conversationNotFound,
          ),
        ),
      );
    });

    test('rejects an empty message', () {
      expect(
        () => repository.sendMessage(message: '   '),
        throwsA(
          isA<ChatbotRepositoryException>().having(
            (error) => error.code,
            'code',
            ChatbotFailureCode.validationError,
          ),
        ),
      );
    });

    test('rejects a message longer than 2000 characters', () {
      expect(
        () => repository.sendMessage(message: 'a' * 2001),
        throwsA(
          isA<ChatbotRepositoryException>().having(
            (error) => error.code,
            'code',
            ChatbotFailureCode.validationError,
          ),
        ),
      );
    });

    test('maps data-source exceptions to repository exceptions', () async {
      final failingRepository = ChatbotRepositoryImpl(
        dataSource: _FailingChatbotDataSource(),
      );

      await expectLater(
        failingRepository.sendMessage(message: 'Xin tư vấn'),
        throwsA(
          isA<ChatbotRepositoryException>()
              .having(
                (error) => error.code,
                'code',
                ChatbotFailureCode.aiTimeout,
              )
              .having(
                (error) => error.isRetryable,
                'isRetryable',
                isTrue,
              ),
        ),
      );
    });

    test('maps unexpected data-source errors to unknown failure', () async {
      final failingRepository = ChatbotRepositoryImpl(
        dataSource: _UnexpectedErrorDataSource(),
      );

      await expectLater(
        failingRepository.sendMessage(message: 'Xin tư vấn'),
        throwsA(
          isA<ChatbotRepositoryException>().having(
            (error) => error.code,
            'code',
            ChatbotFailureCode.unknown,
          ),
        ),
      );
    });
  });
}

class _FailingChatbotDataSource implements ChatbotDataSource {
  @override
  Future<ChatbotSendMessageResult> sendMessage({
    required String message,
    String? conversationId,
    String? clientRequestId,
  }) async {
    throw const ChatbotDataSourceException(
      code: ChatbotFailureCode.aiTimeout,
      message: 'AI phản hồi quá thời gian.',
      isRetryable: true,
    );
  }

  @override
  Future<ChatbotConversationPage> getConversations({
    int page = 1,
    int pageSize = 20,
  }) async {
    throw StateError('Not used in this test.');
  }

  @override
  Future<ChatbotMessagePage> getMessages({
    required String conversationId,
    String? cursor,
    int limit = 30,
  }) async {
    throw StateError('Not used in this test.');
  }

  @override
  Future<void> deleteConversation({required String conversationId}) async {
    throw StateError('Not used in this test.');
  }
}

class _UnexpectedErrorDataSource extends _FailingChatbotDataSource {
  @override
  Future<ChatbotSendMessageResult> sendMessage({
    required String message,
    String? conversationId,
    String? clientRequestId,
  }) async {
    throw StateError('Unexpected test failure.');
  }
}
