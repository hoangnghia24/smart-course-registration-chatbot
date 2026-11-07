import 'package:smart_course_registration_chatbot_client/smart_course_registration_chatbot_client.dart';

import '../../academic_progress/data/academic_progress_repository.dart';
import '../../academic_progress/data/serverpod_academic_progress_repository.dart';
import '../../curriculum_lookup/data/curriculum_lookup_repository.dart';
import '../../curriculum_lookup/data/serverpod_curriculum_lookup_repository.dart';
import 'recommendation_repository.dart';

/// Adapter TẠM THỜI: chỉ phối hợp hai API hiện hữu F04 và F23.
/// Không gọi endpoint F24/F27 (chưa tồn tại), không tính tiên quyết, không xếp hạng.
class ServerpodRecommendationRepository implements RecommendationRepository {
  ServerpodRecommendationRepository(Client client)
      : this.fromRepositories(
          curriculum: ServerpodCurriculumLookupRepository(client),
          progress: ServerpodAcademicProgressRepository(client),
        );

  const ServerpodRecommendationRepository.fromRepositories({
    required this.curriculum,
    required this.progress,
  });

  final CurriculumLookupRepository curriculum;
  final AcademicProgressRepository progress;

  @override
  Future<RecommendationOverview?> getOverview() async {
    CurriculumDetails? curriculumDetails;
    AcademicProgressDetails? progressDetails;
    bool curriculumFailed = false;
    bool progressFailed = false;
    Object? firstError;

    // Một API lỗi mạng thì vẫn hiển thị dữ liệu thực từ API còn lại (nếu có).
    // Lỗi đăng nhập/quyền truy cập KHÔNG được che bằng dữ liệu bộ nhớ.
    try {
      curriculumDetails = await curriculum.getMyCurriculum();
    } catch (error) {
      if (_isAuthorizationError(error)) rethrow;
      curriculumFailed = true;
      firstError = error;
    }
    try {
      progressDetails = await progress.getMyProgress();
    } catch (error) {
      if (_isAuthorizationError(error)) rethrow;
      progressFailed = true;
      firstError ??= error;
    }

    if (curriculumFailed && progressFailed) {
      throw StateError('F04_AND_F23_FAILED: $firstError');
    }
    if (curriculumDetails == null && progressDetails == null) return null;

    // Chỉ dùng mã môn để đối chiếu trạng thái. Nếu trùng mã trong F23,
    // KHÔNG đoán trạng thái nào là chính xác.
    final progressByCode = <String, AcademicCourseProgress>{};
    final duplicateProgressCodes = <String>{};
    for (final item in progressDetails?.courses ?? <AcademicCourseProgress>[]) {
      final key = item.code.trim().toUpperCase();
      if (key.isEmpty) continue;
      if (progressByCode.containsKey(key)) duplicateProgressCodes.add(key);
      progressByCode[key] = item;
    }

    final output = <RecommendationCourse>[];
    if (curriculumDetails != null) {
      // Chỉ hiển thị các môn thuộc CTĐT do F04 trả về.
      for (final course in curriculumDetails.items) {
        final codeKey = course.code.trim().toUpperCase();
        final progressItem = duplicateProgressCodes.contains(codeKey)
            ? null : progressByCode[codeKey];
        output.add(RecommendationCourse(
          code: course.code,
          name: course.name,
          credits: course.credits,
          semester: course.semester,
          isRequired: course.isRequired,
          groupName: course.groupName,
          progressStatus: progressItem?.status,
          lastAcademicScore: progressItem?.scoreStatus == 'AVAILABLE'
              ? progressItem?.score : null,
          // TUYỆT ĐỐI không suy diễn eligibility từ NOT_STARTED/FAILED.
          eligibilityStatus: null,
          reasonCode: null,
          priorityRank: null,
        ));
      }
    } else {
      // Nếu F04 chưa gán CTĐT nhưng F23 có dữ liệu, hiển thị nguồn F23,
      // KHÔNG gọi đây là danh sách môn được phép đăng ký.
      for (final course in progressDetails?.courses ?? <AcademicCourseProgress>[]) {
        output.add(RecommendationCourse(
          code: course.code,
          name: course.name,
          credits: course.credits,
          semester: course.semester,
          isRequired: course.isRequired,
          groupName: course.groupName,
          progressStatus: course.status,
          lastAcademicScore: course.scoreStatus == 'AVAILABLE'
              ? course.score : null,
        ));
      }
    }

    final notes = <String>[];
    if (curriculumFailed) notes.add('Không tải được chương trình đào tạo F04.');
    if (progressFailed) notes.add('Không tải được tiến độ học tập F23.');
    if (curriculumDetails == null) notes.add('Chưa có thông tin CTĐT từ F04.');
    if (progressDetails == null) notes.add('Chưa có thông tin tiến độ từ F23.');
    if (duplicateProgressCodes.isNotEmpty) {
      notes.add('Một số mã môn trùng trong F23 nên trạng thái học tập chưa được ghép.');
    }

    return RecommendationOverview(
      courses: List.unmodifiable(output),
      hasCurriculum: curriculumDetails != null,
      hasProgress: progressDetails != null,
      curriculumName: curriculumDetails?.name,
      earnedCredits: progressDetails?.earnedCredits,
      totalCredits: progressDetails?.totalCredits,
      failedCourseCount: progressDetails?.courses
          .where((c) => c.status == 'FAILED')
          .length,
      curriculumVersion: curriculumDetails?.versionCode,
      partialMessage: notes.isEmpty ? null : notes.join(' '),
    );
  }
}

bool _isAuthorizationError(Object error) {
  final value = error.toString().toUpperCase();
  return value.contains('AUTH_REQUIRED') ||
      value.contains('UNAUTHENTICATED') ||
      value.contains('FORBIDDEN') ||
      value.contains('ACCOUNT_INACTIVE') ||
      value.contains('ACCOUNT_NOT_PROVISIONED');
}
