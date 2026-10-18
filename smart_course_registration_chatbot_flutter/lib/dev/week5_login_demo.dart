import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../data/mock/mock_auth.dart';
import '../features/admin/admin_dashboard.dart';
import '../features/auth/login_demo_screen.dart';
import '../features/lecturer/lecturer_dashboard.dart';
import '../features/student/student_dashboard.dart';

void main() {
  runApp(const Week5LoginDemoApp());
}

class Week5LoginDemoApp extends StatefulWidget {
  const Week5LoginDemoApp({super.key});

  @override
  State<Week5LoginDemoApp> createState() => _Week5LoginDemoAppState();
}

class _Week5LoginDemoAppState extends State<Week5LoginDemoApp> {
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
        return MaterialApp(
          title: 'Week 5 Login Demo',
          debugShowCheckedModeBanner: false,
          theme: buildAppTheme(),
          home: _authController.currentUser == null
              ? LoginDemoScreen(authController: _authController)
              : _DashboardForDemoUser(
                  user: _authController.currentUser!,
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
