import 'package:smart_course_registration_chatbot_flutter/features/chat/data/chatbot_repository.dart';
import 'package:smart_course_registration_chatbot_flutter/features/chat/data/chatbot_repository_impl.dart';
import 'package:smart_course_registration_chatbot_flutter/features/chat/data/fake_chatbot_data_source.dart';
import 'package:smart_course_registration_chatbot_flutter/features/chat/domain/chatbot_conversation.dart';
import 'package:smart_course_registration_chatbot_flutter/features/chat/domain/chatbot_message.dart';
import 'package:smart_course_registration_chatbot_flutter/features/chat/domain/chatbot_response.dart';

typedef SendMessageCallback = Future<ChatbotSendMessageResult> Function({
  required String message,
  String? conversationId,
  String? clientRequestId,
});

typedef GetConversationsCallback = Future<ChatbotConversationPage> Function({
  required int page,
  required int pageSize,
});

typedef GetMessagesCallback = Future<ChatbotMessagePage> Function({
  required String conversationId,
  required String? cursor,
  required int limit,
});

typedef DeleteConversationCallback = Future<void> Function({
  required String conversationId,
});

/// Repository có thể thay từng response để kiểm thử loading và race condition.
/// Các thao tác không được override sẽ chuyển tiếp sang FakeChatbotDataSource.
class TestChatbotRepository implements ChatbotRepository {
  TestChatbotRepository({ChatbotRepository? fallback})
      : _fallback = fallback ??
            ChatbotRepositoryImpl(dataSource: FakeChatbotDataSource());

  final ChatbotRepository _fallback;

  SendMessageCallback? onSendMessage;
  GetConversationsCallback? onGetConversations;
  GetMessagesCallback? onGetMessages;
  DeleteConversationCallback? onDeleteConversation;

  int sendMessageCalls = 0;
  int getConversationsCalls = 0;
  int getMessagesCalls = 0;
  int deleteConversationCalls = 0;

  final List<String?> sentConversationIds = <String?>[];
  final List<String> requestedConversationIds = <String>[];
  final List<String?> requestedMessageCursors = <String?>[];

  @override
  Future<ChatbotSendMessageResult> sendMessage({
    required String message,
    String? conversationId,
    String? clientRequestId,
  }) {
    sendMessageCalls += 1;
    sentConversationIds.add(conversationId);
    final handler = onSendMessage;
    if (handler != null) {
      return handler(
        message: message,
        conversationId: conversationId,
        clientRequestId: clientRequestId,
      );
    }
    return _fallback.sendMessage(
      message: message,
      conversationId: conversationId,
      clientRequestId: clientRequestId,
    );
  }

  @override
  Future<ChatbotConversationPage> getConversations({
    int page = 1,
    int pageSize = 20,
  }) {
    getConversationsCalls += 1;
    final handler = onGetConversations;
    if (handler != null) {
      return handler(page: page, pageSize: pageSize);
    }
    return _fallback.getConversations(page: page, pageSize: pageSize);
  }

  @override
  Future<ChatbotMessagePage> getMessages({
    required String conversationId,
    String? cursor,
    int limit = 30,
  }) {
    getMessagesCalls += 1;
    requestedConversationIds.add(conversationId);
    requestedMessageCursors.add(cursor);
    final handler = onGetMessages;
    if (handler != null) {
      return handler(
        conversationId: conversationId,
        cursor: cursor,
        limit: limit,
      );
    }
    return _fallback.getMessages(
      conversationId: conversationId,
      cursor: cursor,
      limit: limit,
    );
  }

  @override
  Future<void> deleteConversation({required String conversationId}) {
    deleteConversationCalls += 1;
    final handler = onDeleteConversation;
    if (handler != null) return handler(conversationId: conversationId);
    return _fallback.deleteConversation(conversationId: conversationId);
  }
}

ChatbotConversation testConversation(
  String id, {
  String? title,
  DateTime? createdAt,
  DateTime? updatedAt,
  int messageCount = 2,
}) {
  final created = createdAt ?? DateTime.utc(2026, 11, 17);
  return ChatbotConversation(
    id: id,
    title: title ?? 'Hội thoại $id',
    createdAt: created,
    updatedAt: updatedAt ?? created,
    messageCount: messageCount,
  );
}

ChatbotMessage testMessage(
  String id,
  String conversationId,
  String content, {
  ChatbotMessageRole role = ChatbotMessageRole.assistant,
  DateTime? createdAt,
}) {
  return ChatbotMessage(
    id: id,
    conversationId: conversationId,
    role: role,
    content: content,
    createdAt: createdAt ?? DateTime.utc(2026, 11, 17),
  );
}

ChatbotSendMessageResult testSendResult(
  String conversationId, {
  String message = 'Xin tư vấn học phần',
  String answer = 'Đây là phản hồi kiểm thử.',
  DateTime? createdAt,
}) {
  final time = createdAt ?? DateTime.utc(2026, 11, 17);
  final conversation = testConversation(
    conversationId,
    title: message,
    createdAt: time,
    updatedAt: time,
    messageCount: 2,
  );
  return ChatbotSendMessageResult(
    conversation: conversation,
    userMessage: testMessage(
      '$conversationId-user-1',
      conversationId,
      message,
      role: ChatbotMessageRole.user,
      createdAt: time,
    ),
    assistantMessage: testMessage(
      '$conversationId-assistant-1',
      conversationId,
      answer,
      createdAt: time.add(const Duration(seconds: 1)),
    ),
  );
}

ChatbotMessagePage testMessagePage(
  String conversationId,
  List<ChatbotMessage> messages, {
  String? nextCursor,
  bool hasMore = false,
}) {
  return ChatbotMessagePage(
    conversationId: conversationId,
    messages: messages,
    nextCursor: nextCursor,
    hasMore: hasMore,
  );
}
