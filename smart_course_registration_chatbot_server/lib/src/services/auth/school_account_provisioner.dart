import 'dart:io';

import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';
import 'package:serverpod_auth_idp_server/providers/email.dart';

import '../../generated/protocol.dart';

/// Only call from trusted server-side code or an endpoint that has already
/// checked the logged-in caller has the ADMIN role. Never expose publicly.
class SchoolAccountProvisioner {
  static Future<int> create(
    Session session, {
    required String email,
    required String password,
    required AccountRole role,
    String? studentCode,
    int? curriculumVersionId,
    String? lecturerCode,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
        .hasMatch(normalizedEmail)) {
      throw ArgumentError('Email không hợp lệ.');
    }
    // School-domain restriction is optional for demo environments; configure
    // SCHOOL_EMAIL_DOMAIN on the real school server.
    final schoolDomain = Platform.environment['SCHOOL_EMAIL_DOMAIN']
        ?.trim()
        .toLowerCase();
    if (schoolDomain != null &&
        schoolDomain.isNotEmpty &&
        normalizedEmail.split('@').last != schoolDomain) {
      throw ArgumentError('Email không thuộc miền nhà trường cho phép.');
    }
    if (password.length < 16) {
      throw ArgumentError('Mật khẩu cấp ban đầu phải có ít nhất 16 ký tự.');
    }
    if (role == AccountRole.student &&
        ((studentCode?.trim().isEmpty ?? true) ||
            curriculumVersionId == null)) {
      throw ArgumentError('Student cần studentCode và curriculumVersionId.');
    }
    if (role == AccountRole.lecturer &&
        (lecturerCode?.trim().isEmpty ?? true)) {
      throw ArgumentError('Lecturer cần lecturerCode.');
    }

    // Keep all provisioning changes atomic; enable the account ONLY after
    // both identity data and required school profile are present.
    return session.db.transaction((transaction) async {
      final existingProfile = await UserAccount.db.findFirstRow(
        session,
        where: (t) => t.schoolEmail.equals(normalizedEmail),
        transaction: transaction,
      );
      if (existingProfile != null) {
        throw StateError('Tài khoản nghiệp vụ đã tồn tại.');
      }

      final emailAdmin = AuthServices.instance.emailIdp.admin;
      final existingEmailIdentity = await emailAdmin.findAccount(
        session,
        email: normalizedEmail,
        transaction: transaction,
      );
      if (existingEmailIdentity != null) {
        throw StateError(
          'Email đã được gắn với AuthUser khác; không tự ghép danh tính.',
        );
      }

      final authUser = await AuthServices.instance.authUsers.create(
        session,
        blocked: true,
        transaction: transaction,
      );
      final authUserId = authUser.id;

      // Email IDP hashes/stores the password; DO NOT make your own hash table.
      await emailAdmin.createEmailAuthentication(
        session,
        authUserId: authUserId,
        email: normalizedEmail,
        password: password,
        transaction: transaction,
      );

      final now = DateTime.now().toUtc();
      final account = await UserAccount.db.insertRow(
        session,
        UserAccount(
          authUserId: authUserId.toString(),
          schoolEmail: normalizedEmail,
          role: role,
          status: AccountStatus.inactive,
          createdAt: now,
          updatedAt: now,
        ),
        transaction: transaction,
      );

      if (role == AccountRole.student) {
        await Student.db.insertRow(
          session,
          Student(
            userAccountId: account.id!,
            studentCode: studentCode!.trim(),
            curriculumVersionId: curriculumVersionId!,
            academicStatus: 'STUDYING', // Demo; use official enum later.
          ),
          transaction: transaction,
        );
      } else if (role == AccountRole.lecturer) {
        await Lecturer.db.insertRow(
          session,
          Lecturer(
            userAccountId: account.id!,
            lecturerCode: lecturerCode!.trim(),
            teachingStatus: LecturerStatus.active,
          ),
          transaction: transaction,
        );
      }

      await UserAccount.db.updateRow(
        session,
        account.copyWith(
          status: AccountStatus.active,
          updatedAt: now,
          statusChangedAt: now,
        ),
        transaction: transaction,
      );

      await AuthServices.instance.authUsers.update(
        session,
        authUserId: authUserId,
        blocked: false,
        transaction: transaction,
      );
      return account.id!;
    });
  }
}
