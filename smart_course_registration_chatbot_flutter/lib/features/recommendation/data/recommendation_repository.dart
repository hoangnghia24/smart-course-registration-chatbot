/// Mô hình ổn định cho UI F24/F27. Chỉ backend được quyền kết luận
/// eligibility/priority. DTO Serverpod thay đổi không được truyền trực tiếp
/// xuống màn hình.
class RecommendationCourse {
  const RecommendationCourse({
    required this.code,
    required this.name,
    this.courseId,
    this.credits,
    this.semester,
    this.isRequired,
    this.groupName,
    this.progressStatus,
    this.eligibilityStatus,
    this.eligible,
    this.reasonCode,
    this.reasonCodes = const [],
    this.explanations = const [],
    this.priorityRank,
    this.score,
    this.availableClassCount,
    this.lastAcademicScore,
  });

  final int? courseId;
  final String code;
  final String name;
  final int? credits;
  /// Học kỳ gợi ý trong chương trình đào tạo, không phải semesterId thực.
  final int? semester;
  final bool? isRequired;
  final String? groupName;
  /// PASSED / FAILED / IN_PROGRESS / NOT_STARTED từ F23 (nếu có).
  final String? progressStatus;
  /// Chỉ hiển thị nguyên trạng thái do BE cung cấp, không suy ra từ F23.
  final String? eligibilityStatus;
  /// true/false/null chỉ từ kết quả F24 chính thức.
  final bool? eligible;
  /// Tương thích cấu trúc cũ dùng một reason code.
  final String? reasonCode;
  /// Các mã lý do của Rule Engine, không tự diễn giải thành điều kiện.
  final List<String> reasonCodes;
  /// Mô tả giải thích do BE cung cấp; không tự tạo từ mã.
  final List<String> explanations;
  /// Số thứ tự ưu tiên do BE xác định, không dùng groupOrder/itemOrder.
  final int? priorityRank;
  final num? score;
  /// null khi BE chưa có dữ liệu lớp, KHÔNG được coi là không có lớp.
  final int? availableClassCount;
  /// Điểm học phần từ F23 (không phải score xếp hạng F27).
  final double? lastAcademicScore;
}

class RecommendationOverview {
  const RecommendationOverview({
    required this.courses,
    required this.hasCurriculum,
    required this.hasProgress,
    this.curriculumName,
    this.curriculumVersion,
    this.partialMessage,
    this.isOfficialRecommendation = false,
    this.semesterId,
    this.policyVersion,
    this.calculatedAt,
    this.earnedCredits,
    this.totalCredits,
    this.failedCourseCount,
  });

  final List<RecommendationCourse> courses;
  final bool hasCurriculum;
  final bool hasProgress;
  final String? curriculumName;
  final String? curriculumVersion;
  final String? partialMessage;
  /// Chỉ true khi nguồn là API Rule Engine F24/F27 thật.
  final bool isOfficialRecommendation;
  final int? semesterId;
  final String? policyVersion;
  final DateTime? calculatedAt;
  /// Tín chỉ do F23 cung cấp; nếu không tính được, giữ null.
  final int? earnedCredits;
  final int? totalCredits;
  /// Tổng số môn chưa đạt từ F23/BE; không suy ra từ F24 danh sách gợi ý.
  final int? failedCourseCount;

  bool get hasRuleEngineResult => isOfficialRecommendation || courses.any(
        (c) => c.eligible != null || c.eligibilityStatus != null ||
            c.reasonCode != null || c.reasonCodes.isNotEmpty ||
            c.priorityRank != null,
      );
}

abstract class RecommendationRepository {
  Future<RecommendationOverview?> getOverview();
}
