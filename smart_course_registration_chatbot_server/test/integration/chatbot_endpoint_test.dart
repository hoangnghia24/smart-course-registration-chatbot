import 'package:serverpod/serverpod.dart';
import 'package:smart_course_registration_chatbot_server/src/endpoints/chatbot_endpoint.dart';
import 'package:smart_course_registration_chatbot_server/src/generated/protocol.dart';
import 'package:test/test.dart';

import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('ChatbotEndpoint.sendMessage', (sessionBuilder, _) {
    test('rejects blank and over-limit messages before calling AI', () async {
      var aiCalls = 0;
      final endpoint = ChatbotEndpoint(
        answerGenerator: (session, message, history) async {
          aiCalls++;
          return 'unused';
        },
      );
      final session = sessionBuilder.build();

      await expectLater(
        endpoint.sendMessage(session, '   ', null, 'blank'),
        throwsA(
          isA<AppException>().having(
            (error) => error.code,
            'code',
            'CHAT_MESSAGE_INVALID',
          ),
        ),
      );
      await expectLater(
        endpoint.sendMessage(session, 'a' * 2001, null, 'over-limit'),
        throwsA(
          isA<AppException>().having(
            (error) => error.code,
            'code',
            'CHAT_MESSAGE_INVALID',
          ),
        ),
      );

      expect(aiCalls, 0);
    });

    test(
      'creates a conversation and stores both messages atomically',
      () async {
        const authUserId = 'chat-student-create';
        final setupSession = sessionBuilder.build();
        final student = await _seedStudent(
          setupSession,
          authUserId: authUserId,
          suffix: 'create',
        );
        final authenticatedSession = sessionBuilder
            .copyWith(
              authentication: AuthenticationOverride.authenticationInfo(
                authUserId,
                <Scope>{},
              ),
            )
            .build();
        final endpoint = ChatbotEndpoint(
          answerGenerator: (session, message, history) async => 'Câu trả lời AI',
        );

        final answer = await endpoint.sendMessage(
          authenticatedSession,
          '  Tôi nên học môn nào?  ',
          null,
          'request-1',
        );

        expect(answer.answer, 'Câu trả lời AI');
        expect(answer.conversationId, greaterThan(0));
        final conversations = await ChatbotConversation.db.find(
          setupSession,
          where: (table) => table.studentId.equals(student.id!),
        );
        expect(conversations, hasLength(1));
        expect(answer.conversationId, conversations.single.id);
        final replay = await endpoint.sendMessage(
          authenticatedSession, 'Tôi nên học môn nào?', null, 'request-1',
        );
        expect(replay.conversationId, answer.conversationId);
        expect(replay.answer, answer.answer);
        await expectLater(
          endpoint.sendMessage(authenticatedSession, 'Câu khác', null, 'request-1'),
          throwsA(isA<AppException>().having(
            (error) => error.code, 'code', 'CHAT_REQUEST_CONFLICT',
          )),
        );
        expect(conversations.single.title, 'Tôi nên học môn nào?');
        expect(
          conversations.single.updatedAt,
          conversations.single.createdAt,
        );

        final messages = await ChatbotMessage.db.find(
          setupSession,
          where: (table) =>
              table.conversationId.equals(conversations.single.id!),
          orderBy: (table) => table.id,
        );
        expect(messages, hasLength(2));
        expect(messages[0].role, ChatbotMessageRole.user);
        expect(messages[0].content, 'Tôi nên học môn nào?');
        expect(messages[1].role, ChatbotMessageRole.assistant);
        expect(messages[1].content, 'Câu trả lời AI');
      },
    );

    test('appends to an owned conversation and updates updatedAt', () async {
      const authUserId = 'chat-student-append';
      final setupSession = sessionBuilder.build();
      await _seedStudent(
        setupSession,
        authUserId: authUserId,
        suffix: 'append',
      );
      final authenticatedSession = sessionBuilder
          .copyWith(
            authentication: AuthenticationOverride.authenticationInfo(
              authUserId,
              <Scope>{},
            ),
          )
          .build();
      var answerNumber = 0;
      List<ChatbotMessage> receivedHistory = [];
      final endpoint = ChatbotEndpoint(
        answerGenerator: (session, message, history) async {
          receivedHistory = history;
          return 'Trả lời ${++answerNumber}';
        },
      );

      await endpoint.sendMessage(
        authenticatedSession,
        'Tin nhắn đầu',
        null,
        'append-1',
      );
      final conversation = (await ChatbotConversation.db.find(
        setupSession,
      )).single;
      final firstUpdatedAt = conversation.updatedAt;

      await endpoint.sendMessage(
        authenticatedSession,
        'Tin nhắn tiếp theo',
        conversation.id,
        'append-2',
      );

      final updatedConversation = await ChatbotConversation.db.findById(
        setupSession,
        conversation.id!,
      );
      final messages = await ChatbotMessage.db.find(
        setupSession,
        where: (table) => table.conversationId.equals(conversation.id!),
      );
      expect(updatedConversation!.updatedAt.isBefore(firstUpdatedAt), isFalse);
      expect(messages, hasLength(4));
      expect(receivedHistory.map((m) => m.content).toList(),
          ['Tin nhắn đầu', 'Trả lời 1']);
    });

    test('does not call AI for another student conversation', () async {
      final setupSession = sessionBuilder.build();
      final owner = await _seedStudent(
        setupSession,
        authUserId: 'chat-owner',
        suffix: 'owner',
      );
      await _seedStudent(
        setupSession,
        authUserId: 'chat-other',
        suffix: 'other',
      );
      final conversation = await ChatbotConversation.db.insertRow(
        setupSession,
        ChatbotConversation(
          studentId: owner.id!,
          title: 'Riêng tư',
          createdAt: DateTime.now().toUtc(),
          updatedAt: DateTime.now().toUtc(),
        ),
      );
      var aiCalls = 0;
      final endpoint = ChatbotEndpoint(
        answerGenerator: (session, message, history) async {
          aiCalls++;
          return 'unused';
        },
      );
      final otherStudentSession = sessionBuilder
          .copyWith(
            authentication: AuthenticationOverride.authenticationInfo(
              'chat-other',
              <Scope>{},
            ),
          )
          .build();

      await expectLater(
        endpoint.sendMessage(
          otherStudentSession,
          'Đọc hội thoại',
          conversation.id,
          'other-1',
        ),
        throwsA(
          isA<AppException>().having(
            (error) => error.code,
            'code',
            'CHAT_CONVERSATION_NOT_FOUND',
          ),
        ),
      );
      expect(aiCalls, 0);
      expect(await ChatbotMessage.db.find(setupSession), isEmpty);
    });

    test('does not persist anything when AI fails', () async {
      const authUserId = 'chat-student-ai-failure';
      final setupSession = sessionBuilder.build();
      await _seedStudent(
        setupSession,
        authUserId: authUserId,
        suffix: 'failure',
      );
      final authenticatedSession = sessionBuilder
          .copyWith(
            authentication: AuthenticationOverride.authenticationInfo(
              authUserId,
              <Scope>{},
            ),
          )
          .build();
      final endpoint = ChatbotEndpoint(
        answerGenerator: (session, message, history) async => throw AppException(
          code: 'AI_TEST_FAILURE',
          message: 'AI failed',
        ),
      );

      await expectLater(
        endpoint.sendMessage(
          authenticatedSession,
          'Tin nhắn không được lưu',
          null,
          'failure-1',
        ),
        throwsA(
          isA<AppException>().having(
            (error) => error.code,
            'code',
            'AI_TEST_FAILURE',
          ),
        ),
      );

      expect(await ChatbotConversation.db.find(setupSession), isEmpty);
      expect(await ChatbotMessage.db.find(setupSession), isEmpty);
      expect(await ChatbotRequest.db.find(setupSession), isEmpty);
    });
  });
}

Future<Student> _seedStudent(
  Session session, {
  required String authUserId,
  required String suffix,
}) async {
  final now = DateTime.now().toUtc();
  final account = await UserAccount.db.insertRow(
    session,
    UserAccount(
      authUserId: authUserId,
      schoolEmail: '$suffix@student.example.edu.vn',
      role: AccountRole.student,
      status: AccountStatus.active,
      createdAt: now,
      updatedAt: now,
    ),
  );
  final curriculum = await Curriculum.db.insertRow(
    session,
    Curriculum(
      code: 'CUR-$suffix',
      name: 'Chương trình $suffix',
      majorCode: 'MAJ-$suffix',
      status: 'ACTIVE',
    ),
  );
  final version = await CurriculumVersion.db.insertRow(
    session,
    CurriculumVersion(
      curriculumId: curriculum.id!,
      versionCode: 'V1-$suffix',
      effectiveYear: 2026,
      status: 'PUBLISHED',
      revision: 1,
    ),
  );

  return Student.db.insertRow(
    session,
    Student(
      userAccountId: account.id!,
      studentCode: 'SV-$suffix',
      curriculumVersionId: version.id!,
      academicStatus: 'ACTIVE',
      admissionYear: 2026,
    ),
  );
}
