import 'package:flutter/widgets.dart';

import 'data/course_lookup_repository.dart';

/// Cấp repository F03 cho các màn hình bên dưới, không phụ thuộc vào main.dart.
/// Trong app thực: bọc SmartCourseApp bằng Scope với repository Serverpod.
/// Trong các bài test Figma hiện có: không có Scope => vẫn dùng demo.
class CourseLookupRepositoryScope extends InheritedWidget {
  const CourseLookupRepositoryScope({
    super.key,
    required this.repository,
    required super.child,
  });

  final CourseLookupRepository repository;

  static CourseLookupRepository? maybeOf(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<CourseLookupRepositoryScope>()
      ?.repository;

  @override
  bool updateShouldNotify(CourseLookupRepositoryScope oldWidget) =>
      !identical(repository, oldWidget.repository);
}
