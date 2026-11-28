import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_course_registration_chatbot_flutter/app/smart_course_app.dart';
import 'package:smart_course_registration_chatbot_flutter/features/auth/data/f01_auth_gateway.dart';
import 'package:smart_course_registration_chatbot_flutter/features/chat/chatbot_figma_screen.dart';
import 'package:smart_course_registration_chatbot_flutter/features/chat/chatbot_repository_scope.dart';
import 'package:smart_course_registration_chatbot_flutter/features/chat/data/chatbot_repository_impl.dart';
import 'package:smart_course_registration_chatbot_flutter/features/chat/data/serverpod_chatbot_data_source.dart';
import 'package:smart_course_registration_chatbot_flutter/features/chat/domain/chatbot_faq.dart';
import 'package:smart_course_registration_chatbot_flutter/features/chat/domain/chatbot_message.dart';
import 'package:smart_course_registration_chatbot_flutter/features/chat/presentation/chatbot_controller.dart';

import 'helpers/chatbot_test_support.dart';

class _TestStudentAuthGateway implements F01AuthGateway {
  F01User? user = const F01User(
    accountId: 301,
    role: F01Role.student,
    status: 'active',
    studentCode: '23110001',
  );

  @override
  Future<F01User> getCurrentUser() async {
    final current = user;
    if (current == null) throw const F01NotSignedInException();
    return current;
  }

  @override
  Future<F01User> signIn(String email, String password) async {
    user = const F01User(
      accountId: 301,
      role: F01Role.student,
      status: 'active',
      studentCode: '23110001',
    );
    return user!;
  }

  @override
  Future<void> signOut() async {
    user = null;
  }
}

void main() {
  final textInput = find.byKey(const Key('chatbot_question_input'));
  final sendButton = find.byKey(const Key('chatbot_send_button'));
  final resetButton = find.byKey(const Key('chatbot_new_conversation_button'));
  final toggleFaqButton = find.byKey(const Key('chatbot_toggle_faq_button'));

  Future<void> scrollConversationUntilVisible(
    WidgetTester tester,
    Finder target,
  ) async {
    final list = find.byKey(const Key('chatbot_conversation_list'));
    for (var i = 0; i < 20 && target.evaluate().isEmpty; i++) {
      await tester.drag(list, const Offset(0, -220));
      await tester.pump(const Duration(milliseconds: 60));
    }
    expect(target, findsOneWidget);
  }

  group('Approved FAQ dataset & lookup by ID', () {
    test('contains 8 approved FAQs with unique IDs and revised academic guidance', () {
      expect(kApprovedChatbotFaqs, hasLength(8));
      final ids = kApprovedChatbotFaqs.map((e) => e.id).toSet();
      expect(ids, hasLength(8));

      final faq3 = findChatbotFaqById('faq_check_progress')!;
      expect(faq3.answer, contains('Kết quả học tập'));
      expect(faq3.answer, contains('—'));

      final faq4 = findChatbotFaqById('faq_course_catalog')!;
      expect(faq4.answer, contains('mã học phần hoặc tên môn học'));
      expect(faq4.answer.contains('3 tín chỉ'), isFalse);

      final faq6 = findChatbotFaqById('faq_label_eligible')!;
      expect(faq6.answer, contains('Đủ điều kiện'));
      expect(faq6.answer, contains('Chưa đủ điều kiện'));
      expect(faq6.answer, contains('Chưa xác định'));

      final faq7 = findChatbotFaqById('faq_label_priority')!;
      expect(faq7.answer, contains('khuyến nghị'));
      expect(faq7.answer, contains('không đồng nghĩa học phần đó đã đủ điều kiện đăng ký'));

      final faq8 = findChatbotFaqById('faq_use_recommendation')!;
      expect(faq8.answer, contains('Cá nhân hóa'));
      expect(faq8.answer, contains('Chờ đề xuất'));
      expect(faq8.answer, contains('DEMO/Preview'));
    });

    test('selectFaqById looks up by ID, never calls repository, and blocks accidental double tap', () {
      var now = DateTime.utc(2026, 11, 28, 14, 0, 0);
      final repository = TestChatbotRepository();
      final controller = ChatbotController(
        repository: repository,
        clock: () => now,
        faqDuplicateDebounce: const Duration(milliseconds: 350),
      );
      addTearDown(controller.dispose);

      // ID không tồn tại không tạo tin nhắn
      expect(controller.selectFaqById('non_existent_faq'), isFalse);
      expect(controller.state.messages, isEmpty);
      expect(repository.sendMessageCalls, 0);

      // Nhấn lần 1 theo ID hợp lệ
      expect(controller.selectFaqById('faq_view_curriculum'), isTrue);
      expect(repository.sendMessageCalls, 0);
      expect(controller.state.isSending, isFalse);
      expect(controller.state.messages, hasLength(2));
      expect(controller.state.messages[0].role, ChatbotMessageRole.user);
      expect(
        controller.state.messages[0].content,
        'Tôi xem chương trình đào tạo ở đâu?',
      );
      expect(controller.state.messages[1].role, ChatbotMessageRole.assistant);
      expect(
        controller.state.messages[1].content,
        findChatbotFaqById('faq_view_curriculum')!.answer,
      );

      // Nhấn đúp vô tình sau 100ms (< 350ms) bị chặn, không tạo cặp tin nhắn trùng
      now = now.add(const Duration(milliseconds: 100));
      expect(controller.selectFaqById('faq_view_curriculum'), isFalse);
      expect(controller.state.messages, hasLength(2));

      // Sau 500ms (> 350ms), sinh viên chủ động chọn lại cùng FAQ vẫn được phép
      now = now.add(const Duration(milliseconds: 500));
      expect(controller.selectFaqById('faq_view_curriculum'), isTrue);
      expect(controller.state.messages, hasLength(4));
      expect(repository.sendMessageCalls, 0);
    });
  });

  group('FAQ + AI combined conversation & UI lifecycle', () {
    testWidgets(
      'displays FAQ chips, answers FAQ without calling Backend, then sends free-text question to Backend in the same RAM conversation without sending FAQ history',
      (tester) async {
        final recordedBackendMessages = <String>[];
        final recordedBackendConversationIds = <int?>[];

        final dataSource = ServerpodChatbotDataSource.fromRpc(
          sendMessageRpc: (message, conversationId, clientRequestId) async {
            recordedBackendMessages.add(message);
            recordedBackendConversationIds.add(conversationId);
            return 'Theo CTĐT, bạn còn cần kiểm tra các môn tự chọn định hướng.';
          },
        );
        final repository = ChatbotRepositoryImpl(dataSource: dataSource);

        await tester.pumpWidget(
          MaterialApp(
            home: ChatbotFigmaScreen(
              repository: repository,
              isSimulatedSource: false,
              singleConversationMode: true,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // 1. Màn hình trống hiển thị danh sách FAQ
        expect(find.byKey(const Key('chatbot_faq_section_header')), findsOneWidget);
        final faqCurriculumChip = find.byKey(
          const Key('chatbot_faq_chip_faq_view_curriculum'),
        );
        expect(faqCurriculumChip, findsOneWidget);

        // 2. Nhấn FAQ "Tôi xem chương trình đào tạo ở đâu?"
        await tester.tap(faqCurriculumChip);
        await tester.pumpAndSettle();

        // Không gọi Backend, hiển thị ngay câu hỏi và câu trả lời cố định
        expect(recordedBackendMessages, isEmpty);
        expect(find.text('Tôi xem chương trình đào tạo ở đâu?'), findsOneWidget);
        expect(
          find.textContaining('Từ màn hình chính (Dashboard Sinh viên)'),
          findsOneWidget,
        );
        expect(find.byKey(const Key('chatbot_sending_indicator')), findsNothing);

        // 3. Sinh viên nhập câu hỏi tự do gửi cho AI trong cùng cuộc hội thoại
        await tester.enterText(textInput, 'Tôi còn thiếu những môn nào?');
        await tester.tap(sendButton);
        await tester.pumpAndSettle();

        // Chỉ gửi đúng câu hỏi tự nhập lên Backend, không tự nối lịch sử FAQ
        expect(recordedBackendMessages, ['Tôi còn thiếu những môn nào?']);
        expect(recordedBackendConversationIds, [null]);

        // Cả 4 tin nhắn (2 FAQ + 2 AI) cùng nằm trong một giao diện hội thoại RAM
        await scrollConversationUntilVisible(
          tester,
          find.text('Theo CTĐT, bạn còn cần kiểm tra các môn tự chọn định hướng.'),
        );
        expect(find.text('Tôi còn thiếu những môn nào?'), findsOneWidget);

        // 4. Mở lại danh sách FAQ sau khi đã bắt đầu hội thoại và chọn thêm FAQ khác
        await scrollConversationUntilVisible(tester, toggleFaqButton);
        await tester.tap(toggleFaqButton);
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('chatbot_inline_faq_panel')), findsOneWidget);

        final faqPriorityChip = find.byKey(
          const Key('chatbot_faq_chip_faq_label_priority'),
        );
        await scrollConversationUntilVisible(tester, faqPriorityChip);
        await tester.tap(faqPriorityChip);
        await tester.pumpAndSettle();

        // Vẫn chỉ có 1 lần gọi Backend từ câu hỏi AI trước đó
        expect(recordedBackendMessages, hasLength(1));
        await scrollConversationUntilVisible(
          tester,
          find.textContaining('Nhãn "Nên ưu tiên" chỉ là khuyến nghị'),
        );

        // 5. Reset hội thoại xóa cả tin nhắn FAQ và tin nhắn AI khỏi RAM
        await tester.tap(resetButton);
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('chatbot_empty_state')), findsOneWidget);
        expect(
          find.text('Theo CTĐT, bạn còn cần kiểm tra các môn tự chọn định hướng.'),
          findsNothing,
        );
      },
    );

    testWidgets('signing out clears FAQ messages from RAM session', (tester) async {
      var backendCalls = 0;
      final dataSource = ServerpodChatbotDataSource.fromRpc(
        sendMessageRpc: (_, _, _) async {
          backendCalls += 1;
          return 'Trả lời AI';
        },
      );
      final repository = ChatbotRepositoryImpl(dataSource: dataSource);
      final gateway = _TestStudentAuthGateway();

      await tester.pumpWidget(
        ChatbotRepositoryScope(
          repository: repository,
          child: SmartCourseApp(f01Gateway: gateway),
        ),
      );
      await tester.pumpAndSettle();

      final aiFeatureCard = find.text('Trợ lý học vụ AI');
      await tester.scrollUntilVisible(aiFeatureCard, 200);
      await tester.tap(aiFeatureCard);
      await tester.pumpAndSettle();

      await tester.tap(
        find.byKey(const Key('chatbot_faq_chip_faq_assistant_scope')),
      );
      await tester.pumpAndSettle();
      expect(backendCalls, 0);
      expect(
        find.textContaining('Mình không thực hiện đăng ký học phần thay bạn'),
        findsOneWidget,
      );

      // Quay về Dashboard và đăng xuất
      await tester.tap(find.byKey(const Key('chatbot_back_button')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('dashboard-sign-out')));
      await tester.pumpAndSettle();

      // Đăng nhập lại
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

      await tester.scrollUntilVisible(aiFeatureCard, 200);
      await tester.tap(aiFeatureCard);
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('chatbot_empty_state')), findsOneWidget);
      expect(
        find.textContaining('Mình không thực hiện đăng ký học phần thay bạn'),
        findsNothing,
      );
    });

    testWidgets('FAQ layout does not overflow on small 320x568 phone screen', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final repository = TestChatbotRepository();
      await tester.pumpWidget(
        MaterialApp(
          home: ChatbotFigmaScreen(
            repository: repository,
            isSimulatedSource: false,
            singleConversationMode: true,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      final faq8Chip = find.byKey(
        const Key('chatbot_faq_chip_faq_use_recommendation'),
      );
      await tester.ensureVisible(faq8Chip);
      await tester.pumpAndSettle();
      await tester.tap(faq8Chip);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      await tester.ensureVisible(toggleFaqButton);
      await tester.pumpAndSettle();
      await tester.tap(toggleFaqButton);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'Chatbot layout renders cleanly at 390x800, 360x800, and Desktop with long FAQ, many messages, expand/collapse FAQ, AI sending, and keyboard inset',
      (tester) async {
        tester.view.physicalSize = const Size(390, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetViewInsets);

        final pendingCompleter = Completer<String>();
        var callCount = 0;
        final dataSource = ServerpodChatbotDataSource.fromRpc(
          sendMessageRpc: (message, conversationId, clientRequestId) {
            callCount += 1;
            if (callCount <= 3) {
              return Future.value(
                'Phản hồi chi tiết lượt $callCount cho câu hỏi "$message": '
                'Theo CTĐT ngành CNTT, sinh viên cần kiểm tra kỹ học kỳ dự kiến, '
                'điều kiện học trước và quy định số tín chỉ tối thiểu/tối đa.',
              );
            }
            return pendingCompleter.future;
          },
        );
        final repository = ChatbotRepositoryImpl(dataSource: dataSource);
        final customFaqs = <ChatbotFaqItem>[
          ...kApprovedChatbotFaqs,
          const ChatbotFaqItem(
            id: 'faq_very_long_stress_test',
            category: ChatbotFaqCategory.recommendation,
            question:
                'Câu hỏi thường gặp rất dài để kiểm tra khả năng tự xuống dòng an toàn trên màn hình 390x800 và 320x568 mà không bao giờ tràn ngang?',
            answer:
                'Đây là câu trả lời hướng dẫn rất dài gồm nhiều mệnh đề liên tiếp nhằm kiểm tra bubble hội thoại của trợ lý học vụ khi hiển thị trên màn hình điện thoại 390x800, 360x800 và 320x568 vẫn cuộn mượt mà và không phát sinh bất kỳ lỗi RenderFlex overflow nào.',
          ),
        ];
        final controller = ChatbotController(
          repository: repository,
          faqs: customFaqs,
          faqDuplicateDebounce: Duration.zero,
        );
        addTearDown(controller.dispose);

        await tester.pumpWidget(
          MaterialApp(
            home: ChatbotFigmaScreen(
              controller: controller,
              isSimulatedSource: false,
              singleConversationMode: true,
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);

        // Chọn FAQ có câu hỏi và câu trả lời rất dài
        final longFaqChip = find.byKey(
          const Key('chatbot_faq_chip_faq_very_long_stress_test'),
        );
        await tester.ensureVisible(longFaqChip);
        await tester.pumpAndSettle();
        await tester.tap(longFaqChip);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);

        // Tạo danh sách hội thoại có nhiều tin nhắn (kết hợp FAQ + AI)
        controller.selectFaqById('faq_check_progress');
        controller.selectFaqById('faq_label_eligible');
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);

        for (var i = 1; i <= 3; i++) {
          await tester.enterText(
            textInput,
            'Câu hỏi tự do số $i về chương trình đào tạo và điều kiện học phần?',
          );
          await tester.tap(sendButton);
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        }

        // Mở và thu gọn danh sách FAQ khi đã có nhiều tin nhắn
        await tester.ensureVisible(toggleFaqButton);
        await tester.pumpAndSettle();
        await tester.tap(toggleFaqButton);
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('chatbot_inline_faq_panel')), findsOneWidget);
        expect(tester.takeException(), isNull);

        await tester.ensureVisible(toggleFaqButton);
        await tester.pumpAndSettle();
        await tester.tap(toggleFaqButton);
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('chatbot_inline_faq_panel')), findsNothing);
        expect(tester.takeException(), isNull);

        // Kiểm tra trạng thái AI đang gửi (isSending = true)
        await tester.enterText(textInput, 'Câu hỏi đang chờ phản hồi từ AI');
        await tester.tap(sendButton);
        await tester.pump();
        expect(find.byKey(const Key('chatbot_sending_indicator')), findsOneWidget);
        expect(tester.takeException(), isNull);

        // Kiểm tra thanh nhập tin nhắn khi bàn phím ảo xuất hiện (viewInsets.bottom = 300)
        tester.view.viewInsets = const FakeViewPadding(bottom: 300);
        await tester.pump();
        expect(tester.takeException(), isNull);

        // Kiểm tra chuyển sang 360x800 và Desktop 1280x800 khi đang gửi + mở bàn phím
        tester.view.physicalSize = const Size(360, 800);
        await tester.pump();
        expect(tester.takeException(), isNull);

        tester.view.viewInsets = FakeViewPadding.zero;
        tester.view.physicalSize = const Size(1280, 800);
        await tester.pump();
        expect(tester.takeException(), isNull);

        pendingCompleter.complete('Câu trả lời hoàn tất.');
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'handles sudden Chrome DevTools viewport width/height changes including extreme narrow constraints (~1.6 px remaining width)',
      (tester) async {
        tester.view.physicalSize = const Size(390, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final repository = TestChatbotRepository();
        await tester.pumpWidget(
          MaterialApp(
            home: ChatbotFigmaScreen(
              repository: repository,
              isSimulatedSource: false,
              singleConversationMode: true,
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);

        // Mở cả FAQ inline panel để kiểm tra trạng thái phức tạp nhất khi co giãn viewport
        await tester.tap(
          find.byKey(const Key('chatbot_faq_chip_faq_assistant_scope')),
        );
        await tester.pumpAndSettle();
        await tester.ensureVisible(toggleFaqButton);
        await tester.tap(toggleFaqButton);
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('chatbot_inline_faq_panel')), findsOneWidget);

        // Mô phỏng Chrome DevTools kéo thanh splitter qua các kích thước hẹp đột ngột
        // (bao gồm mốc 87.6 px vốn khiến vùng nội dung sau 86 px padding chỉ còn ~1.6 px)
        for (final size in const <Size>[
          Size(1280, 800),
          Size(390, 800),
          Size(360, 800),
          Size(320, 568),
          Size(240, 500),
          Size(160, 400),
          Size(87.6, 400),
          Size(65.6, 300),
          Size(44, 150),
          Size(390, 800),
        ]) {
          tester.view.physicalSize = size;
          await tester.pump();
          expect(
            tester.takeException(),
            isNull,
            reason: 'Không được overflow ở kích thước viewport $size',
          );
        }

        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      },
    );
  });
}
