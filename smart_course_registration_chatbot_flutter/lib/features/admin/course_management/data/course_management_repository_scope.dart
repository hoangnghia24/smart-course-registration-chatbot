import 'package:flutter/widgets.dart';

import 'course_management_repository.dart';

/// Cùng pattern với các repository scope F04/F23.
class CourseManagementRepositoryScope extends InheritedWidget {
  final CourseManagementRepository repository;

  const CourseManagementRepositoryScope({
    super.key,
    required this.repository,
    required super.child,
  });

  static CourseManagementRepository? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<CourseManagementRepositoryScope>()
        ?.repository;
  }

  static CourseManagementRepository of(BuildContext context) {
    final value = maybeOf(context);
    if (value == null) {
      throw StateError('CourseManagementRepositoryScope chưa được cung cấp');
    }
    return value;
  }

  @override
  bool updateShouldNotify(
    covariant CourseManagementRepositoryScope oldWidget,
  ) => !identical(repository, oldWidget.repository);
}
