import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../data/mock/mock_auth.dart';
import '../features/admin/admin_dashboard.dart';
import '../features/auth/login_demo_screen.dart';
import '../features/lecturer/lecturer_dashboard.dart';
import '../features/student/student_dashboard.dart';

/// Vỏ ứng dụng Flutter thống nhất: chỉ có một MaterialApp.
/// Xác thực hiện còn là bản demo, sẽ thay bằng API Serverpod khi sẵn sàng.
class SmartCourseApp extends StatefulWidget {
  const SmartCourseApp({super.key});

  @override
  State<SmartCourseApp> createState() => _SmartCourseAppState();
}

class _SmartCourseAppState extends State<SmartCourseApp> {
  late final DemoAuthController _authController;

  @override
  void initState() {
    super.initState();
    _authController = DemoAuthController();
  }

  @override
  void dispose() {
    _authController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _authController,
      builder: (context, _) {
        final currentUser = _authController.currentUser;

        return MaterialApp(
          title: 'Đăng ký học phần thông minh',
          debugShowCheckedModeBanner: false,
          theme: buildAppTheme(),
          home: currentUser == null
              ? LoginDemoScreen(authController: _authController)
              : _DashboardForDemoUser(
                  user: currentUser,
                  onSignOut: _authController.signOut,
                ),
        );
      },
    );
  }
}

class _DashboardForDemoUser extends StatelessWidget {
  const _DashboardForDemoUser({
    required this.user,
    required this.onSignOut,
  });

  final DemoUser user;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    return switch (user.role) {
      DemoRole.student => StudentDashboard(onSignOut: onSignOut),
      DemoRole.lecturer => LecturerDashboard(onSignOut: onSignOut),
      DemoRole.admin => AdminDashboard(onSignOut: onSignOut),
    };
  }
}
