import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_course_registration_chatbot_flutter/features/admin/course_management/data/course_management_repository.dart';
import 'package:smart_course_registration_chatbot_flutter/features/admin/course_management/domain/admin_course.dart';
import 'package:smart_course_registration_chatbot_flutter/features/admin/course_management/presentation/course_management_screen.dart';

const sample = AdminCourse(id: 9, code: 'CS101', name: 'Lập trình', credits: 3);

class _Repo implements CourseManagementRepository {
  Future<List<AdminCourse>> Function(int, String)? load;
  Future<bool> Function(int)? deactivateRpc;
  int pageCalls = 0;
  int searchCalls = 0;
  int deactivateCalls = 0;

  @override
  Future<List<AdminCourse>> getPage({required int page, int pageSize = 20}) {
    pageCalls++;
    return (load ?? (p, q) async => [sample])(page, '');
  }

  @override
  Future<List<AdminCourse>> search({
    required String query,
    int page = 1,
    int pageSize = 20,
  }) {
    searchCalls++;
    return (load ?? (p, q) async => [sample])(page, query);
  }

  @override
  Future<bool> deactivate(int courseId) {
    deactivateCalls++;
    return (deactivateRpc ?? (id) async => true)(courseId);
  }

  @override
  Future<AdminCourse> create(AdminCourse course) async => course;
  @override
  Future<AdminCourse> update(AdminCourse course) async => course;
  @override
  Future<AdminCourse> getById(int courseId) async => sample;
}

Future<void> showScreen(
  WidgetTester tester,
  CourseManagementRepository repo,
) async {
  await tester.pumpWidget(
    MaterialApp(home: CourseManagementScreen(repository: repo)),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('F06 hiển thị danh sách môn từ repository', (tester) async {
    final repo = _Repo();
    await showScreen(tester, repo);
    expect(find.textContaining('CS101'), findsOneWidget);
    expect(find.textContaining('3 tín chỉ'), findsOneWidget);
    expect(repo.pageCalls, 1);
  });

  testWidgets('F06 hiển thị danh sách rỗng', (tester) async {
    final repo = _Repo()..load = (p, q) async => [];
    await showScreen(tester, repo);
    expect(find.text('Chưa có môn học'), findsOneWidget);
  });

  testWidgets('F06 lỗi tải và thử lại', (tester) async {
    var fail = true;
    final repo = _Repo()
      ..load = (p, q) async {
        if (fail) throw StateError('network');
        return [sample];
      };
    await showScreen(tester, repo);
    expect(find.byKey(const ValueKey('f06-error')), findsOneWidget);
    fail = false;
    final retry = find.byKey(const ValueKey('f06-retry'));
    await tester.scrollUntilVisible(
      retry,
      140,
      scrollable: find
          .descendant(
            of: find.byKey(const ValueKey('f06-list-scroll')),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.pumpAndSettle();
    await tester.tap(retry);
    await tester.pumpAndSettle();
    expect(find.textContaining('CS101'), findsOneWidget);
  });

  testWidgets('F06 tìm kiếm chỉ gửi RPC khi có từ khóa', (tester) async {
    final repo = _Repo();
    await showScreen(tester, repo);
    await tester.enterText(
      find.byKey(const ValueKey('f06-search-field')),
      '  CS101  ',
    );
    await tester.tap(find.byKey(const ValueKey('f06-search-button')));
    await tester.pumpAndSettle();
    expect(repo.searchCalls, 1);
    await tester.tap(find.byKey(const ValueKey('f06-clear-search')));
    await tester.pumpAndSettle();
    expect(repo.pageCalls, 2);
    expect(repo.searchCalls, 1);
  });

  testWidgets('F06 không coi deactivate false là thành công', (tester) async {
    final repo = _Repo()..deactivateRpc = (id) async => false;
    await showScreen(tester, repo);
    await tester.tap(find.byKey(const ValueKey('f06-deactivate-9')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('f06-confirm-deactivate')));
    await tester.pumpAndSettle();
    expect(repo.deactivateCalls, 1);
    expect(find.textContaining('Không thể ngừng hoạt động'), findsOneWidget);
  });

  testWidgets('F06 giữ loading khi repository chưa trả', (tester) async {
    final response = Completer<List<AdminCourse>>();
    final repo = _Repo()..load = (p, q) => response.future;
    await tester.pumpWidget(
      MaterialApp(home: CourseManagementScreen(repository: repo)),
    );
    await tester.pump();
    expect(find.byKey(const ValueKey('f06-loading')), findsOneWidget);
    response.complete([sample]);
    await tester.pumpAndSettle();
    expect(find.textContaining('CS101'), findsOneWidget);
  });
}
