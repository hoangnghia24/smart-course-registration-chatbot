import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';

/// Kiểm tra tài khoản và phân quyền trong hệ thống.
class AccountGuard {
  static Future<UserAccount> requireAuthenticatedAccount(
    Session session,
  ) async {
    // Lấy danh tính từ session đã được Serverpod xác thực.
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
    final account = await requireAuthenticatedAccount(session);

    // Kiểm tra vai trò người dùng.
    if (!allowedRoles.contains(account.role)) {
      throw AppException(
        code: 'FORBIDDEN',
        message: 'Bạn không có quyền truy cập.',
      );
    }

    return account;
  }

  /// Xác định ID sinh viên đang đăng nhập
  static Future<int> requireStudentId(Session session) async {
    final account = await requireRole(
      session,
      allowedRoles: {AccountRole.student},
    );

    final student = await Student.db.findFirstRow(
      session,
      where: (t) => t.userAccountId.equals(account.id!),
    );

    if (student?.id == null) {
      throw AppException(
        code: 'STUDENT_NOT_FOUND',
        message: 'Không tìm thấy hồ sơ sinh viên.',
      );
    }

    return student!.id!;
  }

  /// Xác định ID giảng viên đang đăng nhập
  static Future<int> requireLecturerId(Session session) async {
    final account = await requireRole(
      session,
      allowedRoles: {AccountRole.lecturer},
    );

    final lecturer = await Lecturer.db.findFirstRow(
      session,
      where: (t) => t.userAccountId.equals(account.id!),
    );

    if (lecturer?.id == null) {
      throw AppException(
        code: 'LECTURER_NOT_FOUND',
        message: 'Không tìm thấy hồ sơ giảng viên.',
      );
    }

    return lecturer!.id!;
  }

  /// Xác định ID quản trị viên đang đăng nhập
  static Future<int> requireAdminId(Session session) async {
    final account = await requireRole(
      session,
      allowedRoles: {AccountRole.admin},
    );

    if (account.id == null) {
      throw AppException(
        code: 'ADMIN_NOT_FOUND',
        message: 'Không tìm thấy tài khoản quản trị viên.',
      );
    }

    return account.id!;
  }
}
