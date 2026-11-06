/// Dữ liệu hiển thị F23 được ánh xạ từ API AcademicProgressDto.
/// Các số liệu không có từ backend giữ null, KHÔNG gán giá trị mẫu.
class AcademicProgressDetails {
  const AcademicProgressDetails({
    this.curriculumVersionId,
    this.totalCredits,
    this.earnedCredits,
    this.remainingCredits,
    required this.creditStatus,
    this.gpa,
    required this.gpaStatus,
    required this.courses,
  });

  final int? curriculumVersionId;
  final int? totalCredits;
  final int? earnedCredits;
  final int? remainingCredits;
  final String creditStatus;
  final double? gpa;
  final String gpaStatus;
  final List<AcademicCourseProgress> courses;
}

class AcademicCourseProgress {
  const AcademicCourseProgress({
    required this.code,
    required this.name,
    required this.credits,
    this.semester,
    required this.isRequired,
    this.groupCode,
    this.groupName,
    this.groupOrder,
    this.itemOrder,
    required this.status,
    this.statusDetail,
    this.score,
    required this.scoreStatus,
  });

  final String code;
  final String name;
  final int credits;
  final int? semester;
  final bool isRequired;
  final String? groupCode;
  final String? groupName;
  final int? groupOrder;
  final int? itemOrder;
  /// PASSED / FAILED / IN_PROGRESS / NOT_STARTED.
  final String status;
  final String? statusDetail;
  final double? score;
  /// AVAILABLE / NOT_PUBLISHED / NO_DATA / POLICY_PENDING.
  final String scoreStatus;
}

abstract class AcademicProgressRepository {
  /// Null khi chưa đủ quan hệ sinh viên-CTĐT/dữ liệu hợp lệ theo backend.
  Future<AcademicProgressDetails?> getMyProgress();
}
