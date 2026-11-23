import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_course_registration_chatbot_flutter/features/chat/chatbot_figma_screen.dart';
import 'package:smart_course_registration_chatbot_flutter/features/chat/chatbot_repository_scope.dart';
import 'package:smart_course_registration_chatbot_flutter/features/chat/data/chatbot_repository.dart';
import 'package:smart_course_registration_chatbot_flutter/features/chat/data/chatbot_repository_impl.dart';
import 'package:smart_course_registration_chatbot_flutter/features/chat/data/fake_chatbot_data_source.dart';
import 'package:smart_course_registration_chatbot_flutter/features/chat/domain/chatbot_message.dart';
import 'package:smart_course_registration_chatbot_flutter/features/chat/domain/chatbot_related_course.dart';
import 'package:smart_course_registration_chatbot_flutter/features/chat/domain/chatbot_repository_exception.dart';
import 'package:smart_course_registration_chatbot_flutter/features/chat/domain/chatbot_response.dart';
import 'package:smart_course_registration_chatbot_flutter/features/chat/domain/chatbot_source.dart';
import 'package:smart_course_registration_chatbot_flutter/features/chat/presentation/chatbot_controller.dart';

import 'helpers/chatbot_test_support.dart';

void main() {
  final textInput = find.byKey(const Key('chatbot_question_input'));
  final sendButton = find.byKey(const Key('chatbot_send_button'));
  final historyButton = find.byKey(const Key('chatbot_conversations_button'));

  Widget screenWithRepository(
    ChatbotRepository repository, {
    bool throughScope = false,
    String? initialConversationId,
  }) {
    if (throughScope) {
      return MaterialApp(
        home: ChatbotRepositoryScope(
          repository: repository,
          child: const ChatbotFigmaScreen(),
        ),
      );
    }
    return MaterialApp(
      home: ChatbotFigmaScreen(
        repository: repository,
        initialConversationId: initialConversationId,
      ),
    );
  }

  Future<void> enterAndSend(WidgetTester tester, String message) async {
    await tester.enterText(textInput, message);
    await tester.tap(sendButton);
    await tester.pumpAndSettle();
  }

  Future<void> scrollToMessage(
    WidgetTester tester,
    Finder target,
  ) async {
    final list = find.byKey(const Key('chatbot_conversation_list'));
    for (var i = 0; i < 18 && target.evaluate().isEmpty; i++) {
      await tester.drag(list, const Offset(0, -240));
      await tester.pump(const Duration(milliseconds: 70));
    }
    expect(target, findsOneWidget);
  }

  testWidgets('scope bật controller, hiển thị cảnh báo mô phỏng, không có thẻ lớp giả',
      (tester) async {
    final repository = ChatbotRepositoryImpl(
      dataSource: FakeChatbotDataSource(),
    );
    await tester.pumpWidget(screenWithRepository(repository, throughScope: true));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('chatbot_simulation_banner')), findsOneWidget);
    expect(find.textContaining('Mô phỏng · Chưa kết nối Backend AI'), findsOneWidget);
    expect(find.byKey(const Key('chatbot_empty_state')), findsOneWidget);
    expect(find.byKey(const Key('sample_course_card')), findsNothing);
    expect(find.textContaining('45/60'), findsNothing);
  });

  testWidgets('gửi câu hỏi tạo hội thoại, hiển thị câu trả lời và xóa composer',
      (tester) async {
    final repository = ChatbotRepositoryImpl(
      dataSource: FakeChatbotDataSource(),
    );
    await tester.pumpWidget(screenWithRepository(repository));
    await tester.pumpAndSettle();
    await enterAndSend(tester, 'Học phần này là gì?');

    expect(find.text('Học phần này là gì?'), findsOneWidget);
    expect(find.textContaining('Đây là phản hồi mô phỏng'), findsOneWidget);
    expect(
      tester.widget<TextField>(textInput).controller!.text,
      isEmpty,
    );
  });

  testWidgets('gợi ý chỉ điền nội dung và không gọi repository', (tester) async {
    final repository = TestChatbotRepository();
    await tester.pumpWidget(screenWithRepository(repository));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Gợi ý môn chuyên ngành cho mình'));
    await tester.pump();
    expect(tester.widget<TextField>(textInput).controller!.text,
        'Gợi ý môn chuyên ngành cho mình');
    expect(repository.sendMessageCalls, 0);
  });

  testWidgets('đang gửi hiển thị loading và khóa gửi trùng', (tester) async {
    final completer = Completer<ChatbotSendMessageResult>();
    final repository = TestChatbotRepository();
    repository.onSendMessage = ({
      required message,
      conversationId,
      clientRequestId,
    }) => completer.future;

    await tester.pumpWidget(screenWithRepository(repository));
    await tester.pumpAndSettle();
    await tester.enterText(textInput, 'Tư vấn giúp tôi');
    await tester.tap(sendButton);
    await tester.pump();

    expect(find.byKey(const Key('chatbot_sending_indicator')), findsOneWidget);
    expect(repository.sendMessageCalls, 1);
    final button = tester.widget<IconButton>(sendButton);
    expect(button.onPressed, isNull);

    completer.complete(testSendResult('conversation-1', message: 'Tư vấn giúp tôi'));
    await tester.pumpAndSettle();
    expect(repository.sendMessageCalls, 1);
    expect(find.byKey(const Key('chatbot_sending_indicator')), findsNothing);
  });

  testWidgets('lỗi gửi có nút retry và gửi lại đúng câu hỏi', (tester) async {
    final repository = TestChatbotRepository();
    repository.onSendMessage = ({
      required message,
      conversationId,
      clientRequestId,
    }) async {
      if (repository.sendMessageCalls == 1) {
        throw const ChatbotRepositoryException(
          code: ChatbotFailureCode.aiTimeout,
          message: 'Hết thời gian chờ.',
          isRetryable: true,
        );
      }
      return testSendResult('recovered', message: message);
    };

    await tester.pumpWidget(screenWithRepository(repository));
    await tester.pumpAndSettle();
    await enterAndSend(tester, 'Tôi cần học phần nào?');
    expect(find.byKey(const Key('chatbot_send_error')), findsOneWidget);
    expect(find.textContaining('Hết thời gian chờ.'), findsOneWidget);

    await tester.tap(find.byKey(const Key('chatbot_retry_send_button')));
    await tester.pumpAndSettle();
    expect(repository.sendMessageCalls, 2);
    expect(find.byKey(const Key('chatbot_send_error')), findsNothing);
    expect(find.text('Tôi cần học phần nào?'), findsOneWidget);
  });

  testWidgets('danh sách hội thoại trống hiển thị empty state', (tester) async {
    final repository = ChatbotRepositoryImpl(
      dataSource: FakeChatbotDataSource(),
    );
    await tester.pumpWidget(screenWithRepository(repository));
    await tester.pumpAndSettle();
    await tester.tap(historyButton);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('chatbot_conversations_sheet')), findsOneWidget);
    expect(find.byKey(const Key('chatbot_conversations_empty')), findsOneWidget);
  });

  testWidgets('loading danh sách, lỗi, nút retry khôi phục', (tester) async {
    final waiting = Completer<ChatbotConversationPage>();
    final repository = TestChatbotRepository();
    var calls = 0;
    repository.onGetConversations = ({required page, required pageSize}) {
      calls++;
      if (calls == 1) return waiting.future;
      if (calls == 2) {
        return Future.error(const ChatbotRepositoryException(
          code: ChatbotFailureCode.networkUnavailable,
          message: 'Không thể kết nối.',
          isRetryable: true,
        ));
      }
      return Future.value(const ChatbotConversationPage(
        conversations: [], page: 1, pageSize: 20, total: 0, hasMore: false,
      ));
    };

    await tester.pumpWidget(screenWithRepository(repository));
    await tester.pump();
    await tester.tap(historyButton);
    await tester.pump();
    expect(find.byKey(const Key('chatbot_conversations_loading')), findsOneWidget);

    waiting.completeError(const ChatbotRepositoryException(
      code: ChatbotFailureCode.networkUnavailable,
      message: 'Mạng gián đoạn.',
    ));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('chatbot_conversations_retry_button')),
        findsOneWidget);

    await tester.tap(find.byKey(const Key('chatbot_conversations_retry_button')));
    await tester.pumpAndSettle();
    expect(calls, 2);
    expect(find.byKey(const Key('chatbot_conversations_retry_button')),
        findsOneWidget);

    await tester.tap(find.byKey(const Key('chatbot_conversations_retry_button')));
    await tester.pumpAndSettle();
    expect(calls, 3);
    expect(find.byKey(const Key('chatbot_conversations_empty')), findsOneWidget);
  });

  testWidgets('chọn hội thoại tải lịch sử và tạo hội thoại mới', (tester) async {
    final fake = FakeChatbotDataSource();
    final prior = await fake.sendMessage(message: 'Câu hỏi trước đó');
    final repository = ChatbotRepositoryImpl(dataSource: fake);
    await tester.pumpWidget(screenWithRepository(repository));
    await tester.pumpAndSettle();

    await tester.tap(historyButton);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(
      Key('chatbot_conversation_item_${prior.conversation.id}'),
    ));
    await tester.pumpAndSettle();
    await scrollToMessage(tester, find.text('Câu hỏi trước đó'));

    await tester.tap(find.byKey(const Key('chatbot_new_conversation_button')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('chatbot_empty_state')), findsOneWidget);
    expect(find.text('Câu hỏi trước đó'), findsNothing);
  });

  testWidgets('lỗi tải lịch sử có thể thử lại', (tester) async {
    final repo = TestChatbotRepository();
    final conv = testConversation('history-1');
    repo.onGetConversations = ({required page, required pageSize}) async =>
      ChatbotConversationPage(
        conversations: [conv], page: 1, pageSize: 20,
        total: 1, hasMore: false,
      );
    var historyCalls = 0;
    repo.onGetMessages = ({required conversationId, required cursor, required limit}) {
      historyCalls++;
      if (historyCalls == 1) {
        return Future.error(const ChatbotRepositoryException(
          code: ChatbotFailureCode.networkUnavailable,
          message: 'Mạng gián đoạn khi tải lịch sử.',
        ));
      }
      return Future.value(testMessagePage('history-1', [
        testMessage('history-message', 'history-1', 'Nội dung đã lưu'),
      ]));
    };

    await tester.pumpWidget(screenWithRepository(repo));
    await tester.pumpAndSettle();
    await tester.tap(historyButton);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('chatbot_conversation_item_history-1')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('chatbot_messages_error')), findsOneWidget);

    await tester.tap(find.byKey(const Key('chatbot_messages_retry_button')));
    await tester.pumpAndSettle();
    expect(historyCalls, 2);
    expect(find.text('Nội dung đã lưu'), findsOneWidget);
  });

  testWidgets('tải thêm lịch sử bằng cursor và loại bỏ tin nhắn trùng',
      (tester) async {
    final repo = TestChatbotRepository();
    repo.onGetConversations = ({required page, required pageSize}) async =>
      ChatbotConversationPage(conversations: [testConversation('old-1')],
        page: 1, pageSize: 20, total: 1, hasMore: false);
    repo.onGetMessages = ({required conversationId, required cursor, required limit}) async {
      if (cursor == null) {
        return testMessagePage('old-1', [
          testMessage('m2', 'old-1', 'Tin nhắn mới'),
        ], nextCursor: '1', hasMore: true);
      }
      return testMessagePage('old-1', [
        testMessage('m1', 'old-1', 'Tin nhắn cũ'),
      ]);
    };
    await tester.pumpWidget(screenWithRepository(repo));
    await tester.pumpAndSettle();
    await tester.tap(historyButton);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('chatbot_conversation_item_old-1')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('chatbot_load_older_messages_button')),
        findsOneWidget);
    await tester.tap(find.byKey(const Key('chatbot_load_older_messages_button')));
    await tester.pumpAndSettle();
    expect(repo.requestedMessageCursors, contains('1'));
    expect(find.text('Tin nhắn cũ'), findsOneWidget);
    expect(find.text('Tin nhắn mới'), findsOneWidget);
  });

  testWidgets('tải trang hai danh sách hội thoại trong bottom sheet',
      (tester) async {
    final repo = TestChatbotRepository();
    repo.onGetConversations = ({required page, required pageSize}) async =>
      ChatbotConversationPage(
        conversations: [testConversation(page == 1 ? 'c-first' : 'c-second')],
        page: page, pageSize: pageSize, total: 2,
        hasMore: page == 1,
      );
    await tester.pumpWidget(screenWithRepository(repo));
    await tester.pumpAndSettle();
    await tester.tap(historyButton);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('chatbot_load_more_conversations_button')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('chatbot_conversation_item_c-first')),
        findsOneWidget);
    expect(find.byKey(const Key('chatbot_conversation_item_c-second')),
        findsOneWidget);
  });

  testWidgets('xóa hội thoại đang mở và trở về bản nháp', (tester) async {
    final fake = FakeChatbotDataSource();
    final sent = await fake.sendMessage(message: 'Nội dung cần xóa');
    final controller = ChatbotController(
      repository: ChatbotRepositoryImpl(dataSource: fake),
      initialConversationId: sent.conversation.id,
    );
    addTearDown(controller.dispose);
    await tester.pumpWidget(MaterialApp(home: ChatbotFigmaScreen(
      controller: controller,
    )));
    await tester.pumpAndSettle();
    expect(controller.state.activeConversationId, sent.conversation.id);

    await tester.tap(historyButton);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(
      Key('chatbot_delete_conversation_${sent.conversation.id}'),
    ));
    await tester.pumpAndSettle();
    expect(controller.state.activeConversationId, isNull);
    expect(controller.state.conversations, isEmpty);
    expect(find.byKey(const Key('chatbot_conversations_empty')), findsOneWidget);
  });

  testWidgets('nguồn tham khảo và học phần cấu trúc không bịa thêm lớp học',
      (tester) async {
    final repo = TestChatbotRepository();
    repo.onSendMessage = ({required message, conversationId, clientRequestId}) async {
      final result = testSendResult('evidence-1', message: message,
          answer: 'Bạn có thể tham khảo môn sau.');
      return ChatbotSendMessageResult(
        conversation: result.conversation,
        userMessage: result.userMessage,
        assistantMessage: ChatbotMessage(
          id: result.assistantMessage.id,
          conversationId: result.conversation.id,
          role: ChatbotMessageRole.assistant,
          content: result.assistantMessage.content,
          createdAt: result.assistantMessage.createdAt,
          evidenceStatus: ChatbotEvidenceStatus.supported,
          sources: const [ChatbotSource(
            id: 'source1', title: 'Danh mục học phần',
            sourceType: ChatbotSourceType.courseCatalog,
            reference: 'CS101', excerpt: 'Thông tin chương trình.',
          )],
          relatedCourses: const [ChatbotRelatedCourse(
            courseId: 10, courseCode: 'CS101',
            courseName: 'Nhập môn lập trình', credits: 3,
            reason: 'Ví dụ dữ liệu trả về có cấu trúc',
          )],
        ),
      );
    };
    await tester.pumpWidget(screenWithRepository(repo));
    await tester.pumpAndSettle();
    await enterAndSend(tester, 'Tư vấn môn học');
    await scrollToMessage(tester,
        find.byKey(const Key('chatbot_message_sources_evidence-1-assistant-1')));
    await scrollToMessage(tester,
        find.byKey(const Key('chatbot_related_course_CS101')));
    expect(find.text('Danh mục học phần'), findsOneWidget);
    expect(find.text('Nhập môn lập trình'), findsOneWidget);
    expect(find.text('3 TC'), findsOneWidget);
    expect(find.textContaining('Mã học phần: CS101'), findsOneWidget);
    expect(find.textContaining('45/60'), findsNothing);
    expect(find.textContaining('Thứ 3 · Tiết 1'), findsNothing);
  });

  testWidgets('controller inject từ ngoài không bị dispose khi đóng widget',
      (tester) async {
    final controller = ChatbotController(repository: TestChatbotRepository());
    addTearDown(controller.dispose);
    await tester.pumpWidget(MaterialApp(home: ChatbotFigmaScreen(
      controller: controller,
    )));
    await tester.pumpAndSettle();
    await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));
    await controller.loadConversations(refresh: true);
    expect(controller.state.conversationsStatus, isNotNull);
  });
}
