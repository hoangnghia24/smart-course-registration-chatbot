import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import '../security/account_guard.dart';
import '../services/chatbot/gemini_chat_service.dart';
import '../services/recommendation/course_recommendation_service.dart';
import '../services/recommendation/recommendation_context_service.dart';

class ChatbotEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  /// Giữ nguyên API của Flutter: client.chatbot.sendMessage(message).
  Future<String> sendMessage(Session session, String message) async =>
      _send(session, message);

  Future<String> _send(Session session, String message) async {
    // Xác thực ở mọi nhánh, kể cả khi chỉ hỏi gợi ý môn.
    await AccountGuard.requireRole(
      session,
      allowedRoles: {AccountRole.student},
    );

    final question = message.trim();
    if (question.isEmpty || question.length > 2000) {
      throw AppException(
        code: 'CHAT_MESSAGE_INVALID',
        message: 'Tin nhắn phải có từ 1 đến 2000 ký tự.',
      );
    }

    if (!_isRecommendationQuestion(question)) {
      return GeminiChatService.sendMessage(session, question);
    }

    // F24 dùng kết quả Rule Engine, không cho Gemini suy luận thay.
    try {
      final context = await RecommendationContextService.resolve(session);
      if (context.openPhases.isEmpty) {
        return 'Học kỳ ${context.termName} (${context.academicYear}) '
            'chưa có lớp học phần trạng thái OPEN. '
            'F24 chưa thể gợi ý môn để đăng ký.';
      }

      final explicitPhase = _requestedPhase(question);
      final phases = explicitPhase == null
          ? context.openPhases
          : <int>[explicitPhase];
      final output = StringBuffer(
        'Gợi ý môn theo CTĐT ${context.curriculumName}, '
        'phiên bản ${context.versionCode}, '
        'học kỳ ${context.termName} (${context.academicYear}).\n',
      );
      if (context.versionStatus.toUpperCase() != 'ACTIVE') {
        output.writeln('Lưu ý: Phiên bản CTĐT có trạng thái '
            '${context.versionStatus}; dữ liệu có thể là DEMO/DRAFT.');
      }
      for (final phase in phases) {
        if (!context.openPhases.contains(phase)) {
          output.writeln('\nĐợt $phase: Không có lớp OPEN để gợi ý.');
          continue;
        }
        final result = await CourseRecommendationService.recommend(
          session,
          studentId: context.studentId,
          termId: context.termId,
          teachingPhase: phase,
          curriculumCourseIds: context.curriculumCourseIds,
          requiredCourseIds: context.requiredCourseIds,
        );
        output.writeln('\n${_formatRecommendation(result)}');
      }
      if (phases.length > 1) {
        output.writeln('Các gợi ý theo từng đợt là độc lập; không được '
            'đăng ký trùng một môn ở hai đợt trong cùng học kỳ.');
      }
      output.writeln('Gợi ý sơ bộ, chưa kiểm tra xung đột thời khóa biểu, '
          'hạn mức tín chỉ, hạn đăng ký, quy tắc tự chọn và hạn công bố điểm.');
      return output.toString();
    } on AppException catch (e) {
      // Trả lỗi cấu hình F24 thành thông báo dễ hiểu trong chatbot;
      // giữ nguyên các lỗi bảo mật khác.
      if (e.code.startsWith('F24_')) return e.message;
      rethrow;
    }
  }

  bool _isRecommendationQuestion(String question) {
    final q = question.toLowerCase();
    return const [
      'gợi ý môn',
      'gợi ý học phần',
      'tư vấn môn',
      'nên đăng ký môn',
      'đăng ký môn nào',
      'nên học môn nào',
      'học môn nào',
      'môn nào nên đăng ký',
      'đề xuất môn',
      'đề xuất học phần',
    ].any(q.contains);
  }

  int? _requestedPhase(String question) {
    final match = RegExp(r'(?:đợt|dot|phase)\s*([12])', caseSensitive: false)
        .firstMatch(question);
    return match == null ? null : int.parse(match.group(1)!);
  }

  String _formatRecommendation(RecommendationResult result) {
    final courses = result.recommendations;
    final output = StringBuffer('Đợt ${result.teachingPhase}: ');
    if (courses.isEmpty) {
      output.writeln('Không có môn đủ điều kiện gợi ý sơ bộ.');
    } else {
      output.writeln('${courses.length} môn được xếp hạng sơ bộ:');
      for (final course in courses.take(10)) {
        output.writeln('• Nhóm ưu tiên ${course.priorityGroup}: '
            '${course.courseCode} - ${course.courseName} '
            '(${course.credits} TC, '
            '${course.isRetake ? 'học lại' : 'không phải học lại'}, '
            '${course.dependentCount} môn phụ thuộc). '
            'Lớp còn chỗ: ${course.sectionIds.join(', ')}.');
      }
      if (courses.length > 10) {
        output.writeln('Còn ${courses.length - 10} môn khác; '
            'xem toàn bộ bằng API recommendation.getMyRecommendations.');
      }
    }
    final unconfiguredElectives = result.excluded
        .where((course) => course.reasons.contains('ELECTIVE_RULES_NOT_CONFIGURED'))
        .length;
    if (unconfiguredElectives > 0) {
      output.writeln('$unconfiguredElectives ứng viên môn tự chọn '
          'chưa được gợi ý tự động do chưa cấu hình hạn mức nhóm.');
    }
    return output.toString();
  }
}
