import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';
import 'package:smart_course_registration_chatbot_client/smart_course_registration_chatbot_client.dart';

/// Dữ liệu F01 tối thiểu do server xác thực và trả về.
/// Không lấy role từ màn hình hoặc scopeNames trong AuthSuccess.
class F01User {
  const F01User({
    required this.accountId,
    required this.role,
    required this.status,
    this.studentCode,
    this.lecturerCode,
  });

  final int accountId;
  final F01Role role;
  final String status;
  final String? studentCode;
  final String? lecturerCode;
}

enum F01Role { student, lecturer, admin }

/// Ranh giới gọi API: có thể giả lập trong widget/unit tests.
abstract class F01AuthGateway {
  Future<F01User> signIn(String email, String password);
  Future<F01User> getCurrentUser();
  Future<void> signOut();
}

/// Sử dụng đúng Dart client do Serverpod sinh ra; KHÔNG gọi REST tự đoán.
///
/// Yêu cầu generated client chứa emailIdp.login() và account.me().
/// Cần đối chiếu source client ở commit backend trước khi nghiệm thu.
class ServerpodF01AuthGateway implements F01AuthGateway {
  const ServerpodF01AuthGateway(this.client);

  final Client client;

  @override
  Future<F01User> signIn(String email, String password) async {
    final authInfo = await client.emailIdp.login(
      email: email.trim(),
      password: password,
    );
    await client.auth.updateSignedInUser(authInfo);
    try {
      return await getCurrentUser();
    } catch (_) {
      // Không giữ phiên đăng nhập nếu không lấy được role nghiệp vụ.
      try {
        await client.auth.signOutDevice();
      } catch (_) {
        // Giữ nguyên lỗi gốc, tránh vô tình làm lộ chi tiết sign-out.
      }
      rethrow;
    }
  }

  @override
  Future<F01User> getCurrentUser() async {
    if (!client.auth.isAuthenticated) {
      throw const F01NotSignedInException();
    }
    final me = await client.account.me();
    final role = switch (me.role) {
      AccountRole.student => F01Role.student,
      AccountRole.lecturer => F01Role.lecturer,
      AccountRole.admin => F01Role.admin,
    };
    if (me.status != AccountStatus.active) {
      throw const F01AccountInactiveException();
    }
    return F01User(
      accountId: me.accountId,
      role: role,
      status: 'active',
      studentCode: me.studentCode,
      lecturerCode: me.lecturerCode,
    );
  }

  @override
  Future<void> signOut() async {
    await client.auth.signOutDevice();
  }
}

class F01AccountInactiveException implements Exception {
  const F01AccountInactiveException();

  @override
  String toString() => 'Tài khoản đã bị khóa hoặc chưa kích hoạt.';
}

class F01NotSignedInException implements Exception {
  const F01NotSignedInException();
}
