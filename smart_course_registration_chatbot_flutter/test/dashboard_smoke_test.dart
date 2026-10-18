import 'package:flutter_test/flutter_test.dart';
import 'package:smart_course_registration_chatbot_flutter/features/admin/admin_dashboard.dart';
import 'package:smart_course_registration_chatbot_flutter/features/lecturer/lecturer_dashboard.dart';
import 'package:smart_course_registration_chatbot_flutter/features/student/student_dashboard.dart';

import 'package:flutter/material.dart';

import 'package:smart_course_registration_chatbot_flutter/dev/week5_dashboard_preview.dart';

void main() {
  testWidgets('Student dashboard renders academic profile and GPA', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(home: const StudentDashboard()));

    expect(find.text('Nguyễn Minh Anh'), findsWidgets);
    expect(find.text('GPA tích lũy'), findsOneWidget);
    expect(find.text('3.42'), findsOneWidget);
    expect(find.text('Tiến độ chương trình đào tạo'), findsOneWidget);
  });

  testWidgets('Lecturer dashboard renders class statistics and schedule', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(home: const LecturerDashboard()));

    expect(find.text('Trần Minh Khôi'), findsWidgets);
    expect(find.text('Tổng quan lớp học phần'), findsOneWidget);
    expect(find.text('Lịch giảng dạy'), findsOneWidget);
    expect(find.textContaining('Lập trình Web'), findsOneWidget);
  });

  testWidgets('Admin dashboard renders system management sections', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(home: const AdminDashboard()));

    expect(find.text('Lê Thanh Hùng'), findsWidgets);
    expect(find.text('Chỉ số hệ thống'), findsOneWidget);
    expect(find.text('Duyệt lớp học phần'), findsOneWidget);
    expect(find.text('Quản lý tài khoản'), findsOneWidget);
  });

  testWidgets('Preview switches between the three roles', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const Week5DashboardPreviewApp());
    expect(find.text('Nguyễn Minh Anh'), findsWidgets);

    await tester.tap(find.text('Giảng viên'));
    await tester.pumpAndSettle();
    expect(find.text('Trần Minh Khôi'), findsWidgets);

    await tester.tap(find.text('Admin'));
    await tester.pumpAndSettle();
    expect(find.text('Lê Thanh Hùng'), findsWidgets);
  });
}
