import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import '../security/account_guard.dart';
import '../services/chatbot/gemini_chat_service.dart';

class ChatbotEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  /// Hàm để sinh viên gửi câu hỏi
  Future<String> sendMessage(
    Session session,
    String message,
  ) async {
    return _send(session, message);
  }

  /// Hàm private xử lý câu hỏi
  Future<String> _send(
    Session session,
    String message,
  ) async {
    // Xác thực và kiểm tra vai trò sinh viên
    await AccountGuard.requireRole(
      session,
      allowedRoles: {AccountRole.student},
    );

    // Kiểm tra nội dung câu hỏi
    final question = message.trim();

    if (question.isEmpty || question.length > 2000) {
      throw AppException(
        code: 'CHAT_MESSAGE_INVALID',
        message: 'Tin nhắn phải có từ 1 đến 2000 ký tự.',
      );
    }

    // Chưa có dữ liệu để gợi ý môn học cá nhân
    if (_isRecommendationQuestion(question)) {
      return 'Hiện tại hệ thống chưa có đủ dữ liệu '
          'học tập và chương trình đào tạo của bạn '
          'để đưa ra danh sách môn học phù hợp. '
          'Chức năng gợi ý sẽ hoạt động khi dữ liệu '
          'được cập nhật và kiểm tra bởi hệ thống F24.';
    }

    // Các câu hỏi thông thường gửi đến Gemini
    return GeminiChatService.sendMessage(session, question);
  }

  /// Nhận diện yêu cầu gợi ý môn học
  bool _isRecommendationQuestion(String question) {
    final text = question.toLowerCase();

    return const [
      'gợi ý môn',
      'gợi ý học phần',
      'tư vấn môn',
      'nên đăng ký môn',
      'đăng ký môn nào',
      'nên học môn nào',
      'học môn nào',
      'đề xuất môn',
      'đề xuất học phần',
    ].any(text.contains);
  }
}
