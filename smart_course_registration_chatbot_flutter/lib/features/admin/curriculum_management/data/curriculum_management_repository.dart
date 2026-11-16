import '../domain/managed_curriculum.dart';

/// Frontend interface, NOT proof that Backend RPC F07 exists.
/// A live Serverpod adapter must be implemented only after generated API review.
abstract class CurriculumManagementRepository {
  Future<List<ManagedCurriculum>> listCurriculums({String query = ''});

  Future<ManagedCurriculumVersionDetail> getVersionById(int versionId);

  /// Save a DRAFT only, subject to optimistic concurrency (expectedRevision).
  /// Published/archived structures must not be silently modified.
  Future<ManagedCurriculumVersionDetail> saveDraftVersion(
    ManagedCurriculumVersionDetail version, {
    required int expectedRevision,
  });
}
