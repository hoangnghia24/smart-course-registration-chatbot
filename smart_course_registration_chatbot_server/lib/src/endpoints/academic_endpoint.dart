import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import '../security/account_guard.dart';
import '../services/academic_progress_service.dart';

class AcademicEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  Future<AcademicProgressDto?> getMyProgress(
    Session session,
  ) async {
    // 1. Xac thuc va kiem tra quyen Student
    final account = await AccountGuard.requireRole(
      session,
      allowedRoles: {AccountRole.student},
    );

    // 2. Tim Student cua tai khoan hien tai
    final student = await Student.db.findFirstRow(
      session,
      where: (t) => t.userAccountId.equals(account.id!),
    );

    if (student == null) return null;

    // 3. Goi service tong hop tien do hoc tap
    return AcademicProgressService.getProgress(
      session,
      student,
    );
  }
}
