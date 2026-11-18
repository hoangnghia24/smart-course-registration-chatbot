import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import '../security/account_guard.dart';
import '../services/curriculum/curriculum_admin_service.dart';

/// F07 - API quan tri CTDT / phien ban / lien ket sinh vien.
/// Tat ca phuong thuc chi danh cho Admin.
class CurriculumAdminEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  Future<int> _admin(Session session) => AccountGuard.requireAdminId(session);

  // ---- CTDT ----

  Future<List<AdminCurriculumDto>> listCurriculums(
    Session session,
    String query,
  ) async {
    await _admin(session);
    return CurriculumAdminService.listCurriculums(session, query: query);
  }

  Future<AdminCurriculumDto> createCurriculum(
    Session session,
    String code,
    String name,
    String majorCode,
  ) async {
    final actorId = await _admin(session);
    return CurriculumAdminService.createCurriculum(
      session,
      actorId: actorId,
      code: code,
      name: name,
      majorCode: majorCode,
    );
  }

  // ---- Phien ban ----

  Future<AdminCurriculumVersionDetailDto> createDraftVersion(
    Session session,
    int curriculumId,
    String versionCode,
    int effectiveYear,
    int? copyFromVersionId,
  ) async {
    final actorId = await _admin(session);
    return CurriculumAdminService.createDraftVersion(
      session,
      actorId: actorId,
      curriculumId: curriculumId,
      versionCode: versionCode,
      effectiveYear: effectiveYear,
      copyFromVersionId: copyFromVersionId,
    );
  }

  Future<AdminCurriculumVersionDetailDto> getVersion(
    Session session,
    int versionId,
  ) async {
    await _admin(session);
    return CurriculumAdminService.getVersionDetail(session, versionId);
  }

  Future<AdminCurriculumVersionDetailDto> saveDraftVersion(
    Session session,
    CurriculumDraftInput input,
  ) async {
    final actorId = await _admin(session);
    return CurriculumAdminService.saveDraft(
      session,
      actorId: actorId,
      input: input,
    );
  }

  Future<AdminCurriculumVersionDetailDto> publishVersion(
    Session session,
    int versionId,
    int expectedRevision,
  ) async {
    final actorId = await _admin(session);
    return CurriculumAdminService.publishVersion(
      session,
      actorId: actorId,
      versionId: versionId,
      expectedRevision: expectedRevision,
    );
  }

  Future<AdminCurriculumVersionDetailDto> archiveVersion(
    Session session,
    int versionId,
  ) async {
    final actorId = await _admin(session);
    return CurriculumAdminService.archiveVersion(
      session,
      actorId: actorId,
      versionId: versionId,
    );
  }

  Future<bool> deleteDraftVersion(Session session, int versionId) async {
    final actorId = await _admin(session);
    return CurriculumAdminService.deleteDraftVersion(
      session,
      actorId: actorId,
      versionId: versionId,
    );
  }

  // ---- Chon phien ban theo nam hieu luc ----

  /// Xem truoc phien ban se gan cho sinh vien CTDT [curriculumCode]
  /// nhap hoc nam [admissionYear]; null neu chua co phien ban phu hop.
  Future<AdminCurriculumVersionSummaryDto?> previewVersionForAdmission(
    Session session,
    String curriculumCode,
    int admissionYear,
  ) async {
    await _admin(session);
    return CurriculumAdminService.previewVersionForAdmission(
      session,
      curriculumCode: curriculumCode,
      admissionYear: admissionYear,
    );
  }

  // ---- Sinh vien ----

  Future<StudentCurriculumAssignmentDto> getStudentAssignment(
    Session session,
    String studentCode,
  ) async {
    await _admin(session);
    return CurriculumAdminService.getStudentAssignment(session, studentCode);
  }

  Future<StudentCurriculumAssignmentDto> changeStudentVersion(
    Session session,
    String studentCode,
    int versionId,
    String reason,
  ) async {
    final actorId = await _admin(session);
    return CurriculumAdminService.changeStudentVersion(
      session,
      actorId: actorId,
      studentCode: studentCode,
      versionId: versionId,
      reason: reason,
    );
  }

  Future<StudentCurriculumAssignmentDto> setStudentAdmissionYear(
    Session session,
    String studentCode,
    int admissionYear,
  ) async {
    final actorId = await _admin(session);
    return CurriculumAdminService.setStudentAdmissionYear(
      session,
      actorId: actorId,
      studentCode: studentCode,
      admissionYear: admissionYear,
    );
  }
}
