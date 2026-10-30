
import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';

/// Kiểm tra tài khoản và phân quyền trong hệ thống.
class AccountGuard {
  static Future<UserAccount> requireAuthenticatedAccount(
    Session session,
  ) async {
    // Lấy danh tính từ session đã được Serverpod xác thực.
    final authUserId =
        session.authenticated?.userIdentifier;

    if (authUserId == null || authUserId.isEmpty) {
      throw AppException(
        code: 'AUTH_REQUIRED',
        message: 'Vui lòng đăng nhập.',
      );
    }

    // Tra cứu tài khoản nghiệp vụ.
    final account = await UserAccount.db.findFirstRow(
      session,
      where: (t) => t.authUserId.equals(authUserId),
    );

    if (account == null) {
      throw AppException(
        code: 'ACCOUNT_NOT_PROVISIONED',
        message: 'Tài khoản chưa được nhà trường cấp quyền.',
      );
    }

    // Kiểm tra tài khoản còn hoạt động.
    if (account.status != AccountStatus.active) {
      throw AppException(
        code: 'ACCOUNT_INACTIVE',
        message: 'Tài khoản chưa được kích hoạt.',
      );
    }

    return account;
  }

  /// 2. Xác thực và kiểm tra vai trò.
  static Future<UserAccount> requireRole(
    Session session, {
    required Set<AccountRole> allowedRoles,
  }) async {
    // Kiểm tra tham số đầu vào.
    if (allowedRoles.isEmpty) {
      throw ArgumentError.value(
        allowedRoles,
        'allowedRoles',
        'Phải khai báo ít nhất một vai trò.',
      );
    }

    // Dùng lại logic xác thực, không truy vấn trùng.
    final account =
        await requireAuthenticatedAccount(session);

    // Kiểm tra vai trò người dùng.
    if (!allowedRoles.contains(account.role)) {
      throw AppException(
        code: 'FORBIDDEN',
        message: 'Bạn không có quyền truy cập.',
      );
    }

    return account;
  }
}
