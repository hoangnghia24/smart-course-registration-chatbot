import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import '../security/account_guard.dart';
import '../services/ai/ai_service.dart';
import '../services/ai/rag_service.dart';

typedef ChatbotAnswerGenerator =
    Future<String> Function(
      Session session,
      String message,
    );

class ChatbotEndpoint extends Endpoint {
  ChatbotEndpoint({ChatbotAnswerGenerator? answerGenerator})
    : _answerGenerator = answerGenerator;

  final ChatbotAnswerGenerator? _answerGenerator;

  static Future<String> _generateAnswer(
    Session session,
    String question,
    int studentId,
  ) async {
    final student = await Student.db.findById(session, studentId);
    final version = student == null
        ? null
        : await CurriculumVersion.db.findById(
            session,
            student.curriculumVersionId,
          );
    final curriculum = version == null
        ? null
        : await Curriculum.db.findById(session, version.curriculumId);
    final program = _resolveRagProgram(curriculum, student?.studentCode);
    final cohort = _resolveRagCohort(student, version);
    final context = await RagService.instance().retrieve(
      question,
      defaultProgram: program,
      defaultCohort: cohort,
    );
    session.log(
      'RAG: program=${program ?? 'unknown'}, cohort=${cohort ?? 'unknown'}, '
      '${context.length} ký tự ngữ cảnh.',
      level: LogLevel.info,
    );

    if (_requiresRagClarification(context)) return context;
    return AiService.instance.generateAnswer(question, context);
  }

  static bool _requiresRagClarification(String context) =>
      context.startsWith('Chưa xác định được chương trình') ||
      context.startsWith('Chưa xác định được khóa') ||
      context.startsWith('Câu hỏi đang nhắc đến nhiều chương trình') ||
      context.startsWith('Dữ liệu RAG hiện chỉ hỗ trợ khóa');

  static String? _resolveRagProgram(
    Curriculum? curriculum,
    String? studentCode,
  ) {
    final curriculumCode = curriculum?.code.trim().toUpperCase();
    if (curriculumCode != null) {
      if (const {'CNTT', 'ATTT', 'KTDL', 'CNTT-JP'}.contains(curriculumCode)) {
        return curriculumCode;
      }
      if (curriculumCode.contains('CNTT') &&
          (curriculumCode.contains('JP') || curriculumCode.contains('NHAT'))) {
        return 'CNTT-JP';
      }
    }

    final majorCode = curriculum?.majorCode.trim();
    const programsByMajorCode = {
      '7480201': 'CNTT',
      '7480202': 'ATTT',
      '7480203': 'KTDL',
    };
    final programByMajor = programsByMajorCode[majorCode];
    if (programByMajor != null) return programByMajor;

    final normalizedStudentCode = studentCode?.trim();
    if (normalizedStudentCode != null &&
        RegExp(r'^\d{8}$').hasMatch(normalizedStudentCode) &&
        normalizedStudentCode.substring(2, 5) == '110') {
      return 'CNTT';
    }
    return null;
  }

  static int? _resolveRagCohort(
    Student? student,
    CurriculumVersion? version,
  ) {
    final admissionYear =
        student?.admissionYear ?? _admissionYearFromCode(student?.studentCode);
    if (admissionYear != null) {
      if (admissionYear >= 2026) return 2026;
      if (admissionYear >= 2023) return 2023;
    }

    final effectiveYear = version?.effectiveYear;
    return effectiveYear == 2023 || effectiveYear == 2026
        ? effectiveYear
        : null;
  }

  static int? _admissionYearFromCode(String? studentCode) {
    final value = studentCode?.trim();
    if (value == null || !RegExp(r'^\d{8}$').hasMatch(value)) return null;
    return 2000 + int.parse(value.substring(0, 2));
  }

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
    final answer = _answerGenerator == null
        ? await _generateAnswer(session, question, studentId)
        : await _answerGenerator(session, question);

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
