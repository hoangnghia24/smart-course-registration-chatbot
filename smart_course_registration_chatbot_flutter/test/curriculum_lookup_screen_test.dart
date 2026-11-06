import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_course_registration_chatbot_flutter/features/curriculum_lookup/curriculum_lookup_screen.dart';
import 'package:smart_course_registration_chatbot_flutter/features/curriculum_lookup/data/curriculum_lookup_repository.dart';

class _FakeRepository implements CurriculumLookupRepository {
  _FakeRepository(this.load);
  final Future<CurriculumDetails?> Function() load;
  int calls = 0;

  @override
  Future<CurriculumDetails?> getMyCurriculum() {
    calls++;
    return load();
  }
}

// Chỉ là dữ liệu test, KHÔNG được truyền vào ứng dụng chính.
const _testCurriculum = CurriculumDetails(
  code: 'CNTT',
  name: 'Công nghệ thông tin',
  majorCode: '7480201',
  versionCode: '2026',
  effectiveYear: 2026,
  versionStatus: 'published',
  items: [
    CurriculumCourse(
      code: 'CS101',
      name: 'Nhập môn lập trình',
      credits: 3,
      semester: 1,
      isRequired: true,
      groupCode: 'DC',
      groupName: 'Khối kiến thức đại cương',
      groupOrder: 1,
      itemOrder: 1,
    ),
    CurriculumCourse(
      code: 'CS102',
      name: 'Cấu trúc dữ liệu',
      credits: 4,
      semester: 1,
      isRequired: false,
      groupCode: 'CSN',
      groupName: 'Khối kiến thức cơ sở ngành',
      groupOrder: 2,
      itemOrder: 1,
    ),
    CurriculumCourse(
      code: 'CS103',
      name: 'Cơ sở dữ liệu',
      credits: 3,
      semester: 2,
      isRequired: true,
      groupCode: 'CSN',
      groupName: 'Khối kiến thức cơ sở ngành',
      groupOrder: 2,
      itemOrder: 2,
    ),
  ],
);

Future<void> _render(
  WidgetTester tester,
  CurriculumLookupRepository repo,
) async {
  await tester.pumpWidget(
    MaterialApp(
      home: CurriculumLookupScreen(repository: repo),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('F04 hiển thị CTĐT và học phần từ repository', (tester) async {
    await _render(tester, _FakeRepository(() async => _testCurriculum));

    expect(find.text('Công nghệ thông tin'), findsOneWidget);
    expect(find.text('Bản 2026'), findsOneWidget);
    expect(find.text('Khối kiến thức đại cương'), findsOneWidget);
    expect(find.text('Nhập môn lập trình'), findsOneWidget);
    expect(find.textContaining('CS101 · 3 TC · Bắt buộc · HK 1'), findsOneWidget);
    expect(find.byKey(const ValueKey('f04-progress-placeholder')),
        findsOneWidget);
    expect(find.text('Chưa có dữ liệu tiến độ học tập'), findsOneWidget);
    expect(find.textContaining('57%'), findsNothing);
  });

  testWidgets('F04 lọc đúng học phần bắt buộc và tự chọn', (tester) async {
    await _render(tester, _FakeRepository(() async => _testCurriculum));

    await tester.tap(find.text('Tự chọn'));
    await tester.pumpAndSettle();
    // Khối tự chọn phải tự mở khi là khối đầu tiên của bộ lọc.
    expect(find.byKey(const ValueKey('f04-group-group:CSN')), findsOneWidget);
    expect(find.text('Cấu trúc dữ liệu'), findsOneWidget);
    expect(find.text('Nhập môn lập trình'), findsNothing);
    expect(find.byKey(const ValueKey('f04-filter-bar')), findsOneWidget);

    await tester.tap(find.text('Bắt buộc'));
    await tester.pumpAndSettle();
    expect(find.text('Nhập môn lập trình'), findsOneWidget);
    expect(find.text('Cấu trúc dữ liệu'), findsNothing);
  });

  testWidgets('F04 có trạng thái loading', (tester) async {
    final completer = Completer<CurriculumDetails?>();
    await tester.pumpWidget(MaterialApp(
      home: CurriculumLookupScreen(
        repository: _FakeRepository(() => completer.future),
      ),
    ));
    await tester.pump();
    expect(find.byKey(const ValueKey('f04-loading')), findsOneWidget);
    completer.complete(_testCurriculum);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('f04-curriculum-name')),
        findsOneWidget);
  });

  testWidgets('F04 thông báo chưa gán CTĐT', (tester) async {
    await _render(tester, _FakeRepository(() async => null));
    expect(find.byKey(const ValueKey('f04-unassigned')), findsOneWidget);
  });

  testWidgets('F04 hiển thị CTĐT không có học phần', (tester) async {
    const emptyCurriculum = CurriculumDetails(
      code: 'CNTT',
      name: 'Công nghệ thông tin',
      majorCode: '7480201',
      versionCode: '2026',
      effectiveYear: 2026,
      versionStatus: 'published',
      items: [],
    );
    await _render(tester, _FakeRepository(() async => emptyCurriculum));
    expect(find.byKey(const ValueKey('f04-empty-items')), findsOneWidget);
  });

  testWidgets('F04 thông báo sai quyền', (tester) async {
    await _render(
      tester,
      _FakeRepository(() async => throw Exception('FORBIDDEN')),
    );
    expect(find.byKey(const ValueKey('f04-error')), findsOneWidget);
    expect(find.textContaining('không có quyền'), findsOneWidget);
    expect(find.text('Công nghệ thông tin'), findsNothing);
  });

  testWidgets('F04 nhóm theo khối kiến thức và không gộp theo học kỳ',
      (tester) async {
    await _render(tester, _FakeRepository(() async => _testCurriculum));
    expect(find.text('Khối kiến thức đại cương'), findsOneWidget);
    expect(find.byKey(const ValueKey('f04-group-group:DC')), findsOneWidget);
    // ListView chỉ dựng những mục đang gần vùng nhìn thấy; khối thứ hai
    // có thể chưa được dựng, nên cần cuộn tới nó trước khi tìm tên.
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('f04-group-group:CSN')),
      160,
      scrollable: find.byType(Scrollable).first,
      maxScrolls: 12,
    );
    await tester.pumpAndSettle();
    expect(find.text('Khối kiến thức cơ sở ngành'), findsOneWidget);
    expect(find.byKey(const ValueKey('f04-group-group:CSN')), findsOneWidget);
    await tester.tap(find.text('Khối kiến thức cơ sở ngành'));
    await tester.pumpAndSettle();
    expect(find.text('Cơ sở dữ liệu'), findsOneWidget);
  });

  testWidgets('F04 chưa có nhóm thì hiện chú thích không tự đoán nhóm',
      (tester) async {
    const noGroup = CurriculumDetails(
      code: 'CNTT',
      name: 'Công nghệ thông tin',
      majorCode: '7480201',
      versionCode: '2026',
      effectiveYear: 2026,
      versionStatus: 'published',
      items: [
        CurriculumCourse(
          code: 'CS999',
          name: 'Học phần chưa phân nhóm',
          credits: 2,
          semester: 3,
          isRequired: true,
        ),
      ],
    );
    await _render(tester, _FakeRepository(() async => noGroup));
    expect(find.text('Học kỳ 3 (chưa phân nhóm)'), findsOneWidget);
    expect(find.text('Học phần chưa phân nhóm'), findsOneWidget);
  });

  testWidgets('F04 lỗi mạng và thử lại thành công', (tester) async {
    var attempt = 0;
    final repo = _FakeRepository(() async {
      attempt++;
      if (attempt == 1) throw Exception('Network offline');
      return _testCurriculum;
    });
    await _render(tester, repo);
    expect(find.byKey(const ValueKey('f04-error')), findsOneWidget);
    await tester.tap(find.text('Thử lại'));
    await tester.pumpAndSettle();
    expect(find.text('Công nghệ thông tin'), findsOneWidget);
    expect(repo.calls, 2);
  });
}
