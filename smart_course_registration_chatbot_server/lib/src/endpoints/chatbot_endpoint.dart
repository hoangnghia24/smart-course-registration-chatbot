import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import '../security/account_guard.dart';
import '../services/ai/local_llm_chat_service_qwen35.dart';

typedef ChatbotAnswerGenerator =
    Future<String> Function(
      Session session,
      String message,
    );

class ChatbotEndpoint extends Endpoint {
  ChatbotEndpoint({ChatbotAnswerGenerator? answerGenerator})
    : _answerGenerator = answerGenerator ?? LocalLlmChatService.sendMessage;

  final ChatbotAnswerGenerator _answerGenerator;

  @override
  bool get requireLogin => true;

  /// Hàm để sinh viên gửi câu hỏi.
  Future<String> sendMessage(
    Session session,
    String message,
    int? conversationId,
    String? clientRequestId,
  ) async {
    return _send(
      session,
      message,
      conversationId: conversationId,
      clientRequestId: clientRequestId,
    );
  }

  /// Hàm private xử lý câu hỏi.
  Future<String> _send(
    Session session,
    String message, {
    required int? conversationId,
    required String? clientRequestId,
  }) async {
    // clientRequestId là một phần của contract để client theo dõi request.
    // Đặc tả hiện tại chưa yêu cầu lưu hoặc dùng nó để khử trùng lặp.
    clientRequestId;

    // 1. Kiểm tra nội dung trước khi truy vấn database hoặc gọi AI.
    final question = message.trim();

    if (question.isEmpty || question.runes.length > 2000) {
      throw AppException(
        code: 'CHAT_MESSAGE_INVALID',
        message: 'Tin nhắn phải có từ 1 đến 2000 ký tự.',
      );
    }

    if (conversationId != null && conversationId <= 0) {
      throw AppException(
        code: 'CHAT_CONVERSATION_INVALID',
        message: 'ID hội thoại không hợp lệ.',
      );
    }

    // 2. Xác thực sinh viên và kiểm tra quyền sở hữu hội thoại cũ.
    final studentId = await AccountGuard.requireStudentId(session);
    if (conversationId != null) {
      await _requireOwnedConversation(
        session,
        conversationId,
        studentId,
      );
    }

    // 3. Gọi Local LLM thông qua Ollama trước transaction để không giữ
    // transaction database trong lúc chờ tác vụ mạng có thể kéo dài.
    // Không sử dụng Gemini API.
    final answer = await _answerGenerator(
      session,
      question,
    );

    // 4. Chỉ khi AI trả lời thành công mới lưu trọn vẹn lượt trao đổi.
    await session.db.transaction((transaction) async {
      final now = DateTime.now().toUtc();
      late final ChatbotConversation conversation;

      if (conversationId == null) {
        conversation = await ChatbotConversation.db.insertRow(
          session,
          ChatbotConversation(
            studentId: studentId,
            title: _buildTitle(question),
            createdAt: now,
            updatedAt: now,
          ),
          transaction: transaction,
        );
      } else {
        // Kiểm tra lại trong transaction để không ghi vào hội thoại đã bị
        // xóa hoặc đổi quyền sở hữu giữa lúc AI đang xử lý.
        conversation = await _requireOwnedConversation(
          session,
          conversationId,
          studentId,
          transaction: transaction,
        );
        conversation.updatedAt = now;
        await ChatbotConversation.db.updateRow(
          session,
          conversation,
          columns: (t) => [t.updatedAt],
          transaction: transaction,
        );
      }

      final savedConversationId = conversation.id!;
      await ChatbotMessage.db.insert(
        session,
        [
          ChatbotMessage(
            conversationId: savedConversationId,
            role: ChatbotMessageRole.user,
            content: question,
            createdAt: now,
          ),
          ChatbotMessage(
            conversationId: savedConversationId,
            role: ChatbotMessageRole.assistant,
            content: answer,
            createdAt: now,
          ),
        ],
        transaction: transaction,
      );
    });

    return answer;
  }

  Future<ChatbotConversation> _requireOwnedConversation(
    Session session,
    int conversationId,
    int studentId, {
    Transaction? transaction,
  }) async {
    final conversation = await ChatbotConversation.db.findFirstRow(
      session,
      where: (t) => t.id.equals(conversationId) & t.studentId.equals(studentId),
      transaction: transaction,
    );

    if (conversation == null) {
      throw AppException(
        code: 'CHAT_CONVERSATION_NOT_FOUND',
        message: 'Không tìm thấy hội thoại.',
      );
    }

    return conversation;
  }

  String _buildTitle(String message) {
    const maxTitleLength = 80;
    final characters = message.runes.toList(growable: false);
    if (characters.length <= maxTitleLength) return message;

    return '${String.fromCharCodes(characters.take(maxTitleLength))}…';
  }
}
