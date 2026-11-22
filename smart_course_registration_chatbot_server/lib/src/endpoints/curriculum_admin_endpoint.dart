import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import '../security/account_guard.dart';
import '../services/curriculum/curriculum_admin_service.dart';

/// API Admin CTDT chi doc. Khong cung cap cac ham tao/sua/xoa/gan CTDT.
/// CHU Y: thay the endpoint cu va chay serverpod generate.
class CurriculumAdminEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  Future<void> _requireAdmin(Session session) async {
    await AccountGuard.requireAdminId(session);
  }

  Future<List<AdminCurriculumDto>> listCurriculums(
    Session session,
    String query,
  ) async {
    await _requireAdmin(session);
    return CurriculumAdminService.listCurriculums(session, query: query);
  }

  Future<AdminCurriculumVersionDetailDto> getVersion(
    Session session,
    int versionId,
  ) async {
    await _requireAdmin(session);
    return CurriculumAdminService.getVersionDetail(session, versionId);
  }

  /// Chi xem phien ban phu hop theo khoa, khong thuc hien gan.
  Future<AdminCurriculumVersionSummaryDto?> previewVersionForAdmission(
    Session session,
    String curriculumCode,
    int admissionYear,
  ) async {
    await _requireAdmin(session);
    return CurriculumAdminService.previewVersionForAdmission(
      session,
      curriculumCode: curriculumCode,
      admissionYear: admissionYear,
    );
  }

  /// Chi xem phien ban dang gan cho sinh vien.
  Future<StudentCurriculumAssignmentDto> getStudentAssignment(
    Session session,
    String studentCode,
  ) async {
    await _requireAdmin(session);
    return CurriculumAdminService.getStudentAssignment(session, studentCode);
  }
}
