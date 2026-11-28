import 'package:flutter_test/flutter_test.dart';
import 'package:smart_course_registration_chatbot_client/smart_course_registration_chatbot_client.dart';
import 'package:smart_course_registration_chatbot_flutter/features/chat/data/chatbot_data_source_exception.dart';
import 'package:smart_course_registration_chatbot_flutter/features/chat/data/chatbot_repository_impl.dart';
import 'package:smart_course_registration_chatbot_flutter/features/chat/data/serverpod_chatbot_data_source.dart';
import 'package:smart_course_registration_chatbot_flutter/features/chat/domain/chatbot_message.dart'
    as domain;
import 'package:smart_course_registration_chatbot_flutter/features/chat/domain/chatbot_repository_exception.dart';

void main() {
  group('ServerpodChatbotDataSource', () {
    test(
      'sends question, forwards clientRequestId, and never fabricates backend conversationId',
      () async {
        final recordedMessages = <String>[];
        final recordedConversationIds = <int?>[];
        final recordedRequestIds = <String?>[];

        final fixedNow = DateTime.utc(2026, 11, 28, 12, 0);
        final dataSource = ServerpodChatbotDataSource.fromRpc(
          clock: () => fixedNow,
          sendMessageRpc: (message, conversationId, clientRequestId) async {
            recordedMessages.add(message);
            recordedConversationIds.add(conversationId);
            recordedRequestIds.add(clientRequestId);
            return '  Theo CTĐT ngành CNTT, bạn nên học Nhập môn lập trình trước.  ';
          },
        );

        final first = await dataSource.sendMessage(
          message: '  Em nên học môn nào trước?  ',
          conversationId: null,
          clientRequestId: 'req-1',
        );

        expect(recordedMessages, ['Em nên học môn nào trước?']);
        expect(recordedConversationIds, [null]);
        expect(recordedRequestIds, ['req-1']);

        expect(
          first.conversation.id,
          ServerpodChatbotDataSource.defaultLocalConversationId,
        );
        expect(first.userMessage.role, domain.ChatbotMessageRole.user);
        expect(first.userMessage.content, 'Em nên học môn nào trước?');
        expect(first.assistantMessage.role, domain.ChatbotMessageRole.assistant);
        expect(
          first.assistantMessage.content,
          'Theo CTĐT ngành CNTT, bạn nên học Nhập môn lập trình trước.',
        );
        // Không tự bịa dữ liệu học vụ/nguồn tham khảo/học phần liên quan
        expect(first.assistantMessage.evidenceStatus, isNull);
        expect(first.assistantMessage.sources, isEmpty);
        expect(first.assistantMessage.relatedCourses, isEmpty);

        // Lượt thứ 2: Controller truyền local conversationId từ lượt 1 vào,
        // adapter phải nhận diện đó là ID RAM cục bộ và gửi `null` lên Backend.
        final second = await dataSource.sendMessage(
          message: 'Còn môn Cơ sở dữ liệu thì sao?',
          conversationId: first.conversation.id,
          clientRequestId: 'req-2',
        );

        expect(recordedConversationIds, [null, null]);
        expect(recordedRequestIds, ['req-1', 'req-2']);
        expect(second.conversation.id, first.conversation.id);
        expect(second.userMessage.id, isNot(first.userMessage.id));
        expect(second.assistantMessage.id, isNot(first.assistantMessage.id));
      },
    );

    test(
      'passes positive integer conversationId when Backend provides real ID in future',
      () async {
        int? receivedId;
        final dataSource = ServerpodChatbotDataSource.fromRpc(
          sendMessageRpc: (message, conversationId, clientRequestId) async {
            receivedId = conversationId;
            return 'Câu trả lời tiếp nối.';
          },
        );

        final result = await dataSource.sendMessage(
          message: 'Câu hỏi tiếp theo',
          conversationId: '42',
          clientRequestId: 'req-42',
        );

        expect(receivedId, 42);
        expect(result.conversation.id, '42');
      },
    );

    test('rejects invalid non-local conversationId without calling RPC', () async {
      var rpcCalled = false;
      final dataSource = ServerpodChatbotDataSource.fromRpc(
        sendMessageRpc: (message, conversationId, clientRequestId) async {
          rpcCalled = true;
          return 'Không nên gọi';
        },
      );

      await expectLater(
        () => dataSource.sendMessage(
          message: 'Câu hỏi hợp lệ',
          conversationId: 'fake-conversation-99',
        ),
        throwsA(
          isA<ChatbotDataSourceException>().having(
            (e) => e.code,
            'code',
            ChatbotFailureCode.validationError,
          ),
        ),
      );
      expect(rpcCalled, isFalse);
    });

    test('maps Backend AppException through ChatbotRepositoryImpl', () async {
      final dataSource = ServerpodChatbotDataSource.fromRpc(
        sendMessageRpc: (message, conversationId, clientRequestId) async {
          throw AppException(
            code: 'AI_LOCAL_CONNECTION_ERROR',
            message: 'Không thể kết nối Ollama.',
          );
        },
      );
      final repository = ChatbotRepositoryImpl(dataSource: dataSource);

      await expectLater(
        () => repository.sendMessage(message: 'Tư vấn học phần'),
        throwsA(
          isA<ChatbotRepositoryException>()
              .having((e) => e.code, 'code', ChatbotFailureCode.aiUnavailable)
              .having((e) => e.isRetryable, 'isRetryable', isTrue),
        ),
      );
    });

    test('returns empty conversation and message pages in single-session mode', () async {
      final dataSource = ServerpodChatbotDataSource.fromRpc(
        sendMessageRpc: (_, _, _) async => 'OK',
      );

      final convPage = await dataSource.getConversations();
      expect(convPage.conversations, isEmpty);
      expect(convPage.total, 0);
      expect(convPage.hasMore, isFalse);

      final msgPage = await dataSource.getMessages(
        conversationId: ServerpodChatbotDataSource.defaultLocalConversationId,
      );
      expect(msgPage.messages, isEmpty);
      expect(msgPage.hasMore, isFalse);
    });
  });
}
