import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/dashboard_widgets.dart';
import '../../data/mock/mock_dashboard_data.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key, this.onSignOut});

  final VoidCallback? onSignOut;

  @override
  Widget build(BuildContext context) {
    final data = adminMockData;
    return DashboardScaffold(
      header: DashboardHeader(
        role: 'Quản trị viên',
        name: data.name,
        subtitle: data.organization,
        avatarIcon: Icons.admin_panel_settings_outlined,
        onSignOut: onSignOut,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const InfoPill(label: 'Trung tâm quản trị', icon: Icons.tune_rounded),
          const SizedBox(height: 10),
          ProfileCard(
            name: data.name,
            id: data.accountId,
            program: data.organization,
            avatarIcon: Icons.admin_panel_settings_outlined,
            badge: 'Đang hoạt động',
          ),
          const SizedBox(height: 16),
          const SectionTitle(title: 'Chỉ số hệ thống'),
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
              final values = ['1,248', '12', '86', '07'];
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
          const SectionTitle(
            title: 'Duyệt lớp học phần',
            trailing: 'Cần xử lý',
          ),
          const SizedBox(height: 10),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                for (
                  var index = 0;
                  index < data.pendingApprovals.length;
                  index++
                )
                  ListTile(
                    dense: true,
                    leading: Icon(
                      Icons.pending_actions_rounded,
                      color: index == 0 ? AppColors.amber : AppColors.purple,
                    ),
                    title: Text(
                      data.pendingApprovals[index],
                      style: const TextStyle(
                        color: AppColors.text,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: const Text(
                      'Đang chờ xem xét • Dữ liệu mẫu',
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
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 2, 14, 14),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () => showPreviewMessage(
                        context,
                        'Thao tác duyệt thật sẽ kết nối backend sau.',
                      ),
                      icon: const Icon(Icons.visibility_outlined, size: 17),
                      label: const Text('Xem danh sách chờ duyệt'),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const SectionTitle(title: 'Quản lý hệ thống'),
          const SizedBox(height: 10),
          const FeatureCard(
            title: 'Quản lý tài khoản',
            subtitle: 'Sinh viên, giảng viên và quản trị viên',
            icon: Icons.manage_accounts_outlined,
            iconColor: AppColors.primary,
            iconBackground: AppColors.blueSoft,
          ),
          const SizedBox(height: 8),
          const FeatureCard(
            title: 'Quản lý chương trình đào tạo',
            subtitle: 'Theo dõi ngành và khung chương trình',
            icon: Icons.menu_book_outlined,
            iconColor: AppColors.primary,
            iconBackground: AppColors.blueSoft,
          ),
          const SizedBox(height: 8),
          const FeatureCard(
            title: 'Quản lý lớp học phần',
            subtitle: 'Mở lớp và theo dõi trạng thái duyệt',
            icon: Icons.bar_chart_rounded,
            iconColor: AppColors.green,
            iconBackground: AppColors.greenSoft,
          ),
          const SizedBox(height: 8),
          const FeatureCard(
            title: 'Nhật ký hệ thống',
            subtitle: 'Theo dõi hoạt động quản trị',
            icon: Icons.history_rounded,
            iconColor: AppColors.purple,
            iconBackground: AppColors.purpleSoft,
          ),
        ],
      ),
    );
  }
}
