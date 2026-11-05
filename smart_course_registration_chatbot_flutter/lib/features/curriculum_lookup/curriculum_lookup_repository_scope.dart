import 'package:flutter/widgets.dart';

import 'data/curriculum_lookup_repository.dart';

/// Dependency injection đơn giản, cùng cách với CourseLookupRepositoryScope (F03).
class CurriculumLookupRepositoryScope extends InheritedWidget {
  const CurriculumLookupRepositoryScope({
    super.key,
    required this.repository,
    required super.child,
  });

  final CurriculumLookupRepository repository;

  static CurriculumLookupRepository? maybeOf(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<CurriculumLookupRepositoryScope>()
      ?.repository;

  @override
  bool updateShouldNotify(CurriculumLookupRepositoryScope oldWidget) =>
      !identical(repository, oldWidget.repository);
}
