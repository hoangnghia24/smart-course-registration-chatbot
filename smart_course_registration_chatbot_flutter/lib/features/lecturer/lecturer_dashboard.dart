import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/dashboard_widgets.dart';
import '../../data/mock/mock_dashboard_data.dart';

class LecturerDashboard extends StatelessWidget {
  const LecturerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final data = lecturerMockData;
    return DashboardScaffold(
      header: DashboardHeader(
        role: 'Giảng viên',
        name: data.name,
        subtitle: data.department,
        avatarIcon: Icons.co_present_outlined,
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
            id: data.staffId,
            program: data.department,
            avatarIcon: Icons.co_present_outlined,
            badge: 'Đang công tác',
          ),
          const SizedBox(height: 16),
          const SectionTitle(title: 'Tổng quan lớp học phần'),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: data.stats.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.95,
            ),
            itemBuilder: (context, index) {
              final stat = data.stats[index];
              final values = ['04', '126', '48', '4.6/5'];
              return StatisticCard(
                label: stat.title,
                value: values[index],
                caption: stat.subtitle,
                icon: stat.icon,
                iconColor: stat.iconColor,
                iconBackground: stat.iconBackground,
              );
            },
          ),
          const SizedBox(height: 16),
          const SectionTitle(title: 'Lịch giảng dạy', trailing: 'Xem tất cả'),
          const SizedBox(height: 10),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                for (var index = 0; index < data.schedule.length; index++) ...[
                  ListTile(
                    dense: true,
                    leading: CircleAvatar(
                      radius: 17,
                      backgroundColor: AppColors.blueSoft,
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    title: Text(
                      data.schedule[index],
                      style: const TextStyle(
                        color: AppColors.text,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.chevron_right_rounded,
                      color: Color(0xFF8EA0B6),
                    ),
                  ),
                  if (index != data.schedule.length - 1)
                    const Divider(height: 1, indent: 58, endIndent: 12),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          const SectionTitle(title: 'Nhu cầu mở lớp', trailing: 'Tuần 5'),
          const SizedBox(height: 10),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                for (var index = 0; index < data.demands.length; index++)
                  ListTile(
                    dense: true,
                    leading: Icon(
                      Icons.bar_chart_rounded,
                      color: index == 0 ? AppColors.primary : AppColors.amber,
                    ),
                    title: Text(
                      data.demands[index],
                      style: const TextStyle(
                        color: AppColors.text,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: const Text(
                      'Dữ liệu mẫu • Chưa gửi yêu cầu thật',
                      style: TextStyle(
                        color: AppColors.mutedText,
                        fontSize: 10,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.chevron_right_rounded,
                      color: Color(0xFF8EA0B6),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const SectionTitle(title: 'Chức năng nhanh'),
          const SizedBox(height: 10),
          const FeatureCard(
            title: 'Quản lý lớp học phần',
            subtitle: 'Theo dõi lớp và danh sách sinh viên',
            icon: Icons.class_outlined,
            iconColor: AppColors.purple,
            iconBackground: AppColors.purpleSoft,
          ),
        ],
      ),
    );
  }
}
