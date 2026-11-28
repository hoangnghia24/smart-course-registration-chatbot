import 'package:smart_course_registration_chatbot_client/smart_course_registration_chatbot_client.dart';

import '../domain/chatbot_conversation.dart';
import '../domain/chatbot_message.dart' as domain;
import '../domain/chatbot_repository_exception.dart';
import '../domain/chatbot_response.dart';
import 'chatbot_data_source.dart';
import 'chatbot_data_source_exception.dart';
import 'chatbot_error_mapper.dart';

/// Chữ ký RPC tương ứng với `client.chatbot.sendMessage`.
typedef ChatbotSendMessageRpc = Future<String> Function(
  String message,
  int? conversationId,
  String? clientRequestId,
);

/// Adapter kết nối FE-08 với `EndpointChatbot` của Serverpod.
///
/// Đặc điểm theo contract Backend hiện tại:
/// - `client.chatbot.sendMessage(message, conversationId, clientRequestId)`
///   trả về `Future<String>` (chỉ văn bản câu trả lời).
/// - Backend chưa trả về `conversationId` của PostgreSQL trong response và
///   chưa nạp lịch sử nhiều lượt vào prompt AI/RAG.
/// - Không tự bịa `conversationId` kiểu số để gửi lên Server. Các ID hội thoại
///   cục bộ ở Flutter (bắt đầu bằng `localSessionConversationPrefix`) chỉ dùng
///   để nhóm tin nhắn trên giao diện trong RAM và luôn được ánh xạ thành `null`
///   khi gọi RPC trừ khi có ID số dương thực sự từ Backend.
/// - Không tự tạo dữ liệu học vụ, nguồn trích dẫn (`sources`), học phần liên quan
///   (`relatedCourses`) hay trạng thái căn cứ (`evidenceStatus`).
class ServerpodChatbotDataSource implements ChatbotDataSource {
  ServerpodChatbotDataSource(
    Client client, {
    DateTime Function()? clock,
  }) : this.fromRpc(
          sendMessageRpc: client.chatbot.sendMessage,
          clock: clock,
        );

  ServerpodChatbotDataSource.fromRpc({
    required ChatbotSendMessageRpc sendMessageRpc,
    DateTime Function()? clock,
  })  : _sendMessageRpc = sendMessageRpc,
        _clock = clock ?? DateTime.now;

  /// Tiền tố phân biệt rõ ID hội thoại trong RAM của Flutter với ID số của PostgreSQL.
  static const String localSessionConversationPrefix = 'local-ram-session-';
  static const String defaultLocalConversationId =
      '${localSessionConversationPrefix}active';

  final ChatbotSendMessageRpc _sendMessageRpc;
  final DateTime Function() _clock;

  int _localMessageSequence = 0;

  /// Phân tích `conversationId` ở tầng domain sang `int?` của PostgreSQL.
  ///
  /// - Trả về `null` nếu là `null` hoặc là ID phiên RAM cục bộ (`local-ram-session-*`).
  /// - Trả về `int` dương nếu chuỗi là số nguyên dương hợp lệ (sẵn sàng khi
  ///   Backend nâng cấp trả về `conversationId` thật).
  /// - Ném lỗi `validationError` nếu truyền ID không hợp lệ để không gửi ID giả.
  static int? resolveBackendConversationId(String? conversationId) {
    if (conversationId == null) return null;
    final trimmed = conversationId.trim();
    if (trimmed.isEmpty) {
      throw const ChatbotDataSourceException(
        code: ChatbotFailureCode.validationError,
        message: 'Mã hội thoại không hợp lệ.',
      );
    }
    if (trimmed.startsWith(localSessionConversationPrefix)) {
      return null;
    }
    final parsed = int.tryParse(trimmed);
    if (parsed == null || parsed <= 0) {
      throw const ChatbotDataSourceException(
        code: ChatbotFailureCode.validationError,
        message: 'Mã hội thoại không hợp lệ.',
      );
    }
    return parsed;
  }

  @override
  Future<ChatbotSendMessageResult> sendMessage({
    required String message,
    String? conversationId,
    String? clientRequestId,
  }) async {
    final normalizedMessage = message.trim();
    if (normalizedMessage.isEmpty || normalizedMessage.runes.length > 2000) {
      throw const ChatbotDataSourceException(
        code: ChatbotFailureCode.validationError,
        message: 'Tin nhắn phải có từ 1 đến 2000 ký tự.',
      );
    }

    final backendConversationId = resolveBackendConversationId(conversationId);

    late final String rawAnswer;
    try {
      rawAnswer = await _sendMessageRpc(
        normalizedMessage,
        backendConversationId,
        clientRequestId,
      );
    } catch (error) {
      throw mapChatbotDataSourceError(error);
    }

    final answer = rawAnswer.trim();
    if (answer.isEmpty) {
      throw const ChatbotDataSourceException(
        code: ChatbotFailureCode.aiUnavailable,
        message: 'Trợ lý AI chưa trả về nội dung hợp lệ.',
        isRetryable: false,
      );
    }

    final now = _clock();
    final uiConversationId = backendConversationId != null
        ? '$backendConversationId'
        : (conversationId?.trim().isNotEmpty == true
            ? conversationId!.trim()
            : defaultLocalConversationId);

    final userMessageId = 'local-msg-${++_localMessageSequence}';
    final assistantMessageId = 'local-msg-${++_localMessageSequence}';

    final userMessage = domain.ChatbotMessage(
      id: userMessageId,
      conversationId: uiConversationId,
      role: domain.ChatbotMessageRole.user,
      content: normalizedMessage,
      createdAt: now,
    );

    final assistantMessage = domain.ChatbotMessage(
      id: assistantMessageId,
      conversationId: uiConversationId,
      role: domain.ChatbotMessageRole.assistant,
      content: answer,
      createdAt: now,
    );

    final conversation = ChatbotConversation(
      id: uiConversationId,
      title: _buildTitle(normalizedMessage),
      createdAt: now,
      updatedAt: now,
      messageCount: 2,
      lastMessagePreview: answer,
    );

    return ChatbotSendMessageResult(
      conversation: conversation,
      userMessage: userMessage,
      assistantMessage: assistantMessage,
    );
  }

  @override
  Future<ChatbotConversationPage> getConversations({
    int page = 1,
    int pageSize = 20,
  }) async {
    if (page < 1 || pageSize < 1) {
      throw const ChatbotDataSourceException(
        code: ChatbotFailureCode.validationError,
        message: 'Tham số phân trang không hợp lệ.',
      );
    }
    // Backend hiện không cung cấp API lấy danh sách lịch sử hội thoại,
    // và nghiệp vụ FE-08 chỉ duy trì một hội thoại trong RAM của phiên hiện tại.
    return ChatbotConversationPage(
      conversations: const [],
      page: page,
      pageSize: pageSize,
      total: 0,
      hasMore: false,
    );
  }

  @override
  Future<ChatbotMessagePage> getMessages({
    required String conversationId,
    String? cursor,
    int limit = 30,
  }) async {
    if (conversationId.trim().isEmpty || limit < 1) {
      throw const ChatbotDataSourceException(
        code: ChatbotFailureCode.validationError,
        message: 'Tham số truy vấn lịch sử tin nhắn không hợp lệ.',
      );
    }
    return ChatbotMessagePage(
      conversationId: conversationId.trim(),
      messages: const [],
      hasMore: false,
      nextCursor: null,
    );
  }

  @override
  Future<void> deleteConversation({
    required String conversationId,
  }) async {
    if (conversationId.trim().isEmpty) {
      throw const ChatbotDataSourceException(
        code: ChatbotFailureCode.validationError,
        message: 'Mã hội thoại không được để trống.',
      );
    }
    // Backend không có endpoint xóa hội thoại trong PostgreSQL.
  }

  static String _buildTitle(String message) {
    const maxTitleLength = 80;
    final characters = message.runes.toList(growable: false);
    if (characters.length <= maxTitleLength) return message;
    return '${String.fromCharCodes(characters.take(maxTitleLength))}…';
  }
}
