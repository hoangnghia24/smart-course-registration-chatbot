import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import '../security/account_guard.dart';
import '../services/ai/local_llm_chat_service_qwen35.dart';

class ChatbotEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  /// Hàm để sinh viên gửi câu hỏi.
  Future<String> sendMessage(
    Session session,
    String message,
  ) async {
    return _send(session, message);
  }

  /// Hàm private xử lý câu hỏi.
  Future<String> _send(
    Session session,
    String message,
  ) async {
    // 1. Xác thực và kiểm tra vai trò sinh viên.
    await AccountGuard.requireRole(
      session,
      allowedRoles: {AccountRole.student},
    );

    // 2. Kiểm tra nội dung câu hỏi.
    final question = message.trim();

    if (question.isEmpty || question.length > 2000) {
      throw AppException(
        code: 'CHAT_MESSAGE_INVALID',
        message: 'Tin nhắn phải có từ 1 đến 2000 ký tự.',
      );
    }

    // 3. Gọi Local LLM thông qua Ollama.
    // Không sử dụng Gemini API.
    final answer = await LocalLlmChatService.sendMessage(
      session,
      question,
    );

    return answer;
  }
}
