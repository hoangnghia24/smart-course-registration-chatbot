import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_course_registration_chatbot_flutter/core/widgets/shared_app_header.dart';
import 'package:smart_course_registration_chatbot_flutter/features/academic_progress/academic_progress_screen.dart';
import 'package:smart_course_registration_chatbot_flutter/features/academic_progress/data/academic_progress_repository.dart';

class _FakeRepository implements AcademicProgressRepository {
  _FakeRepository(this.call);
  final Future<AcademicProgressDetails?> Function() call;
  int count = 0;

  @override
  Future<AcademicProgressDetails?> getMyProgress() {
    count++;
    return call();
  }
}

// Dữ liệu chỉ trong TEST, không được đưa vào luồng chạy thật.
const _data = AcademicProgressDetails(
  totalCredits: 150,
  earnedCredits: 86,
  remainingCredits: 64,
  creditStatus: 'AVAILABLE',
  gpa: null,
  gpaStatus: 'POLICY_PENDING',
  courses: [
    AcademicCourseProgress(
      code: 'CS101',
      name: 'Lập trình hướng đối tượng',
      credits: 3,
      semester: 1,
      isRequired: true,
      groupCode: 'CSN',
      groupName: 'Cơ sở ngành',
      groupOrder: 1,
      itemOrder: 1,
      status: 'PASSED',
      score: 9,
      scoreStatus: 'AVAILABLE',
    ),
    AcademicCourseProgress(
      code: 'CS102',
      name: 'Toán rời rạc',
      credits: 3,
      semester: 2,
      isRequired: true,
      groupCode: 'CSN',
      groupName: 'Cơ sở ngành',
      groupOrder: 1,
      itemOrder: 2,
      status: 'FAILED',
      score: null,
      scoreStatus: 'NOT_PUBLISHED',
    ),
    AcademicCourseProgress(
      code: 'CS103',
      name: 'Hệ quản trị CSDL',
      credits: 3,
      semester: 3,
      isRequired: true,
      groupCode: 'CN',
      groupName: 'Chuyên ngành',
      groupOrder: 2,
      itemOrder: 1,
      status: 'IN_PROGRESS',
      score: null,
      scoreStatus: 'NO_DATA',
    ),
    AcademicCourseProgress(
      code: 'CS104',
      name: 'Bảo mật mạng',
      credits: 3,
      semester: 4,
      isRequired: false,
      groupCode: 'CN',
      groupName: 'Chuyên ngành',
      groupOrder: 2,
      itemOrder: 2,
      status: 'NOT_STARTED',
      score: null,
      scoreStatus: 'POLICY_PENDING',
    ),
  ],
);

Future<void> _show(WidgetTester tester, _FakeRepository repository) async {
  await tester.pumpWidget(
    MaterialApp(
      home: AcademicProgressScreen(repository: repository),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _scrollTo(
  WidgetTester tester,
  Finder target,
) async {
  await tester.scrollUntilVisible(
    target,
    190,
    scrollable: find
        .descendant(
          of: find.byKey(const ValueKey('f23-scroll-view')),
          matching: find.byType(Scrollable),
        )
        .first,
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('F23 sử dụng SharedAppHeader dùng chung', (tester) async {
    await _show(tester, _FakeRepository(() async => _data));
    expect(find.byType(SharedAppHeader), findsOneWidget);
    expect(find.byKey(const ValueKey('f23-back')), findsOneWidget);
    expect(find.text('KẾT QUẢ HỌC TẬP'), findsOneWidget);
  });

  testWidgets('F23 hiển thị tín chỉ thực và GPA đang chờ quy chế', (
    tester,
  ) async {
    await _show(tester, _FakeRepository(() async => _data));
    expect(find.text('Bảng điểm học tập'), findsOneWidget);
    expect(find.byKey(const ValueKey('f23-gpa')), findsOneWidget);
    expect(find.byKey(const ValueKey('f23-credits')), findsOneWidget);
    expect(find.text('Chờ quy chế tính GPA'), findsOneWidget);
    expect(find.text('86'), findsOneWidget);
    expect(find.text('Trong 150 tín chỉ CTĐT'), findsOneWidget);
    expect(find.text('3.24'), findsNothing); // Không dùng số mẫu trong Figma.
  });

  testWidgets('F23 không bịa số tín chỉ khi backend trả null', (tester) async {
    final nullCredits = AcademicProgressDetails(
      totalCredits: null,
      earnedCredits: null,
      remainingCredits: null,
      creditStatus: 'POLICY_PENDING',
      gpa: null,
      gpaStatus: 'NO_DATA',
      courses: _data.courses,
    );
    await _show(tester, _FakeRepository(() async => nullCredits));
    expect(find.text('Tổng tín chỉ chưa xác định'), findsOneWidget);
    expect(find.text('Chưa có dữ liệu GPA'), findsOneWidget);
    expect(find.text('86'), findsNothing);
    expect(find.text('150'), findsNothing);
  });

  testWidgets('F23 hiển thị đầy đủ bốn trạng thái học phần', (tester) async {
    await _show(tester, _FakeRepository(() async => _data));
    expect(find.text('Đã đạt (1)'), findsOneWidget);
    expect(find.text('Chưa đạt (1)'), findsOneWidget);
    expect(find.text('Đang học (1)'), findsOneWidget);
    expect(find.text('Chưa học (1)'), findsOneWidget);
    await _scrollTo(tester, find.byKey(const ValueKey('f23-course-CS104')));
    expect(find.byKey(const ValueKey('f23-course-CS104')), findsOneWidget);
  });

  testWidgets('F23 lọc đúng môn chưa đạt', (tester) async {
    await _show(tester, _FakeRepository(() async => _data));
    await _scrollTo(tester, find.byKey(const ValueKey('f23-filter-failed')));
    await tester.tap(find.byKey(const ValueKey('f23-filter-failed')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('f23-course-CS102')), findsOneWidget);
    expect(find.byKey(const ValueKey('f23-course-CS101')), findsNothing);
  });

  testWidgets('F23 không hiển thị điểm khi chưa công bố', (tester) async {
    await _show(tester, _FakeRepository(() async => _data));
    await _scrollTo(tester, find.byKey(const ValueKey('f23-course-CS102')));
    expect(find.byKey(const ValueKey('f23-score-CS102')), findsOneWidget);
    expect(find.text('Chưa công bố'), findsOneWidget);
  });

  testWidgets('F23 có trạng thái đang tải', (tester) async {
    final completer = Completer<AcademicProgressDetails?>();
    await tester.pumpWidget(
      MaterialApp(
        home: AcademicProgressScreen(
          repository: _FakeRepository(() => completer.future),
        ),
      ),
    );
    await tester.pump();
    expect(find.byKey(const ValueKey('f23-loading')), findsOneWidget);
    completer.complete(_data);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('f23-credits')), findsOneWidget);
  });

  testWidgets('F23 xử lý sinh viên chưa có dữ liệu tiến độ', (tester) async {
    await _show(tester, _FakeRepository(() async => null));
    expect(find.byKey(const ValueKey('f23-unavailable')), findsOneWidget);
  });

  testWidgets('F23 xử lý sai quyền', (tester) async {
    await _show(
      tester,
      _FakeRepository(() async => throw Exception('FORBIDDEN')),
    );
    expect(find.byKey(const ValueKey('f23-error')), findsOneWidget);
    expect(find.textContaining('không có quyền'), findsOneWidget);
  });

  testWidgets('F23 có thể thử lại sau lỗi mạng', (tester) async {
    var fail = true;
    final repo = _FakeRepository(() async {
      if (fail) throw Exception('network error');
      return _data;
    });
    await _show(tester, repo);
    expect(find.byKey(const ValueKey('f23-error')), findsOneWidget);
    fail = false;
    await tester.tap(find.text('Thử lại'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('f23-credits')), findsOneWidget);
    expect(repo.count, 2);
  });

  testWidgets('F23 hiển thị đủ năm bộ lọc trên màn hình 390px', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await _show(tester, _FakeRepository(() async => _data));

    final first = find.byKey(const ValueKey('f23-filter-all'));
    final last = find.byKey(const ValueKey('f23-filter-notStarted'));
    expect(find.byKey(const ValueKey('f23-status-filters')), findsOneWidget);
    for (final name in [
      'all',
      'passed',
      'failed',
      'inProgress',
      'notStarted',
    ]) {
      final rect = tester.getRect(find.byKey(ValueKey('f23-filter-$name')));
      expect(rect.left, greaterThanOrEqualTo(0));
      expect(rect.right, lessThanOrEqualTo(390));
    }
    // Hai trạng thái mở rộng xuống hàng thay vì bị cắt ở mép phải.
    expect(
      tester.getTopLeft(last).dy,
      greaterThan(tester.getTopLeft(first).dy),
    );
  });

  testWidgets('F23 có vạch trạng thái xanh và đỏ theo kết quả API', (
    tester,
  ) async {
    await _show(tester, _FakeRepository(() async => _data));
    final passed = find.byKey(const ValueKey('f23-status-stripe-CS101'));
    final failed = find.byKey(const ValueKey('f23-status-stripe-CS102'));
    await _scrollTo(tester, passed);
    expect(tester.widget<ColoredBox>(passed).color, const Color(0xFF16865B));
    await _scrollTo(tester, failed);
    expect(tester.widget<ColoredBox>(failed).color, const Color(0xFFD93448));
  });
}
