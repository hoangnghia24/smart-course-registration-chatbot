import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../features/admin/admin_dashboard.dart';
import '../features/lecturer/lecturer_dashboard.dart';
import '../features/student/student_dashboard.dart';

void main() {
  runApp(const Week5DashboardPreviewApp());
}

class Week5DashboardPreviewApp extends StatelessWidget {
  const Week5DashboardPreviewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Week 5 Dashboard Preview',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const Week5DashboardPreview(),
    );
  }
}

enum DashboardRole { student, lecturer, admin }

class Week5DashboardPreview extends StatefulWidget {
  const Week5DashboardPreview({super.key});

  @override
  State<Week5DashboardPreview> createState() => _Week5DashboardPreviewState();
}

class _Week5DashboardPreviewState extends State<Week5DashboardPreview> {
  DashboardRole _role = DashboardRole.student;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Dashboard Preview • Tuần 5'),
        actions: [
          PopupMenuButton<DashboardRole>(
            tooltip: 'Chọn vai trò',
            onSelected: (role) => setState(() => _role = role),
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: DashboardRole.student,
                child: Text('Sinh viên'),
              ),
              PopupMenuItem(
                value: DashboardRole.lecturer,
                child: Text('Giảng viên'),
              ),
              PopupMenuItem(value: DashboardRole.admin, child: Text('Admin')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: SegmentedButton<DashboardRole>(
              segments: const [
                ButtonSegment(
                  value: DashboardRole.student,
                  label: Text('Sinh viên'),
                  icon: Icon(Icons.person_outline_rounded),
                ),
                ButtonSegment(
                  value: DashboardRole.lecturer,
                  label: Text('Giảng viên'),
                  icon: Icon(Icons.co_present_outlined),
                ),
                ButtonSegment(
                  value: DashboardRole.admin,
                  label: Text('Admin'),
                  icon: Icon(Icons.admin_panel_settings_outlined),
                ),
              ],
              selected: {_role},
              onSelectionChanged: (selection) =>
                  setState(() => _role = selection.first),
              showSelectedIcon: false,
            ),
          ),
          Expanded(child: _buildDashboard()),
        ],
      ),
    );
  }

  Widget _buildDashboard() {
    return switch (_role) {
      DashboardRole.student => const StudentDashboard(),
      DashboardRole.lecturer => const LecturerDashboard(),
      DashboardRole.admin => const AdminDashboard(),
    };
  }
}
