import 'dart:convert';
import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import '../services/recommendation/course_recommendation_service.dart';
import '../services/recommendation/recommendation_context_service.dart';

/// F24 cho Flutter: luôn lấy sinh viên/CTĐT từ session đăng nhập.
/// Trả JSON qua String vì RecommendationResult không phải model .spy.yaml.
class RecommendationEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  Future<String> getMyRecommendations(
    Session session,
    int teachingPhase,
  ) async {
    if (teachingPhase != 1 && teachingPhase != 2) {
      throw AppException(
        code: 'F24_PHASE_INVALID',
        message: 'Đợt học chỉ nhận 1 hoặc 2.',
      );
    }
    final context = await RecommendationContextService.resolve(session);
    if (!context.openPhases.contains(teachingPhase)) {
      throw AppException(
        code: 'F24_NO_OPEN_SECTIONS',
        message: 'Học kỳ đang xét chưa có lớp OPEN ở đợt $teachingPhase.',
      );
    }
    final result = await CourseRecommendationService.recommend(
      session,
      studentId: context.studentId,
      termId: context.termId,
      teachingPhase: teachingPhase,
      curriculumCourseIds: context.curriculumCourseIds,
      requiredCourseIds: context.requiredCourseIds,
    );
    return jsonEncode({
      'status': 'PRELIMINARY',
      'studentCode': context.studentCode,
      'curriculumName': context.curriculumName,
      'versionCode': context.versionCode,
      'versionStatus': context.versionStatus,
      'academicYear': context.academicYear,
      'termName': context.termName,
      'termId': context.termId,
      'teachingPhase': teachingPhase,
      'totalCandidates': context.curriculumCourseIds.length,
      'requiredCandidates': context.requiredCourseIds.length,
      'warnings': [
        'Chưa phải kết quả đăng ký chính thức.',
        'Chưa kiểm tra trùng lịch, hạn tín chỉ và thời hạn đăng ký.',
        'Chưa cấu hình hạn mức tự chọn theo nhóm.',
        'Cần xác minh độ đầy đủ của bảng tiên quyết và thời hạn công bố điểm.',
      ],
      'result': result.toJson(),
    });
  }
}
