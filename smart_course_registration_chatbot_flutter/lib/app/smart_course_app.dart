import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../data/mock/mock_auth.dart';
import '../features/admin/admin_dashboard.dart';
import '../features/auth/data/f01_auth_gateway.dart';
import '../features/auth/f01_auth_controller.dart';
import '../features/auth/login_demo_screen.dart';
import '../features/lecturer/lecturer_dashboard.dart';
import '../features/student/student_dashboard.dart';

/// Ứng dụng thống nhất, giữ nguyên 3 Dashboard và điều hướng đã có.
///
/// Khi truyền f01Gateway: dùng Serverpod thật.
/// Khi không truyền: chế độ demo CHỈ để chạy các bài test/preview cũ.
class SmartCourseApp extends StatefulWidget {
  const SmartCourseApp({super.key, this.f01Gateway});

  final F01AuthGateway? f01Gateway;

  @override
  State<SmartCourseApp> createState() => _SmartCourseAppState();
}

class _SmartCourseAppState extends State<SmartCourseApp> {
  DemoAuthController? _demoController;
  F01AuthController? _realController;

  @override
  void initState() {
    super.initState();
    if (widget.f01Gateway == null) {
      _demoController = DemoAuthController();
    } else {
      _realController = F01AuthController(widget.f01Gateway!);
      _realController!.restoreSession();
    }
  }

  @override
  void dispose() {
    _demoController?.dispose();
    _realController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final listenable = _realController ?? _demoController!;
    return AnimatedBuilder(
      animation: listenable,
      builder: (context, _) {
        return MaterialApp(
          title: 'Đăng ký học phần thông minh',
          debugShowCheckedModeBanner: false,
          theme: buildAppTheme(),
          home: _realController != null
              ? _buildRealHome(_realController!)
              : _buildDemoHome(_demoController!),
        );
      },
    );
  }

  Widget _buildRealHome(F01AuthController auth) {
    if (auth.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final user = auth.user;
    if (user == null) {
      return LoginDemoScreen(
        onServerSignIn: (email, password) =>
            auth.signIn(email: email, password: password),
      );
    }
    return _VerifiedRoleDashboard(
      user: user,
      onSignOut: () { auth.signOut(); },
    );
  }

  Widget _buildDemoHome(DemoAuthController auth) {
    final currentUser = auth.currentUser;
    if (currentUser == null) {
      return LoginDemoScreen(authController: auth);
    }
    return switch (currentUser.role) {
      DemoRole.student => StudentDashboard(onSignOut: auth.signOut),
      DemoRole.lecturer => LecturerDashboard(onSignOut: auth.signOut),
      DemoRole.admin => AdminDashboard(onSignOut: auth.signOut),
    };
  }
}

class _VerifiedRoleDashboard extends StatelessWidget {
  const _VerifiedRoleDashboard({
    required this.user,
    required this.onSignOut,
  });

  final F01User user;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    final page = switch (user.role) {
      F01Role.student => StudentDashboard(onSignOut: onSignOut),
      F01Role.lecturer => LecturerDashboard(onSignOut: onSignOut),
      F01Role.admin => AdminDashboard(onSignOut: onSignOut),
    };

    // F01 chứng minh role đã được xác thực nhưng các Dashboard hiện vẫn dùng
    // mock_dashboard_data.dart. Dán nhãn để tránh nhầm là dữ liệu học tập thật.
    return Column(
      children: [
        Material(
          color: const Color(0xFFFFF2D7),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Đã xác thực tài khoản #${user.accountId} • '
                      'Thông tin Dashboard hiện là dữ liệu mẫu',
                      style: const TextStyle(fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(child: page),
      ],
    );
  }
}
