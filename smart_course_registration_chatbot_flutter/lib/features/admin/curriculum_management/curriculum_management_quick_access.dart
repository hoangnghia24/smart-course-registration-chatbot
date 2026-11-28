import 'package:flutter/material.dart';
import 'data/curriculum_management_repository_scope.dart';
import 'presentation/curriculum_management_screen.dart';

/// Safe entry point once a real F07 repository is registered.
/// Intentionally does not construct mock repositories in production.
abstract final class CurriculumManagementQuickAccess {
  static void open(BuildContext context) {
    final repository = CurriculumManagementRepositoryScope.maybeOf(context);
    if (repository == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('F07 đang chờ API quản lý chương trình đào tạo.'),
      ));
      return;
    }
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => CurriculumManagementScreen(repository: repository),
    ));
  }
}
