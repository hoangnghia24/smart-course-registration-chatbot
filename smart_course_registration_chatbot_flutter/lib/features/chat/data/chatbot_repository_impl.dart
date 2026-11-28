import '../domain/chatbot_repository_exception.dart';
import '../domain/chatbot_response.dart';
import 'chatbot_data_source.dart';
import 'chatbot_data_source_exception.dart';
import 'chatbot_repository.dart';

/// Repository implementation that keeps callers independent from the
/// underlying data source (fake today, Serverpod adapter when its API exists).
class ChatbotRepositoryImpl implements ChatbotRepository {
  const ChatbotRepositoryImpl({
    required ChatbotDataSource dataSource,
  }) : _dataSource = dataSource;

  final ChatbotDataSource _dataSource;

  @override
  Future<ChatbotSendMessageResult> sendMessage({
    required String message,
    String? conversationId,
    String? clientRequestId,
  }) {
    final normalizedMessage = message.trim();
    if (normalizedMessage.isEmpty) {
      throw const ChatbotRepositoryException(
        code: ChatbotFailureCode.validationError,
        message: 'Nội dung tin nhắn không được để trống.',
      );
    }
    if (normalizedMessage.length > 2000) {
      throw const ChatbotRepositoryException(
        code: ChatbotFailureCode.validationError,
        message: 'Nội dung tin nhắn không được vượt quá 2000 ký tự.',
      );
    }
    if (conversationId != null && conversationId.trim().isEmpty) {
      throw const ChatbotRepositoryException(
        code: ChatbotFailureCode.validationError,
        message: 'Mã hội thoại không hợp lệ.',
      );
    }

    return _execute(
      () => _dataSource.sendMessage(
        message: normalizedMessage,
        conversationId: conversationId,
        clientRequestId: clientRequestId,
      ),
      fallbackMessage: 'Không thể gửi tin nhắn chatbot.',
    );
  }

  @override
  Future<ChatbotConversationPage> getConversations({
    int page = 1,
    int pageSize = 20,
  }) {
    if (page < 1 || pageSize < 1) {
      throw const ChatbotRepositoryException(
        code: ChatbotFailureCode.validationError,
        message: 'Số trang và kích thước trang phải lớn hơn 0.',
      );
    }

    return _execute(
      () => _dataSource.getConversations(page: page, pageSize: pageSize),
      fallbackMessage: 'Không thể tải danh sách hội thoại.',
    );
  }

  @override
  Future<ChatbotMessagePage> getMessages({
    required String conversationId,
    String? cursor,
    int limit = 30,
  }) {
    if (conversationId.trim().isEmpty || limit < 1) {
      throw const ChatbotRepositoryException(
        code: ChatbotFailureCode.validationError,
        message: 'Mã hội thoại hoặc số lượng tin nhắn không hợp lệ.',
      );
    }

    return _execute(
      () => _dataSource.getMessages(
        conversationId: conversationId,
        cursor: cursor,
        limit: limit,
      ),
      fallbackMessage: 'Không thể tải lịch sử hội thoại.',
    );
  }

  @override
  Future<void> deleteConversation({
    required String conversationId,
  }) {
    if (conversationId.trim().isEmpty) {
      throw const ChatbotRepositoryException(
        code: ChatbotFailureCode.validationError,
        message: 'Mã hội thoại không hợp lệ.',
      );
    }

    return _execute(
      () => _dataSource.deleteConversation(conversationId: conversationId),
      fallbackMessage: 'Không thể xóa hội thoại.',
    );
  }

  Future<T> _execute<T>(
    Future<T> Function() action, {
    required String fallbackMessage,
  }) async {
    try {
      return await action();
    } on ChatbotDataSourceException catch (error) {
      throw ChatbotRepositoryException(
        code: error.code,
        message: error.message,
        isRetryable: error.isRetryable,
        cause: error.cause ?? error,
      );
    } on ChatbotRepositoryException {
      rethrow;
    } catch (error) {
      throw ChatbotRepositoryException(
        code: ChatbotFailureCode.unknown,
        message: fallbackMessage,
        cause: error,
      );
    }
  }
}
