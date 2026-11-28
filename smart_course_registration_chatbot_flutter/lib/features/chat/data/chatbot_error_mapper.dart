import 'dart:async';
import 'dart:io';

import 'package:smart_course_registration_chatbot_client/smart_course_registration_chatbot_client.dart';

import '../domain/chatbot_repository_exception.dart';
import 'chatbot_data_source_exception.dart';

/// Ánh xạ lỗi từ Serverpod Client / AppException sang [ChatbotDataSourceException].
///
/// Tuân thủ nguyên tắc an toàn dữ liệu:
/// - Không tự động retry những lỗi mà Backend có thể đã nhận và lưu vào PostgreSQL
///   (ví dụ client hết thời gian chờ 20s trong khi Ollama ở server vẫn xử lý tiếp).
/// - Chỉ đánh dấu `isRetryable: true` khi chắc chắn server chưa lưu dữ liệu hoặc
///   server đã chủ động dừng trước transaction ghi DB.
ChatbotDataSourceException mapChatbotDataSourceError(
  Object error, {
  String fallbackMessage = 'Đã xảy ra lỗi hệ thống. Vui lòng thử lại sau.',
}) {
  if (error is ChatbotDataSourceException) {
    return error;
  }

  if (error is AppException) {
    return _mapAppException(error, fallbackMessage: fallbackMessage);
  }

  if (error is ServerpodClientException) {
    return _mapServerpodClientException(
      error,
      fallbackMessage: fallbackMessage,
    );
  }

  if (error is SocketException) {
    return ChatbotDataSourceException(
      code: ChatbotFailureCode.networkUnavailable,
      message: 'Mất kết nối mạng. Vui lòng kiểm tra kết nối và thử lại.',
      isRetryable: true,
      cause: error,
    );
  }

  if (error is TimeoutException) {
    // Client-side timeout (mặc định 20s của ServerpodClient) có thể xảy ra
    // trong khi server vẫn tiếp tục đợi Ollama (tối đa 180s) và ghi vào DB sau đó.
    // Không đánh dấu retry tự động hoặc khuyến khích bấm gửi lại cùng request.
    return ChatbotDataSourceException(
      code: ChatbotFailureCode.aiTimeout,
      message:
          'Yêu cầu xử lý quá thời gian chờ kết nối. Hệ thống có thể vẫn đang xử lý câu hỏi của bạn.',
      isRetryable: false,
      cause: error,
    );
  }

  return ChatbotDataSourceException(
    code: ChatbotFailureCode.internalError,
    message: fallbackMessage,
    isRetryable: false,
    cause: error,
  );
}

ChatbotDataSourceException _mapAppException(
  AppException error, {
  required String fallbackMessage,
}) {
  final serverMessage = error.message.trim();
  switch (error.code) {
    case 'AUTH_REQUIRED':
      return ChatbotDataSourceException(
        code: ChatbotFailureCode.unauthenticated,
        message: 'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.',
        isRetryable: false,
        cause: error,
      );

    case 'FORBIDDEN':
    case 'ACCOUNT_INACTIVE':
    case 'ACCOUNT_NOT_PROVISIONED':
    case 'STUDENT_NOT_FOUND':
      return ChatbotDataSourceException(
        code: ChatbotFailureCode.forbidden,
        message: serverMessage.isNotEmpty
            ? serverMessage
            : 'Bạn không có quyền truy cập chức năng tư vấn học vụ này.',
        isRetryable: false,
        cause: error,
      );

    case 'CHAT_MESSAGE_INVALID':
    case 'CHAT_CONVERSATION_INVALID':
    case 'AI_INVALID_INPUT':
      return ChatbotDataSourceException(
        code: ChatbotFailureCode.validationError,
        message: serverMessage.isNotEmpty
            ? serverMessage
            : 'Câu hỏi hoặc mã hội thoại không hợp lệ.',
        isRetryable: false,
        cause: error,
      );

    case 'CHAT_CONVERSATION_NOT_FOUND':
      return ChatbotDataSourceException(
        code: ChatbotFailureCode.conversationNotFound,
        message: serverMessage.isNotEmpty
            ? serverMessage
            : 'Cuộc hội thoại không tồn tại hoặc không thuộc tài khoản của bạn.',
        isRetryable: false,
        cause: error,
      );

    case 'AI_TIMEOUT':
      // AI_TIMEOUT do AiService ném ra TRƯỚC transaction lưu DB, nên server
      // chưa lưu gì vào PostgreSQL -> sinh viên có thể bấm gửi lại thủ công.
      return ChatbotDataSourceException(
        code: ChatbotFailureCode.aiTimeout,
        message:
            'AI xử lý quá thời gian cho phép. Vui lòng thử gửi lại câu hỏi.',
        isRetryable: true,
        cause: error,
      );

    case 'AI_LOCAL_CONNECTION_ERROR':
    case 'AI_LOCAL_API_ERROR':
      return ChatbotDataSourceException(
        code: ChatbotFailureCode.aiUnavailable,
        message:
            'Trợ lý AI hiện không khả dụng. Vui lòng thử lại sau ít phút.',
        isRetryable: true,
        cause: error,
      );

    case 'AI_MODEL_NOT_FOUND':
    case 'AI_LOCAL_CONFIG_ERROR':
    case 'AI_INVALID_RESPONSE':
      return ChatbotDataSourceException(
        code: ChatbotFailureCode.aiUnavailable,
        message:
            'Trợ lý AI chưa sẵn sàng hoặc phản hồi không hợp lệ. Vui lòng thử lại sau.',
        isRetryable: false,
        cause: error,
      );

    case 'RAG_FILE_NOT_FOUND':
    case 'RAG_FILE_EMPTY':
    case 'RAG_FILE_INVALID':
    case 'RAG_DUPLICATE_ID':
      return ChatbotDataSourceException(
        code: ChatbotFailureCode.contextUnavailable,
        message:
            'Dữ liệu tra cứu chương trình đào tạo hiện chưa sẵn sàng.',
        isRetryable: false,
        cause: error,
      );

    default:
      return ChatbotDataSourceException(
        code: ChatbotFailureCode.internalError,
        message: serverMessage.isNotEmpty ? serverMessage : fallbackMessage,
        isRetryable: false,
        cause: error,
      );
  }
}

ChatbotDataSourceException _mapServerpodClientException(
  ServerpodClientException error, {
  required String fallbackMessage,
}) {
  if (error.statusCode == HttpStatus.unauthorized) {
    return ChatbotDataSourceException(
      code: ChatbotFailureCode.unauthenticated,
      message: 'Bạn chưa đăng nhập hoặc phiên đăng nhập đã hết hạn.',
      isRetryable: false,
      cause: error,
    );
  }

  if (error.statusCode == HttpStatus.forbidden) {
    return ChatbotDataSourceException(
      code: ChatbotFailureCode.forbidden,
      message: 'Bạn không có quyền truy cập chức năng này.',
      isRetryable: false,
      cause: error,
    );
  }

  if (error.statusCode <= 0) {
    return ChatbotDataSourceException(
      code: ChatbotFailureCode.networkUnavailable,
      message:
          'Không thể kết nối tới máy chủ. Vui lòng kiểm tra mạng và thử lại.',
      isRetryable: true,
      cause: error,
    );
  }

  return ChatbotDataSourceException(
    code: ChatbotFailureCode.internalError,
    message: fallbackMessage,
    isRetryable: false,
    cause: error,
  );
}
