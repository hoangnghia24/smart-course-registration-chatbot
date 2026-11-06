import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/dashboard_widgets.dart';
import 'academic_progress_repository_scope.dart';
import 'academic_progress_screen.dart';

/// Thẻ F23 để thêm vào StudentDashboard, không thay đổi các thẻ F01/F03/F04.
class AcademicProgressQuickAccess extends StatelessWidget {
  const AcademicProgressQuickAccess({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = AcademicProgressRepositoryScope.maybeOf(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: FeatureCard(
        title: 'Kết quả học tập',
        subtitle: 'Xem tiến độ tín chỉ, điểm và trạng thái học phần',
        icon: Icons.fact_check_outlined,
        iconColor: AppColors.primary,
        iconBackground: AppColors.blueSoft,
        onTap: () {
          if (repository == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Chức năng F23 chưa được kết nối Serverpod.'),
              ),
            );
            return;
          }
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => AcademicProgressScreen(repository: repository),
            ),
          );
        },
      ),
    );
  }
}
