import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/dashboard_widgets.dart';
import '../../data/mock/mock_dashboard_data.dart';
import '../chat/chatbot_figma_screen.dart';
import '../course_lookup/course_lookup_quick_access.dart';

class StudentDashboard extends StatelessWidget {
  const StudentDashboard({super.key, this.onSignOut});

  final VoidCallback? onSignOut;

  @override
  Widget build(BuildContext context) {
    final data = studentMockData;
    return DashboardScaffold(
      header: DashboardHeader(
        role: 'Sinh viên',
        name: data.name,
        subtitle: data.semester,
        avatarIcon: Icons.person_outline_rounded,
        onSignOut: onSignOut,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const InfoPill(
            label: 'Học kỳ hiện tại',
            icon: Icons.calendar_today_outlined,
          ),
          const SizedBox(height: 10),
          ProfileCard(
            name: data.name,
            id: data.studentId,
            program: data.program,
            avatarIcon: Icons.person_outline_rounded,
            badge: 'Đang theo học',
          ),
          const SizedBox(height: 16),
          const SectionTitle(title: 'Hồ sơ học tập'),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: StatisticCard(
                  label: 'GPA tích lũy',
                  value: data.gpa,
                  caption: 'Tốt',
                  icon: Icons.trending_up_rounded,
                  iconColor: AppColors.primary,
                  iconBackground: AppColors.blueSoft,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatisticCard(
                  label: 'Tín chỉ tích lũy',
                  value: '${data.credits}',
                  caption: 'Đã hoàn thành',
                  icon: Icons.school_outlined,
                  iconColor: AppColors.green,
                  iconBackground: AppColors.greenSoft,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const SectionTitle(title: 'Tiến độ chương trình đào tạo'),
          const SizedBox(height: 10),
          ProgressCard(
            title: 'Tiến độ hoàn thành',
            completed: data.credits,
            total: data.totalCredits,
            caption:
                'Còn ${data.totalCredits - data.credits} tín chỉ để hoàn thành chương trình.',
          ),
          const SizedBox(height: 16),
          const SectionTitle(title: 'Chức năng nhanh'),
          const SizedBox(height: 10),
          CourseLookupQuickAccess(
            studentName: data.name,
            studentCode: data.studentId,
            program: data.program,
          ),
          ...data.features.map(
            (feature) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: FeatureCard(
                title: feature.title,
                subtitle: feature.subtitle,
                icon: feature.icon,
                iconColor: feature.iconColor,
                iconBackground: feature.iconBackground,
                onTap: feature.title == 'Trợ lý học vụ AI'
                  ? () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const ChatbotFigmaScreen(),
                        ),
                      )
                  : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
