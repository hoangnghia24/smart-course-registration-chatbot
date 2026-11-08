import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_course_registration_chatbot_flutter/core/widgets/shared_app_header.dart';
import 'package:smart_course_registration_chatbot_flutter/features/admin/course_management/data/course_management_repository.dart';
import 'package:smart_course_registration_chatbot_flutter/features/admin/course_management/domain/admin_course.dart';
import 'package:smart_course_registration_chatbot_flutter/features/admin/course_management/presentation/course_management_screen.dart';
import 'package:smart_course_registration_chatbot_flutter/features/admin/course_management/presentation/course_detail_screen.dart';
import 'package:smart_course_registration_chatbot_flutter/features/admin/course_management/presentation/course_form_screen.dart';

const _sample = AdminCourse(
  id: 1,
  code: 'DABA230101',
  name: 'Cơ sở dữ liệu',
  credits: 3,
  description: 'Kiến thức về hệ quản trị CSDL.',
);

class _FakeCourseRepository implements CourseManagementRepository {
  @override
  Future<List<AdminCourse>> getPage({
    required int page,
    int pageSize = 20,
  }) async => [_sample];
  @override
  Future<List<AdminCourse>> search({
    required String query,
    int page = 1,
    int pageSize = 20,
  }) async => [_sample];
  @override
  Future<AdminCourse> getById(int courseId) async => _sample;
  @override
  Future<AdminCourse> create(AdminCourse course) async => course;
  @override
  Future<AdminCourse> update(AdminCourse course) async => course;
  @override
  Future<bool> deactivate(int courseId) async => true;
}

void main() {
  testWidgets('F06 danh sách sử dụng SharedAppHeader và bộ lọc trạng thái', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        home: CourseManagementScreen(repository: _FakeCourseRepository()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(SharedAppHeader), findsOneWidget);
    expect(find.text('Danh sách môn học'), findsOneWidget);
    expect(find.byKey(const ValueKey('f06-filter-active')), findsOneWidget);
    expect(find.byKey(const ValueKey('f06-filter-hidden')), findsOneWidget);
    expect(find.textContaining('DABA230101'), findsOneWidget);
  });

  testWidgets('F06 chi tiết dùng cùng SharedAppHeader, không bịa khoa/CTĐT', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: CourseDetailScreen(
          repository: _FakeCourseRepository(),
          course: _sample,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(SharedAppHeader), findsOneWidget);
    expect(find.text('Cơ sở dữ liệu'), findsOneWidget);
    expect(find.text('Chưa có dữ liệu API'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Chờ API F07'),
      150,
      scrollable: find
          .descendant(
            of: find.byKey(const ValueKey('f06-detail-scroll')),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    expect(find.text('Chờ API F07'), findsOneWidget);
  });

  testWidgets('F06 form dùng SharedAppHeader và ghi rõ khoa chờ API', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: CourseFormScreen(repository: _FakeCourseRepository())),
    );
    await tester.pumpAndSettle();
    expect(find.byType(SharedAppHeader), findsOneWidget);
    expect(find.text('Thêm môn học'), findsNWidgets(2));
    await tester.scrollUntilVisible(
      find.text('Chưa có trong API F06'),
      150,
      scrollable: find
          .descendant(
            of: find.byKey(const ValueKey('f06-form-scroll')),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    expect(find.text('Chưa có trong API F06'), findsOneWidget);
    expect(find.byKey(const ValueKey('f06-form-save')), findsOneWidget);
  });
}
