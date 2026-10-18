import 'package:flutter/foundation.dart';

enum DemoRole { student, lecturer, admin }

class DemoUser {
  const DemoUser({
    required this.username,
    required this.displayName,
    required this.role,
  });

  final String username;
  final String displayName;
  final DemoRole role;
}

class DemoAuthResult {
  const DemoAuthResult._({required this.success, this.message});

  const DemoAuthResult.success() : this._(success: true);

  const DemoAuthResult.failure(String message)
    : this._(success: false, message: message);

  final bool success;
  final String? message;
}

/// Mock-only auth state for the Week 5 UI preview.
///
/// This intentionally does not create tokens, persist passwords, or call an
/// API. It can be replaced by a Serverpod-backed repository later.
class DemoAuthController extends ChangeNotifier {
  DemoUser? _currentUser;

  DemoUser? get currentUser => _currentUser;

  DemoAuthResult signIn({required String username, required String password}) {
    final normalizedUsername = username.trim().toLowerCase();
    final demoUser = _demoUsers[normalizedUsername];

    if (demoUser == null || password != _demoPassword) {
      return const DemoAuthResult.failure(
        'Tài khoản hoặc mật khẩu demo không đúng.',
      );
    }

    _currentUser = demoUser;
    notifyListeners();
    return const DemoAuthResult.success();
  }

  void signOut() {
    if (_currentUser == null) return;
    _currentUser = null;
    notifyListeners();
  }
}

const _demoPassword = 'demo123';

const _demoUsers = <String, DemoUser>{
  'sv001': DemoUser(
    username: 'sv001',
    displayName: 'Nguyễn Minh Anh',
    role: DemoRole.student,
  ),
  'gv001': DemoUser(
    username: 'gv001',
    displayName: 'Trần Minh Khôi',
    role: DemoRole.lecturer,
  ),
  'admin001': DemoUser(
    username: 'admin001',
    displayName: 'Lê Thanh Hùng',
    role: DemoRole.admin,
  ),
};
