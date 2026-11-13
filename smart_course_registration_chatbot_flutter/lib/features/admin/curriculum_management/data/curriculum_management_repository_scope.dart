import 'package:flutter/widgets.dart';

import 'curriculum_management_repository.dart';

class CurriculumManagementRepositoryScope extends InheritedWidget {
  const CurriculumManagementRepositoryScope({
    super.key,
    required this.repository,
    required super.child,
  });

  final CurriculumManagementRepository repository;

  static CurriculumManagementRepository? maybeOf(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<CurriculumManagementRepositoryScope>()
      ?.repository;

  @override
  bool updateShouldNotify(CurriculumManagementRepositoryScope oldWidget) =>
      !identical(repository, oldWidget.repository);
}
