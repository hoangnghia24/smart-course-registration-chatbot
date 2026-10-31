import 'package:serverpod_auth_idp_server/core.dart';
import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import '../security/account_guard.dart';

/// API dành cho người dùng đang đăng nhập.
class AccountEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  /// Lấy thông tin người dùng từ session.
  Future<CurrentUserDto> me(Session session) async {
    final account = await AccountGuard.requireAuthenticatedAccount(session);

    String? studentCode;
    String? lecturerCode;

    // Lấy thông tin Student.
    if (account.role == AccountRole.student) {
      final student = await Student.db.findFirstRow(
        session,
        where: (t) => t.userAccountId.equals(account.id!),
      );

      studentCode = student?.studentCode;
    }

    // Lấy thông tin Lecturer.
    if (account.role == AccountRole.lecturer) {
      final lecturer = await Lecturer.db.findFirstRow(
        session,
        where: (t) => t.userAccountId.equals(account.id!),
      );

      lecturerCode = lecturer?.lecturerCode;
    }

    return CurrentUserDto(
      accountId: account.id!,
      role: account.role,
      status: account.status,
      studentCode: studentCode,
      lecturerCode: lecturerCode,
    );
  }

  /// Đăng xuất tài khoản khỏi tất cả các thiết bị.
  Future<bool> logoutAll(Session session) async {
    await AccountGuard.requireAuthenticatedAccount(session);

    final authUserId = session.authenticated?.authUserId;

    if (authUserId == null) {
      throw AppException(
        code: 'AUTH_REQUIRED',
        message: 'Vui lòng đăng nhập.',
      );
    }

    await AuthServices.instance.tokenManager.revokeAllTokens(
      session,
      authUserId: authUserId,
    );

    return true;
  }
}
