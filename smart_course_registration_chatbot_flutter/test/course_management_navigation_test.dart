import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_course_registration_chatbot_flutter/features/admin/course_management/course_management_quick_access.dart';
import 'package:smart_course_registration_chatbot_flutter/features/admin/course_management/data/course_management_repository.dart';
import 'package:smart_course_registration_chatbot_flutter/features/admin/course_management/data/course_management_repository_scope.dart';
import 'package:smart_course_registration_chatbot_flutter/features/admin/course_management/domain/admin_course.dart';

class _Repo implements CourseManagementRepository {
  @override
  Future<List<AdminCourse>> getPage({
    required int page,
    int pageSize = 20,
  }) async => [];
  @override
  Future<List<AdminCourse>> search({
    required String query,
    int page = 1,
    int pageSize = 20,
  }) async => [];
  @override
  Future<AdminCourse> getById(int courseId) => throw UnimplementedError();
  @override
  Future<AdminCourse> create(AdminCourse course) => throw UnimplementedError();
  @override
  Future<AdminCourse> update(AdminCourse course) => throw UnimplementedError();
  @override
  Future<bool> deactivate(int courseId) => throw UnimplementedError();
}

class _Launch extends StatelessWidget {
  const _Launch();
  @override
  Widget build(BuildContext context) => Scaffold(
    body: TextButton(
      onPressed: () => CourseManagementQuickAccess.open(context),
      child: const Text('Mở F06'),
    ),
  );
}

void main() {
  testWidgets('F06 không crash khi thiếu repository scope', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: _Launch()));
    await tester.tap(find.text('Mở F06'));
    await tester.pump();
    expect(
      find.text('Chức năng quản lý môn học chưa được cấu hình.'),
      findsOneWidget,
    );
  });

  testWidgets('F06 mở màn hình khi có scope', (tester) async {
    await tester.pumpWidget(
      CourseManagementRepositoryScope(
        repository: _Repo(),
        child: const MaterialApp(home: _Launch()),
      ),
    );
    await tester.tap(find.text('Mở F06'));
    await tester.pumpAndSettle();
    expect(find.text('Danh sách môn học'), findsOneWidget);
    expect(find.text('Chưa có môn học'), findsOneWidget);
  });
}
