import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/dashboard_widgets.dart';
import 'course_lookup_screen.dart';

/// Thẻ dẫn đường F03 dành cho Dashboard Sinh viên.
/// Tách riêng để không phải ghi đè student_dashboard.dart/Chatbot đang hoạt động.
class CourseLookupQuickAccess extends StatelessWidget {
  const CourseLookupQuickAccess({
    super.key,
    required this.studentName,
    required this.studentCode,
    required this.program,
  });

  final String studentName;
  final String studentCode;
  final String program;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: FeatureCard(
        title: 'Tra cứu học phần',
        subtitle: 'Tìm kiếm môn học, tín chỉ và thông tin lớp (bản mẫu)',
        icon: Icons.manage_search_rounded,
        iconColor: AppColors.primary,
        iconBackground: AppColors.blueSoft,
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => CourseLookupScreen(
                studentName: studentName,
                studentCode: studentCode,
                program: program,
              ),
            ),
          );
        },
      ),
    );
  }
}
