import 'dart:io';

import 'package:serverpod/serverpod.dart';

import '../../generated/protocol.dart';
import 'school_account_provisioner.dart';

/// Run only from a local post-migration initializer.
class DevSeedAccounts {
  static Future<void> run(Session session) async {
    if (Platform.environment['APP_ENV']?.trim().toLowerCase() !=
            'development' ||
        Platform.environment['ALLOW_DEV_SEED']?.trim().toLowerCase() !=
            'true') {
      return;
    }

    ({String email, String password})? credentials(
      String emailKey,
      String passwordKey,
    ) {
      final email = Platform.environment[emailKey]?.trim() ?? '';
      final password = Platform.environment[passwordKey] ?? '';
      if (email.isEmpty && password.isEmpty) {
        stdout.writeln(
          '[DEV ACCOUNT SEED] Skipped $emailKey/$passwordKey because both '
          'values are empty.',
        );
        return null;
      }
      if (email.isEmpty || password.isEmpty) {
        throw StateError(
          'Phải cấu hình đồng thời $emailKey và $passwordKey.',
        );
      }
      return (email: email, password: password);
    }

    final curriculum =
        await Curriculum.db.findFirstRow(
          session,
          where: (t) => t.code.equals('DEV-CNTT'),
        ) ??
        await Curriculum.db.insertRow(
          session,
          Curriculum(
            code: 'DEV-CNTT',
            name: 'Chương trình thử nghiệm - KHÔNG CHÍNH THỨC',
            majorCode: 'DEV',
            status: 'ACTIVE',
          ),
        );
    final version =
        await CurriculumVersion.db.findFirstRow(
          session,
          where: (t) =>
              t.curriculumId.equals(curriculum.id!) &
              t.versionCode.equals('DEV-2026'),
        ) ??
        await CurriculumVersion.db.insertRow(
          session,
          CurriculumVersion(
            curriculumId: curriculum.id!,
            versionCode: 'DEV-2026',
            effectiveYear: 2026,
            status: 'PUBLISHED',
            publishedAt: DateTime.now().toUtc(),
          ),
        );

    Future<void> createIfAbsent({
      required String email,
      required String password,
      required AccountRole role,
      String? studentCode,
      int? curriculumVersionId,
      String? lecturerCode,
      int? admissionYear,
    }) async {
      final existing = await UserAccount.db.findFirstRow(
        session,
        where: (t) => t.schoolEmail.equals(email.trim().toLowerCase()),
      );
      if (existing != null) return;
      await SchoolAccountProvisioner.create(
        session,
        email: email,
        password: password,
        role: role,
        studentCode: studentCode,
        curriculumVersionId: curriculumVersionId,
        lecturerCode: lecturerCode,
        admissionYear: admissionYear,
      );
    }

    final admin = credentials('SEED_ADMIN_EMAIL', 'SEED_ADMIN_PASSWORD');
    if (admin != null) {
      await createIfAbsent(
        email: admin.email,
        password: admin.password,
        role: AccountRole.admin,
      );
    }

    final lecturer = credentials(
      'SEED_LECTURER_EMAIL',
      'SEED_LECTURER_PASSWORD',
    );
    if (lecturer != null) {
      await createIfAbsent(
        email: lecturer.email,
        password: lecturer.password,
        role: AccountRole.lecturer,
        lecturerCode: 'DEV-GV001',
      );
    }

    final student = credentials('SEED_STUDENT_EMAIL', 'SEED_STUDENT_PASSWORD');
    if (student != null) {
      await createIfAbsent(
        email: student.email,
        password: student.password,
        role: AccountRole.student,
        studentCode: 'DEV-SV001',
        curriculumVersionId: version.id!,
        admissionYear: 2026,
      );
    }
  }
}
