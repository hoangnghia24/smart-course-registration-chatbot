import 'package:flutter/widgets.dart';
import 'data/academic_progress_repository.dart';

/// Dependency injection tương tự F04, sử dụng chung Serverpod Client đã login.
class AcademicProgressRepositoryScope extends InheritedWidget {
  const AcademicProgressRepositoryScope({
    super.key,
    required this.repository,
    required super.child,
  });

  final AcademicProgressRepository repository;

  static AcademicProgressRepository? maybeOf(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<AcademicProgressRepositoryScope>()
      ?.repository;

  @override
  bool updateShouldNotify(AcademicProgressRepositoryScope oldWidget) =>
      !identical(repository, oldWidget.repository);
}
