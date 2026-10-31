import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_course_registration_chatbot_flutter/features/chat/chatbot_figma_screen.dart';

void main() {
  Future<void> loadScreen(WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: ChatbotFigmaScreen()));
  }

  testWidgets('hiện tiêu đề và cảnh báo bản mẫu', (tester) async {
    await loadScreen(tester);
    expect(find.text('Trợ lý AI Đăng ký'), findsOneWidget);
    expect(find.text('Bản mẫu · Chưa kết nối AI'), findsOneWidget);
    expect(find.text('NỘI DUNG MINH HỌA · CHƯA KẾT NỐI AI'), findsOneWidget);
  });

  testWidgets('có đề xuất môn học và thông tin minh họa', (tester) async {
    await loadScreen(tester);
    expect(find.byKey(const Key('sample_course_card')), findsOneWidget);
    expect(find.text('Lập trình Di động'), findsWidgets);
    expect(find.text('3 TC'), findsOneWidget);
  });

  testWidgets('nhấn gợi ý sẽ điền câu hỏi, không gọi API', (tester) async {
    await loadScreen(tester);
    await tester.tap(find.text('Gợi ý môn chuyên ngành cho mình'));
    await tester.pump();
    final field = tester.widget<TextField>(
      find.byKey(const Key('chatbot_question_input')),
    );
    expect(field.controller!.text, 'Gợi ý môn chuyên ngành cho mình');
  });

  testWidgets('gửi ô trống không sinh nội dung', (tester) async {
    await loadScreen(tester);
    await tester.tap(find.byKey(const Key('chatbot_send_button')));
    await tester.pump();
    expect(find.byKey(const Key('no_evidence_message')), findsNothing);
  });

  testWidgets('gửi câu hỏi hiển thị thiếu căn cứ, không giả lập câu trả lời', (
    tester,
  ) async {
    await loadScreen(tester);
    await tester.enterText(
      find.byKey(const Key('chatbot_question_input')),
      'Học phần này còn chỗ không?',
    );
    await tester.tap(find.byKey(const Key('chatbot_send_button')));
    await tester.pump();
    expect(find.text('Học phần này còn chỗ không?'), findsOneWidget);
    expect(find.byKey(const Key('no_evidence_message')), findsOneWidget);
  });

  testWidgets('trạng thái đang tải', (tester) async {
    await loadScreen(tester);
    await tester.tap(find.byKey(const Key('chatbot_state_menu')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Đang tải').last);
    await tester.pump();
    expect(find.textContaining('Đang tải (mô phỏng'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('trạng thái câu trả lời có nguồn minh họa', (tester) async {
    await loadScreen(tester);
    await tester.tap(find.byKey(const Key('chatbot_state_menu')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Có nguồn minh họa').last);
    await tester.pump();
    expect(find.byKey(const Key('sourced_sample_answer')), findsOneWidget);
    expect(find.text('Nguồn mẫu · CHƯA XÁC THỰC'), findsOneWidget);
  });

  testWidgets('trạng thái timeout', (tester) async {
    await loadScreen(tester);
    await tester.tap(find.byKey(const Key('chatbot_state_menu')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Hết thời gian chờ').last);
    await tester.pump();
    expect(find.byKey(const Key('timeout_message')), findsOneWidget);
  });

  testWidgets('trạng thái mất mạng', (tester) async {
    await loadScreen(tester);
    await tester.tap(find.byKey(const Key('chatbot_state_menu')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mất mạng').last);
    await tester.pump();
    expect(find.byKey(const Key('offline_message')), findsOneWidget);
  });

  testWidgets('ấn đăng ký không thực hiện ghi danh', (tester) async {
    await loadScreen(tester);
    await tester.ensureVisible(find.byKey(const Key('sample_register_button')));
    await tester.tap(find.byKey(const Key('sample_register_button')));
    await tester.pump();
    expect(find.textContaining('Chatbot không đăng ký học phần'), findsOneWidget);
  });

  testWidgets('giao diện có thể cuộn trên màn hình nhỏ', (tester) async {
    tester.view.physicalSize = const Size(360, 740);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await loadScreen(tester);
    expect(find.byKey(const Key('chatbot_conversation_list')), findsOneWidget);
    expect(find.byKey(const Key('chatbot_question_input')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
