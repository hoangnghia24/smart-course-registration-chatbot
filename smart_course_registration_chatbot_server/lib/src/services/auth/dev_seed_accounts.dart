import 'dart:io';

import 'package:serverpod/serverpod.dart';

import '../../generated/protocol.dart';
import 'school_account_provisioner.dart';

/// Run only from a local post-migration initializer.
class DevSeedAccounts {
  static Future<void> run(Session session) async {
    if (Platform.environment['APP_ENV'] != 'development' ||
        Platform.environment['ALLOW_DEV_SEED'] != 'true') {
      return;
    }

    String secret(String key) {
      final value = Platform.environment[key];
      if (value == null || value.isEmpty) {
        throw StateError('Chưa cấu hình biến môi trường $key.');
      }
      return value;
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
            status: 'DEMO',
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
            status: 'DEMO',
          ),
        );

    Future<void> createIfAbsent({
      required String email,
      required String password,
      required AccountRole role,
      String? studentCode,
      int? curriculumVersionId,
      String? lecturerCode,
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
      );
    }

    await createIfAbsent(
      email: secret('SEED_ADMIN_EMAIL'),
      password: secret('SEED_ADMIN_PASSWORD'),
      role: AccountRole.admin,
    );
    await createIfAbsent(
      email: secret('SEED_LECTURER_EMAIL'),
      password: secret('SEED_LECTURER_PASSWORD'),
      role: AccountRole.lecturer,
      lecturerCode: 'DEV-GV001',
    );
    await createIfAbsent(
      email: secret('SEED_STUDENT_EMAIL'),
      password: secret('SEED_STUDENT_PASSWORD'),
      role: AccountRole.student,
      studentCode: 'DEV-SV001',
      curriculumVersionId: version.id!,
    );
  }
}
