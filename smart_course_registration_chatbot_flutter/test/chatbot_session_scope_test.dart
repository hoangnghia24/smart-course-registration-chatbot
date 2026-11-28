import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_course_registration_chatbot_flutter/app/smart_course_app.dart';
import 'package:smart_course_registration_chatbot_flutter/features/auth/data/f01_auth_gateway.dart';
import 'package:smart_course_registration_chatbot_flutter/features/chat/chatbot_figma_screen.dart';
import 'package:smart_course_registration_chatbot_flutter/features/chat/chatbot_repository_scope.dart';
import 'package:smart_course_registration_chatbot_flutter/features/chat/chatbot_session_scope.dart';
import 'package:smart_course_registration_chatbot_flutter/features/chat/data/chatbot_repository_impl.dart';
import 'package:smart_course_registration_chatbot_flutter/features/chat/data/serverpod_chatbot_data_source.dart';
import 'package:smart_course_registration_chatbot_flutter/features/chat/domain/chatbot_response.dart';
import 'package:smart_course_registration_chatbot_flutter/features/chat/presentation/chatbot_controller.dart';

import 'helpers/chatbot_test_support.dart';

class _FakeF01AuthGateway implements F01AuthGateway {
  F01User? currentUser;

  @override
  Future<F01User> getCurrentUser() async {
    final user = currentUser;
    if (user == null) {
      throw const F01NotSignedInException();
    }
    return user;
  }

  @override
  Future<F01User> signIn(String email, String password) async {
    final user = F01User(
      accountId: email.contains('sv2') ? 202 : 101,
      role: F01Role.student,
      status: 'active',
      studentCode: email.contains('sv2') ? '23110002' : '23110001',
    );
    currentUser = user;
    return user;
  }

  @override
  Future<void> signOut() async {
    currentUser = null;
  }
}

void main() {
  final textInput = find.byKey(const Key('chatbot_question_input'));
  final sendButton = find.byKey(const Key('chatbot_send_button'));
  final resetButton = find.byKey(const Key('chatbot_new_conversation_button'));
  final backButton = find.byKey(const Key('chatbot_back_button'));

  group('ChatbotController reset & late response safety', () {
    test(
      'resetConversationInMemory clears messages, sending state, and ignores late responses',
      () async {
        final completer = Completer<ChatbotSendMessageResult>();
        final repository = TestChatbotRepository();
        repository.onSendMessage = ({
          required message,
          conversationId,
          clientRequestId,
        }) => completer.future;

        final controller = ChatbotController(repository: repository);
        addTearDown(controller.dispose);
        await controller.initialize();

        final sendFuture = controller.sendMessage('Câu hỏi đang chờ AI');
        expect(controller.state.isSending, isTrue);

        // Người dùng bấm Reset trong lúc request vẫn đang chờ
        controller.resetConversationInMemory();
        expect(controller.state.isSending, isFalse);
        expect(controller.state.messages, isEmpty);
        expect(controller.state.activeConversationId, isNull);

        // Phản hồi trễ từ request cũ hoàn tất
        completer.complete(
          testSendResult('late-conv', message: 'Câu hỏi đang chờ AI'),
        );
        await sendFuture;

        // Phản hồi trễ không được phép hiển thị vào hội thoại đã reset
        expect(controller.state.messages, isEmpty);
        expect(controller.state.activeConversationId, isNull);
        expect(controller.state.isSending, isFalse);
      },
    );

    test('disposed controller during pending AI request does not throw', () async {
      final completer = Completer<ChatbotSendMessageResult>();
      final repository = TestChatbotRepository();
      repository.onSendMessage = ({
        required message,
        conversationId,
        clientRequestId,
      }) => completer.future;

      final controller = ChatbotController(repository: repository);
      await controller.initialize();

      final sendFuture = controller.sendMessage('Câu hỏi trước khi đăng xuất');
      expect(controller.state.isSending, isTrue);

      controller.dispose();
      completer.complete(
        testSendResult('disposed-conv', message: 'Câu hỏi trước khi đăng xuất'),
      );
      await sendFuture;

      expect(controller.state.messages, isEmpty);
    });
  });

  group('ChatbotSessionScope & Navigation / Auth lifecycle', () {
    testWidgets(
      'single conversation mode hides history button, preserves messages across screen navigation, and resets in RAM',
      (tester) async {
        var callCount = 0;
        final dataSource = ServerpodChatbotDataSource.fromRpc(
          sendMessageRpc: (message, conversationId, clientRequestId) async {
            callCount += 1;
            expect(conversationId, isNull);
            return 'Phản hồi AI lần $callCount cho: $message';
          },
        );
        final repository = ChatbotRepositoryImpl(dataSource: dataSource);

        final gateway = _FakeF01AuthGateway()
          ..currentUser = const F01User(
            accountId: 101,
            role: F01Role.student,
            status: 'active',
            studentCode: '23110001',
          );

        await tester.pumpWidget(
          ChatbotRepositoryScope(
            repository: repository,
            child: SmartCourseApp(f01Gateway: gateway),
          ),
        );
        await tester.pumpAndSettle();

        // Mở màn hình Chatbot từ StudentDashboard
        final aiFeatureCard = find.text('Trợ lý học vụ AI');
        await tester.scrollUntilVisible(aiFeatureCard, 200);
        await tester.tap(aiFeatureCard);
        await tester.pumpAndSettle();

        // Chế độ kết nối thật: không có banner mô phỏng, không có nút lịch sử đa hội thoại
        expect(find.byKey(const Key('chatbot_simulation_banner')), findsNothing);
        expect(
          find.byKey(const Key('chatbot_conversations_button')),
          findsNothing,
        );

        // Gửi tin nhắn AI
        await tester.enterText(textInput, 'Tôi nên học môn nào?');
        await tester.tap(sendButton);
        await tester.pumpAndSettle();

        expect(find.text('Tôi nên học môn nào?'), findsOneWidget);
        expect(
          find.text('Phản hồi AI lần 1 cho: Tôi nên học môn nào?'),
          findsOneWidget,
        );

        // Quay về Dashboard rồi mở lại Chatbot: hội thoại vẫn còn nguyên trong RAM
        await tester.tap(backButton);
        await tester.pumpAndSettle();
        expect(find.text('Sinh viên'), findsOneWidget);

        await tester.tap(aiFeatureCard);
        await tester.pumpAndSettle();
        expect(find.text('Tôi nên học môn nào?'), findsOneWidget);
        expect(
          find.text('Phản hồi AI lần 1 cho: Tôi nên học môn nào?'),
          findsOneWidget,
        );

        // Bấm nút reset: xóa hội thoại trong RAM, không báo đã xóa dữ liệu Server
        await tester.tap(resetButton);
        await tester.pumpAndSettle();
        expect(find.text('Tôi nên học môn nào?'), findsNothing);
        expect(find.byKey(const Key('chatbot_empty_state')), findsOneWidget);
        expect(
          find.text('Đã đặt lại đoạn hội thoại trên màn hình hiện tại.'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'signing out clears RAM conversation and prevents late AI response from leaking into next login session',
      (tester) async {
        final pendingCompleter = Completer<String>();
        var callIndex = 0;
        final dataSource = ServerpodChatbotDataSource.fromRpc(
          sendMessageRpc: (message, conversationId, clientRequestId) {
            callIndex += 1;
            if (callIndex == 1) {
              return Future.value('Trả lời lượt 1 của phiên cũ');
            }
            if (callIndex == 2) {
              return pendingCompleter.future;
            }
            return Future.value('Trả lời của phiên mới');
          },
        );
        final repository = ChatbotRepositoryImpl(dataSource: dataSource);
        final gateway = _FakeF01AuthGateway()
          ..currentUser = const F01User(
            accountId: 101,
            role: F01Role.student,
            status: 'active',
            studentCode: '23110001',
          );

        await tester.pumpWidget(
          ChatbotRepositoryScope(
            repository: repository,
            child: SmartCourseApp(f01Gateway: gateway),
          ),
        );
        await tester.pumpAndSettle();

        // Mở Chatbot và gửi lượt 1 thành công
        final aiFeatureCard = find.text('Trợ lý học vụ AI');
        await tester.scrollUntilVisible(aiFeatureCard, 200);
        await tester.tap(aiFeatureCard);
        await tester.pumpAndSettle();

        await tester.enterText(textInput, 'Câu hỏi phiên 1');
        await tester.tap(sendButton);
        await tester.pumpAndSettle();
        expect(find.text('Trả lời lượt 1 của phiên cũ'), findsOneWidget);

        // Gửi lượt 2 nhưng AI chưa trả về ngay
        await tester.enterText(textInput, 'Câu hỏi treo khi đăng xuất');
        await tester.tap(sendButton);
        await tester.pump();
        expect(find.byKey(const Key('chatbot_sending_indicator')), findsOneWidget);

        // Quay lại Dashboard và Đăng xuất ngay trong lúc request lượt 2 đang chờ
        await tester.tap(backButton);
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('dashboard-sign-out')));
        await tester.pumpAndSettle();

        // Đã về màn hình đăng nhập
        expect(find.byKey(const ValueKey('login-submit')), findsOneWidget);

        // Đăng nhập lại (cùng tài khoản sv1@ou.edu.vn)
        await tester.enterText(
          find.byKey(const ValueKey('login-username')),
          'sv1@ou.edu.vn',
        );
        await tester.enterText(
          find.byKey(const ValueKey('login-password')),
          'secret123',
        );
        await tester.tap(find.byKey(const ValueKey('login-submit')));
        await tester.pumpAndSettle();

        // Phản hồi trễ của phiên cũ hoàn tất SAU khi đã đăng nhập phiên mới
        pendingCompleter.complete('Phản hồi trễ từ phiên cũ');
        await tester.pumpAndSettle();

        // Mở lại Chatbot ở phiên mới: phải hoàn toàn trống, không có tin nhắn cũ hay phản hồi trễ
        await tester.scrollUntilVisible(aiFeatureCard, 200);
        await tester.tap(aiFeatureCard);
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('chatbot_empty_state')), findsOneWidget);
        expect(find.text('Câu hỏi phiên 1'), findsNothing);
        expect(find.text('Trả lời lượt 1 của phiên cũ'), findsNothing);
        expect(find.text('Câu hỏi treo khi đăng xuất'), findsNothing);
        expect(find.text('Phản hồi trễ từ phiên cũ'), findsNothing);
      },
    );

    testWidgets(
      'direct ChatbotSessionScope swaps controller on account change',
      (tester) async {
        final repository = TestChatbotRepository();
        String? sessionKey = 'user-1';

        await tester.pumpWidget(
          StatefulBuilder(
            builder: (context, setState) {
              return ChatbotRepositoryScope(
                repository: repository,
                child: ChatbotSessionScope(
                  sessionKey: sessionKey,
                  isSimulatedSource: false,
                  child: MaterialApp(
                    home: Column(
                      children: [
                        TextButton(
                          key: const Key('switch_session_button'),
                          onPressed: () => setState(() => sessionKey = 'user-2'),
                          child: const Text('Đổi tài khoản'),
                        ),
                        const Expanded(child: ChatbotFigmaScreen()),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
        await tester.pumpAndSettle();

        await tester.enterText(textInput, 'Tin nhắn user 1');
        await tester.tap(sendButton);
        await tester.pumpAndSettle();
        expect(find.text('Tin nhắn user 1'), findsOneWidget);

        await tester.tap(find.byKey(const Key('switch_session_button')));
        await tester.pumpAndSettle();

        expect(find.text('Tin nhắn user 1'), findsNothing);
        expect(find.byKey(const Key('chatbot_empty_state')), findsOneWidget);
      },
    );
  });
}
