import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import '../security/account_guard.dart';
import '../services/chatbot/gemini_chat_service.dart';
class ChatbotEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  /// Hàm để sinh viên gửi câu hỏi
  Future<String> sendMessage(Session session, String message) async {
    return _send(session, message);
  }
  /// Hàm private xử lý phản hồi tin nhắn từ chatbot cho sinh viên
  Future<String> _send(
    Session session,
    String message,
  ) async {
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
    return GeminiChatService.sendMessage(session, question);
  }
}
