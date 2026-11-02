import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/dashboard_widgets.dart';
import 'course_lookup_screen.dart';
import 'course_lookup_repository_scope.dart';

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
    final liveRepository = CourseLookupRepositoryScope.maybeOf(context);
    final isLiveData = liveRepository != null;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: FeatureCard(
        title: 'Tra cứu học phần',
        subtitle: isLiveData
            ? 'Tra cứu danh mục học phần trên Serverpod'
            : 'Tìm kiếm môn học, tín chỉ và thông tin lớp (bản mẫu)',
        icon: Icons.manage_search_rounded,
        iconColor: AppColors.primary,
        iconBackground: AppColors.blueSoft,
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => CourseLookupScreen(
                studentName: isLiveData ? 'Sinh viên đã xác thực' : studentName,
                studentCode: isLiveData ? '' : studentCode,
                program: isLiveData ? 'Tra cứu danh mục học phần' : program,
                repository: liveRepository,
                isLiveData: isLiveData,
              ),
            ),
          );
        },
      ),
    );
  }
}
