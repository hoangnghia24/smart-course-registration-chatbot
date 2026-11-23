import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import '../security/account_guard.dart';
import '../services/curriculum/curriculum_read_service.dart';

/// Chi sinh vien duoc doc CTDT dang duoc gan cho tai khoan cua minh.
class StudentEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  // Giu nguyen ten API va DTO de Flutter khong phai thay doi.
  Future<CurriculumDetailsDto?> getMyCurriculum(Session session) async {
    final account = await AccountGuard.requireRole(
      session,
      allowedRoles: {AccountRole.student},
    );

    final student = await Student.db.findFirstRow(
      session,
      where: (t) => t.userAccountId.equals(account.id!),
    );
    if (student == null) return null;

    // Student khong duoc tu chon versionId.
    final snapshot = await CurriculumReadService.getByVersion(
      session,
      student.curriculumVersionId,
    );
    return snapshot?.toStudentDto();
  }
}
