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
    ),
    CurriculumCourse(
      code: 'CS102',
      name: 'Cấu trúc dữ liệu',
      credits: 4,
      semester: 1,
      isRequired: false,
    ),
    CurriculumCourse(
      code: 'CS103',
      name: 'Cơ sở dữ liệu',
      credits: 3,
      semester: 2,
      isRequired: true,
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
    expect(find.text('Học kỳ 1'), findsOneWidget);
    expect(find.text('Nhập môn lập trình'), findsOneWidget);
    expect(find.textContaining('CS101 · 3 TC · Bắt buộc'), findsOneWidget);
    expect(find.byKey(const ValueKey('f04-progress-placeholder')),
        findsOneWidget);
    expect(find.text('Chưa có dữ liệu tiến độ học tập'), findsOneWidget);
    expect(find.textContaining('57%'), findsNothing);
  });

  testWidgets('F04 lọc đúng học phần bắt buộc và tự chọn', (tester) async {
    await _render(tester, _FakeRepository(() async => _testCurriculum));

    await tester.tap(find.text('Tự chọn'));
    await tester.pumpAndSettle();
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
