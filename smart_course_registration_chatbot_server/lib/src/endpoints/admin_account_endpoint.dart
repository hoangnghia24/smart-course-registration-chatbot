
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';

import '../generated/protocol.dart';
import '../security/account_guard.dart';

/// API quản trị tài khoản.
/// Chỉ tài khoản Admin mới được thực hiện các thao tác.
class AdminAccountEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  /// Kiểm tra quyền truy cập Admin.
  Future<String> checkAccess(Session session) async {
    await AccountGuard.require(
      session,
      allowedRoles: {AccountRole.admin},
    );

    return 'ADMIN_OK';
  }

  /// Khóa hoặc mở khóa tài khoản.
  ///
  /// active = true: kích hoạt tài khoản.
  /// active = false: khóa tài khoản.
  Future<bool> setActive(
    Session session,
    int accountId,
    bool active,
  ) async {
    // 1. Kiểm tra người gọi có quyền Admin.
    final actor = await AccountGuard.require(
      session,
      allowedRoles: {AccountRole.admin},
    );

    // 2. Cập nhật trạng thái trong transaction.
    final targetAuthUserId = await session.db.transaction(
      (transaction) async {
        final target = await UserAccount.db.findById(
          session,
          accountId,
          transaction: transaction,
        );

        // Không tìm thấy tài khoản.
        if (target == null) {
          throw AppException(
            code: 'ACCOUNT_NOT_FOUND',
            message: 'Không tìm thấy tài khoản.',
          );
        }

        // Không cho Admin tự khóa chính mình.
        if (!active && target.id == actor.id) {
          throw AppException(
            code: 'CANNOT_LOCK_SELF',
            message: 'Admin không thể tự khóa tài khoản.',
          );
        }

        final now = DateTime.now().toUtc();

        // 3. Cập nhật UserAccount.
        target.status = active
            ? AccountStatus.active
            : AccountStatus.inactive;

        target.updatedAt = now;
        target.statusChangedAt = now;

        await UserAccount.db.updateRow(
          session,
          target,
          transaction: transaction,
        );

        // 4. Xác định AuthUser tương ứng.
        final authId = UuidValue.fromString(
          target.authUserId,
        );

        // 5. Khóa hoặc mở khóa AuthUser.
        await AuthServices.instance.authUsers.update(
          session,
          authUserId: authId,
          blocked: !active,
          transaction: transaction,
        );

        return authId;
      },
    );

    // 6. Thu hồi các session cũ khi khóa tài khoản.
    if (!active) {
      await AuthServices.instance.tokenManager.revokeAllTokens(
        session,
        authUserId: targetAuthUserId,
      );
    }

    return true;
  }
}
