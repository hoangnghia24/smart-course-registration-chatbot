import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/dashboard_widgets.dart';
import 'curriculum_lookup_repository_scope.dart';
import 'curriculum_lookup_screen.dart';

/// Thẻ F04 có thể gắn vào StudentDashboard mà không phá luồng F03.
class CurriculumLookupQuickAccess extends StatelessWidget {
  const CurriculumLookupQuickAccess({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = CurriculumLookupRepositoryScope.maybeOf(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: FeatureCard(
        title: 'Chương trình đào tạo',
        subtitle: 'Xem môn học theo CTĐT và phiên bản được gán',
        icon: Icons.account_tree_outlined,
        iconColor: AppColors.primary,
        iconBackground: AppColors.blueSoft,
        onTap: () {
          if (repository == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Chức năng F04 chưa được kết nối Serverpod.'),
              ),
            );
            return;
          }
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => CurriculumLookupScreen(repository: repository),
            ),
          );
        },
      ),
    );
  }
}
