import 'package:serverpod/serverpod.dart';

/// Gửi mã xác minh khi đăng ký tài khoản.
Future<void> sendRegistrationCode(
  Session session, {
  required String email,
  required UuidValue accountRequestId,
  required String verificationCode,
  required Transaction? transaction,
}) async {
  // TODO: Tích hợp dịch vụ gửi email của nhà trường.
  // Không ghi verificationCode vào log.

  throw UnimplementedError(
    'Chưa cấu hình dịch vụ gửi email xác minh tài khoản.',
  );
}

/// Gửi mã xác minh khi đặt lại mật khẩu.
Future<void> sendPasswordResetCode(
  Session session, {
  required String email,
  required UuidValue passwordResetRequestId,
  required String verificationCode,
  required Transaction? transaction,
}) async {
  // TODO: Tích hợp dịch vụ gửi email đặt lại mật khẩu.
  // Không ghi verificationCode vào log.

  throw UnimplementedError(
    'Chưa cấu hình dịch vụ gửi email đặt lại mật khẩu.',
  );
}
