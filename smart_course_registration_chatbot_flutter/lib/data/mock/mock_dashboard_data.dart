import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class DashboardFeatureData {
  const DashboardFeatureData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
}

class StudentMockData {
  const StudentMockData({
    required this.name,
    required this.studentId,
    required this.program,
    required this.gpa,
    required this.credits,
    required this.totalCredits,
    required this.semester,
    required this.features,
  });

  final String name;
  final String studentId;
  final String program;
  final String gpa;
  final int credits;
  final int totalCredits;
  final String semester;
  final List<DashboardFeatureData> features;
}

const studentMockData = StudentMockData(
  name: 'Nguyễn Minh Anh',
  studentId: 'MSSV: 22110001',
  program: 'Công nghệ thông tin • K46',
  gpa: '3.42',
  credits: 96,
  totalCredits: 140,
  semester: 'Học kỳ 1 • 2026–2027',
  features: [
    DashboardFeatureData(
      title: 'Đăng ký học phần',
      subtitle: 'Theo dõi các học phần mở trong kỳ',
      icon: Icons.assignment_outlined,
      iconColor: AppColors.primary,
      iconBackground: AppColors.blueSoft,
    ),
    DashboardFeatureData(
      title: 'Lịch học của tôi',
      subtitle: 'Xem lịch học và lịch thi dự kiến',
      icon: Icons.school_outlined,
      iconColor: AppColors.primary,
      iconBackground: AppColors.blueSoft,
    ),
    DashboardFeatureData(
      title: 'Trợ lý học vụ AI',
      subtitle: 'Hỏi đáp thông tin học vụ',
      icon: Icons.smart_toy_outlined,
      iconColor: AppColors.primary,
      iconBackground: AppColors.blueSoft,
    ),
  ],
);

class LecturerMockData {
  const LecturerMockData({
    required this.name,
    required this.staffId,
    required this.department,
    required this.stats,
    required this.schedule,
    required this.demands,
  });

  final String name;
  final String staffId;
  final String department;
  final List<DashboardFeatureData> stats;
  final List<String> schedule;
  final List<String> demands;
}

const lecturerMockData = LecturerMockData(
  name: 'Trần Minh Khôi',
  staffId: 'GV: GV2020018',
  department: 'Khoa Công nghệ thông tin',
  stats: [
    DashboardFeatureData(
      title: 'Lớp học phần',
      subtitle: 'Đang phụ trách',
      icon: Icons.class_outlined,
      iconColor: AppColors.primary,
      iconBackground: AppColors.blueSoft,
    ),
    DashboardFeatureData(
      title: 'Sinh viên',
      subtitle: 'Trong các lớp',
      icon: Icons.groups_outlined,
      iconColor: AppColors.amber,
      iconBackground: AppColors.amberSoft,
    ),
    DashboardFeatureData(
      title: 'Giờ giảng',
      subtitle: 'Trong học kỳ',
      icon: Icons.schedule_outlined,
      iconColor: AppColors.green,
      iconBackground: AppColors.greenSoft,
    ),
    DashboardFeatureData(
      title: 'Đánh giá',
      subtitle: 'Trung bình kỳ trước',
      icon: Icons.star_outline_rounded,
      iconColor: AppColors.purple,
      iconBackground: AppColors.purpleSoft,
    ),
  ],
  schedule: [
    '08:00  •  Lập trình Web  •  A302',
    '13:30  •  Cơ sở dữ liệu  •  B204',
  ],
  demands: [
    'Lập trình nâng cao  •  45 sinh viên',
    'Phân tích thiết kế hệ thống  •  35 sinh viên',
  ],
);

class AdminMockData {
  const AdminMockData({
    required this.name,
    required this.accountId,
    required this.organization,
    required this.stats,
    required this.pendingApprovals,
  });

  final String name;
  final String accountId;
  final String organization;
  final List<DashboardFeatureData> stats;
  final List<String> pendingApprovals;
}

const adminMockData = AdminMockData(
  name: 'Lê Thanh Hùng',
  accountId: 'ADMIN: QT0008',
  organization: 'Phòng Đào tạo • Hệ thống đăng ký học phần',
  stats: [
    DashboardFeatureData(
      title: 'Tài khoản',
      subtitle: 'Đang hoạt động',
      icon: Icons.manage_accounts_outlined,
      iconColor: AppColors.primary,
      iconBackground: AppColors.blueSoft,
    ),
    DashboardFeatureData(
      title: 'Chương trình',
      subtitle: 'Đang áp dụng',
      icon: Icons.menu_book_outlined,
      iconColor: AppColors.purple,
      iconBackground: AppColors.purpleSoft,
    ),
    DashboardFeatureData(
      title: 'Lớp học phần',
      subtitle: 'Trong học kỳ này',
      icon: Icons.class_outlined,
      iconColor: AppColors.green,
      iconBackground: AppColors.greenSoft,
    ),
    DashboardFeatureData(
      title: 'Chờ duyệt',
      subtitle: 'Yêu cầu cần xử lý',
      icon: Icons.schedule_outlined,
      iconColor: AppColors.amber,
      iconBackground: AppColors.amberSoft,
    ),
  ],
  pendingApprovals: [
    'Mở lớp Lập trình Web nâng cao',
    'Cập nhật chương trình đào tạo K47',
  ],
);
