import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_course_registration_chatbot_flutter/features/course_lookup/course_lookup_screen.dart';
import 'package:smart_course_registration_chatbot_flutter/features/course_lookup/data/course_lookup_repository.dart';

class _FailingRepository implements CourseLookupRepository {
  @override
  Future<List<CourseInfo>> lookup({
    required String query,
    required CourseLookupFilter filter,
  }) async => throw StateError('Lỗi API giả lập trong test');
}

void main() {
  Future<void> pumpScreen(WidgetTester tester, {CourseLookupRepository? repo}) async {
    await tester.pumpWidget(MaterialApp(
      home: CourseLookupScreen(repository: repo),
    ));
    await tester.pumpAndSettle();
  }

  /// Đợi cả debounce tìm kiếm (250ms) và độ trễ repository mẫu (160ms).
  /// pumpAndSettle() đơn lẻ có thể kết thúc trước khi Timer debounce chạy.
  Future<void> enterSearchAndWait(WidgetTester tester, String keyword) async {
    await tester.enterText(
      find.byKey(const ValueKey('course-search')),
      keyword,
    );
    await tester.pump(const Duration(milliseconds: 260)); // Debounce: 250ms
    await tester.pump(const Duration(milliseconds: 170)); // Repository: 160ms
    await tester.pumpAndSettle();
  }

  testWidgets('F03 hiển thị 2 học phần mẫu từ Figma và nhãn minh họa', (tester) async {
    await pumpScreen(tester);
    expect(find.text('Tìm kiếm học phần'), findsOneWidget);
    expect(find.text('Lập trình di động'), findsOneWidget);
    expect(find.text('Lập trình hướng đối tượng'), findsOneWidget);
    expect(find.text('2 học phần'), findsOneWidget);
    expect(find.byKey(const ValueKey('course-demo-label')), findsOneWidget);
  });

  testWidgets('lọc đúng ngành chỉ còn 1 học phần', (tester) async {
    await pumpScreen(tester);
    await tester.tap(find.byKey(const ValueKey('course-filter-majorOnly')));
    await tester.pumpAndSettle();
    expect(find.text('1 học phần'), findsOneWidget);
    expect(find.text('Lập trình di động'), findsOneWidget);
    expect(find.text('Lập trình hướng đối tượng'), findsNothing);
  });

  testWidgets('lọc 3 tín chỉ cho ra các học phần có 3 TC', (tester) async {
    await pumpScreen(tester);
    await tester.tap(find.byKey(const ValueKey('course-filter-threeCredits')));
    await tester.pumpAndSettle();
    expect(find.text('2 học phần'), findsOneWidget);
  });

  testWidgets('tìm kiếm không dấu theo tên môn', (tester) async {
    await pumpScreen(tester);
    await enterSearchAndWait(tester, 'huong doi tuong');
    expect(find.text('1 học phần'), findsOneWidget);
    expect(find.text('Lập trình hướng đối tượng'), findsOneWidget);
    expect(find.text('Lập trình di động'), findsNothing);
  });

  testWidgets('tìm theo mã học phần', (tester) async {
    await pumpScreen(tester);
    await enterSearchAndWait(tester, 'MOPR331279');
    expect(find.text('1 học phần'), findsOneWidget);
    expect(find.text('Lập trình di động'), findsOneWidget);
  });

  testWidgets('không có kết quả hiện empty, xóa tìm kiếm khôi phục', (tester) async {
    await pumpScreen(tester);
    await enterSearchAndWait(tester, 'MON-KHONG-TON-TAI');
    expect(find.byKey(const ValueKey('course-empty')), findsOneWidget);
    await tester.tap(find.text('Xóa tìm kiếm'));
    await tester.pumpAndSettle();
    expect(find.text('2 học phần'), findsOneWidget);
  });

  testWidgets('khi repository lỗi hiển thị error và nút thử lại', (tester) async {
    await pumpScreen(tester, repo: _FailingRepository());
    expect(find.byKey(const ValueKey('course-error')), findsOneWidget);
    expect(find.text('Thử lại'), findsOneWidget);
  });

  testWidgets('nút xem lớp và đăng ký không ghi danh thật', (tester) async {
    await pumpScreen(tester);
    await tester.ensureVisible(find.byKey(const ValueKey('course-register-preview')));
    await tester.tap(find.byKey(const ValueKey('course-register-preview')));
    await tester.pump();
    expect(find.textContaining('Đây là dữ liệu minh họa'), findsOneWidget);
  });

  testWidgets('tiên quyết không bịa quy định hay dữ liệu API', (tester) async {
    await pumpScreen(tester);
    await tester.ensureVisible(find.byKey(const ValueKey('course-prerequisite-shortcut')));
    await tester.tap(find.byKey(const ValueKey('course-prerequisite-shortcut')));
    await tester.pumpAndSettle();
    expect(find.textContaining('Chưa có dữ liệu hoặc quy định học vụ'), findsOneWidget);
  });

  testWidgets('nút menu quay về khi được mở từ Dashboard', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Builder(builder: (context) => Scaffold(
        body: TextButton(
          onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(
            builder: (_) => const CourseLookupScreen(),
          )),
          child: const Text('Mở F03'),
        ),
      )),
    ));
    await tester.tap(find.text('Mở F03'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('course-back')));
    await tester.pumpAndSettle();
    expect(find.text('Mở F03'), findsOneWidget);
  });

  testWidgets('hiển thị trên khung mobile 320px không overflow', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await pumpScreen(tester);
    expect(tester.takeException(), isNull);
    expect(find.byKey(const ValueKey('course-search')), findsOneWidget);
  });
}
