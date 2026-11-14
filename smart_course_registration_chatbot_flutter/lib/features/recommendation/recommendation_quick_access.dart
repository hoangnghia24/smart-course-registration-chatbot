import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/dashboard_widgets.dart';
import 'recommendation_repository_scope.dart';
import 'recommendation_screen.dart';

class RecommendationQuickAccess extends StatelessWidget {
  const RecommendationQuickAccess({
    super.key,
    this.studentName,
    this.studentCode,
    this.program,
  });

  final String? studentName;
  final String? studentCode;
  final String? program;

  @override
  Widget build(BuildContext context) {
    final repo = RecommendationRepositoryScope.maybeOf(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: FeatureCard(
        title: 'Lộ trình học tập',
        subtitle: 'Kế hoạch cá nhân và gợi ý học phần khi có dữ liệu',
        icon: Icons.auto_awesome_outlined,
        iconColor: AppColors.primary,
        iconBackground: AppColors.blueSoft,
        onTap: () {
          if (repo == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Chức năng F24/F27 chưa được kết nối repository.',
                ),
              ),
            );
            return;
          }
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => RecommendationScreen(
                repository: repo,
                studentDisplayName: [studentName, studentCode]
                    .whereType<String>()
                    .where((s) => s.trim().isNotEmpty)
                    .join(' - '),
                studentIdentifier: program,
              ),
            ),
          );
        },
      ),
    );
  }
}
