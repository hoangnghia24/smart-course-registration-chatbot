import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_course_registration_chatbot_flutter/features/admin/course_management/data/course_management_repository.dart';
import 'package:smart_course_registration_chatbot_flutter/features/admin/course_management/domain/admin_course.dart';
import 'package:smart_course_registration_chatbot_flutter/features/admin/course_management/presentation/course_form_screen.dart';

const sample = AdminCourse(id: 9, code: 'CS101', name: 'Lập trình', credits: 3);

class _Repo implements CourseManagementRepository {
  Future<AdminCourse> Function(AdminCourse)? onCreate;
  Future<AdminCourse> Function(AdminCourse)? onUpdate;
  AdminCourse? created;
  AdminCourse? updated;
  int calls = 0;

  @override
  Future<AdminCourse> create(AdminCourse course) async {
    created = course;
    calls++;
    return onCreate != null ? await onCreate!(course) : course;
  }

  @override
  Future<AdminCourse> update(AdminCourse course) async {
    updated = course;
    calls++;
    return onUpdate != null ? await onUpdate!(course) : course;
  }

  @override
  Future<bool> deactivate(int courseId) async => true;
  @override
  Future<AdminCourse> getById(int courseId) async => sample;
  @override
  Future<List<AdminCourse>> getPage({
    required int page,
    int pageSize = 20,
  }) async => [sample];
  @override
  Future<List<AdminCourse>> search({
    required String query,
    int page = 1,
    int pageSize = 20,
  }) async => [sample];
}

Future<void> showForm(
  WidgetTester tester,
  CourseManagementRepository repo, {
  AdminCourse? course,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: CourseFormScreen(repository: repo, course: course),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('F06 bắt buộc mã, tên, tín chỉ trước khi gọi API', (
    tester,
  ) async {
    final repo = _Repo();
    await showForm(tester, repo);
    await tester.tap(find.byKey(const ValueKey('f06-form-save')));
    await tester.pumpAndSettle();
    expect(find.text('Vui lòng nhập mã môn học'), findsOneWidget);
    expect(find.text('Vui lòng nhập tên môn học'), findsOneWidget);
    expect(repo.calls, 0);
  });

  testWidgets('F06 tạo môn chỉ gọi create', (tester) async {
    final repo = _Repo();
    await showForm(tester, repo);
    await tester.enterText(
      find.byKey(const ValueKey('f06-form-code')),
      'CS201',
    );
    await tester.enterText(
      find.byKey(const ValueKey('f06-form-name')),
      'Cấu trúc dữ liệu',
    );
    await tester.enterText(find.byKey(const ValueKey('f06-form-credits')), '3');
    await tester.tap(find.byKey(const ValueKey('f06-form-save')));
    await tester.pumpAndSettle();
    expect(repo.calls, 1);
    expect(repo.created?.code, 'CS201');
    expect(repo.created?.id, isNull);
  });

  testWidgets('F06 sửa môn giữ ID và trạng thái hoạt động', (tester) async {
    final repo = _Repo();
    await showForm(tester, repo, course: sample);
    await tester.enterText(
      find.byKey(const ValueKey('f06-form-name')),
      'Lập trình nâng cao',
    );
    await tester.tap(find.byKey(const ValueKey('f06-form-save')));
    await tester.pumpAndSettle();
    expect(repo.updated?.id, 9);
    expect(repo.updated?.isActive, isTrue);
    expect(repo.updated?.name, 'Lập trình nâng cao');
  });

  testWidgets('F06 có thể yêu cầu kích hoạt lại môn không hoạt động', (
    tester,
  ) async {
    final repo = _Repo();
    const inactive = AdminCourse(
      id: 11,
      code: 'CS102',
      name: 'Môn cũ',
      credits: 2,
      isActive: false,
    );
    await showForm(tester, repo, course: inactive);
    final reactivate = find.byKey(const ValueKey('f06-reactivate'));
    await tester.scrollUntilVisible(
      reactivate,
      140,
      scrollable: find
          .descendant(
            of: find.byKey(const ValueKey('f06-form-scroll')),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('f06-reactivate')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('f06-form-save')));
    await tester.pumpAndSettle();
    expect(repo.updated?.isActive, isTrue);
  });

  testWidgets('F06 khi lỗi lưu vẫn giữ form cho người dùng', (tester) async {
    final repo = _Repo()..onCreate = (c) async => throw StateError('error');
    await showForm(tester, repo);
    await tester.enterText(
      find.byKey(const ValueKey('f06-form-code')),
      'CS201',
    );
    await tester.enterText(
      find.byKey(const ValueKey('f06-form-name')),
      'Cấu trúc dữ liệu',
    );
    await tester.enterText(find.byKey(const ValueKey('f06-form-credits')), '3');
    await tester.tap(find.byKey(const ValueKey('f06-form-save')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('f06-form-error')), findsOneWidget);
    expect(find.byKey(const ValueKey('f06-form-code')), findsOneWidget);
  });

  testWidgets('F06 không gửi request trùng khi đang lưu', (tester) async {
    final pending = Completer<AdminCourse>();
    final repo = _Repo()..onCreate = (c) => pending.future;
    await showForm(tester, repo);
    await tester.enterText(
      find.byKey(const ValueKey('f06-form-code')),
      'CS201',
    );
    await tester.enterText(
      find.byKey(const ValueKey('f06-form-name')),
      'Cấu trúc dữ liệu',
    );
    await tester.enterText(find.byKey(const ValueKey('f06-form-credits')), '3');
    await tester.tap(find.byKey(const ValueKey('f06-form-save')));
    await tester.pump();
    expect(repo.calls, 1);
    expect(
      tester
          .widget<FilledButton>(find.byKey(const ValueKey('f06-form-save')))
          .onPressed,
      isNull,
    );
    pending.complete(sample);
    await tester.pumpAndSettle();
  });
}
