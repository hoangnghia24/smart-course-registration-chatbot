import 'package:flutter/widgets.dart';
import 'data/recommendation_repository.dart';

/// Repository injection: một lần bọc bên ngoài SmartCourseApp.
class RecommendationRepositoryScope extends InheritedWidget {
  const RecommendationRepositoryScope({
    super.key,
    required this.repository,
    required super.child,
  });

  final RecommendationRepository repository;

  static RecommendationRepository? maybeOf(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<RecommendationRepositoryScope>()
      ?.repository;

  @override
  bool updateShouldNotify(RecommendationRepositoryScope oldWidget) =>
      !identical(repository, oldWidget.repository);
}
