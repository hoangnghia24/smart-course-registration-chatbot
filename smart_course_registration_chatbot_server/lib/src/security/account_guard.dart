import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';

class AccountGuard {
  static Future<UserAccount> require(
    Session session, {
    Set<AccountRole> allowedRoles = const {},
  }) async {
    // Lấy AuthUser ID từ token.
    final authUserId = session.authenticated?.userIdentifier;

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

    // Kiểm tra trạng thái tài khoản.
    if (account.status != AccountStatus.active) {
      throw AppException(
        code: 'ACCOUNT_INACTIVE',
        message: 'Tài khoản đã bị khóa hoặc chưa được kích hoạt.',
      );
    }

    // Kiểm tra quyền nếu API yêu cầu vai trò cụ thể.
    if (allowedRoles.isNotEmpty &&
        !allowedRoles.contains(account.role)) {
      throw AppException(
        code: 'FORBIDDEN',
        message: 'Bạn không có quyền truy cập.',
      );
    }

    return account;
  }
}