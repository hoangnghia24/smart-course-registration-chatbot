import 'package:flutter/material.dart';

import 'data/course_management_repository_scope.dart';
import 'presentation/course_management_screen.dart';

/// F06: khởi động màn hình từ AdminDashboard và tái sử dụng scope có sẵn.
class CourseManagementQuickAccess {
  const CourseManagementQuickAccess._();

  static void open(BuildContext context) {
    final repository = CourseManagementRepositoryScope.maybeOf(context);
    if (repository == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Chức năng quản lý môn học chưa được cấu hình.'),
        ),
      );
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CourseManagementScreen(repository: repository),
      ),
    );
  }
}
