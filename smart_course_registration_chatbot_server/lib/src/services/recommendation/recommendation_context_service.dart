import 'package:serverpod/serverpod.dart';

import '../../generated/protocol.dart';
import '../../security/account_guard.dart';

/// Chỉ backend được xác định studentId và danh sách môn thuộc CTĐT.
/// Không nhận studentId, curriculumVersionId hoặc courseIds từ Flutter.
class RecommendationContext {
  final int studentId;
  final String studentCode;
  final int termId;
  final String termName;
  final String academicYear;
  final String curriculumName;
  final String versionCode;
  final String versionStatus;
  final Set<int> curriculumCourseIds;
  final Set<int> requiredCourseIds;
  final List<int> openPhases;

  const RecommendationContext({
    required this.studentId,
    required this.studentCode,
    required this.termId,
    required this.termName,
    required this.academicYear,
    required this.curriculumName,
    required this.versionCode,
    required this.versionStatus,
    required this.curriculumCourseIds,
    required this.requiredCourseIds,
    required this.openPhases,
  });
}

class RecommendationContextService {
  const RecommendationContextService._();

  static Future<RecommendationContext> resolve(Session session) async {
    final account = await AccountGuard.requireRole(
      session,
      allowedRoles: {AccountRole.student},
    );
    if (account.id == null) {
      throw AppException(
        code: 'F24_ACCOUNT_INVALID',
        message: 'Tài khoản đăng nhập chưa có ID hợp lệ.',
      );
    }

    final student = await Student.db.findFirstRow(
      session,
      where: (t) => t.userAccountId.equals(account.id!),
    );
    if (student == null || student.id == null) {
      throw AppException(
        code: 'F24_STUDENT_NOT_FOUND',
        message: 'Tài khoản chưa liên kết với hồ sơ sinh viên.',
      );
    }

    final version = await CurriculumVersion.db.findById(
      session,
      student.curriculumVersionId,
    );
    if (version == null) {
      throw AppException(
        code: 'F24_VERSION_NOT_FOUND',
        message: 'Không tìm thấy phiên bản CTĐT của sinh viên.',
      );
    }
    final curriculum = await Curriculum.db.findById(
      session,
      version.curriculumId,
    );
    if (curriculum == null) {
      throw AppException(
        code: 'F24_CURRICULUM_NOT_FOUND',
        message: 'Không tìm thấy CTĐT của sinh viên.',
      );
    }

    final items = await CurriculumItem.db.find(
      session,
      where: (t) => t.curriculumVersionId.equals(student.curriculumVersionId),
    );
    if (items.isEmpty) {
      throw AppException(
        code: 'F24_CURRICULUM_EMPTY',
        message: 'Phiên bản CTĐT chưa có học phần.',
      );
    }

    // ACTIVE là trạng thái học kỳ do nhà trường thiết lập;
    // không tự đoán từ ngày hiện tại hay từ mã học kỳ.
    final activeTerms = await AcademicTerm.db.find(
      session,
      where: (t) => t.status.equals('ACTIVE'),
    );
    if (activeTerms.isEmpty) {
      throw AppException(
        code: 'F24_NO_ACTIVE_TERM',
        message: 'Chưa có học kỳ ACTIVE. Quản trị viên cần cấu hình học kỳ.',
      );
    }
    if (activeTerms.length != 1 || activeTerms.single.id == null) {
      throw AppException(
        code: 'F24_ACTIVE_TERM_AMBIGUOUS',
        message: 'Hệ thống cần đúng một học kỳ ACTIVE có ID hợp lệ.',
      );
    }
    final term = activeTerms.single;

    final openSections = await CourseSection.db.find(
      session,
      where: (t) =>
          t.termId.equals(term.id!) & t.status.equals('OPEN'),
    );
    final phases = openSections
        .map((s) => s.teachingPhase)
        .where((phase) => phase == 1 || phase == 2)
        .toSet()
        .toList()
      ..sort();

    return RecommendationContext(
      studentId: student.id!,
      studentCode: student.studentCode,
      termId: term.id!,
      termName: term.termName,
      academicYear: term.academicYear,
      curriculumName: curriculum.name,
      versionCode: version.versionCode,
      versionStatus: version.status,
      curriculumCourseIds: items.map((item) => item.courseId).toSet(),
      requiredCourseIds: items
          .where((item) => item.isRequired)
          .map((item) => item.courseId)
          .toSet(),
      openPhases: phases,
    );
  }
}
