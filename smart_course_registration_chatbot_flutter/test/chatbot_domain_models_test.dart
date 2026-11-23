import 'package:flutter_test/flutter_test.dart';

import 'package:smart_course_registration_chatbot_flutter/features/chat/domain/chatbot_conversation.dart';
import 'package:smart_course_registration_chatbot_flutter/features/chat/domain/chatbot_message.dart';
import 'package:smart_course_registration_chatbot_flutter/features/chat/domain/chatbot_related_course.dart';
import 'package:smart_course_registration_chatbot_flutter/features/chat/domain/chatbot_repository_exception.dart';
import 'package:smart_course_registration_chatbot_flutter/features/chat/domain/chatbot_response.dart';
import 'package:smart_course_registration_chatbot_flutter/features/chat/domain/chatbot_source.dart';

void main() {
  group('ChatbotMessage', () {
    test('identifies a student message', () {
      final message = ChatbotMessage(
        id: 'm1',
        conversationId: 'c1',
        role: ChatbotMessageRole.user,
        content: 'Xin tư vấn học phần',
        createdAt: DateTime.utc(2026, 11, 17),
      );
      expect(message.isFromUser, isTrue);
      expect(message.isFromAssistant, isFalse);
    });

    test('identifies an assistant message and evidence status', () {
      final message = ChatbotMessage(
        id: 'm2',
        conversationId: 'c1',
        role: ChatbotMessageRole.assistant,
        content: 'Tôi có thể hỗ trợ bạn.',
        createdAt: DateTime.utc(2026, 11, 17),
        evidenceStatus: ChatbotEvidenceStatus.supported,
      );
      expect(message.isFromAssistant, isTrue);
      expect(message.isFromUser, isFalse);
      expect(message.evidenceStatus, ChatbotEvidenceStatus.supported);
    });

    test('stores sources and related courses', () {
      const source = ChatbotSource(
        id: 's1',
        title: 'Chương trình đào tạo',
        sourceType: ChatbotSourceType.curriculum,
      );
      const course = ChatbotRelatedCourse(
        courseId: 12,
        courseCode: 'CS101',
        courseName: 'Nhập môn lập trình',
        credits: 3,
        reason: 'Phù hợp chương trình đào tạo',
      );
      final message = ChatbotMessage(
        id: 'm3',
        conversationId: 'c1',
        role: ChatbotMessageRole.assistant,
        content: 'Đây là học phần được đề xuất.',
        createdAt: DateTime.utc(2026, 11, 17),
        sources: const [source],
        relatedCourses: const [course],
      );
      expect(message.sources, hasLength(1));
      expect(message.relatedCourses, hasLength(1));
      expect(message.relatedCourses.first.courseId, 12);
    });
  });

  group('ChatbotConversation', () {
    test('stores conversation information', () {
      final conversation = ChatbotConversation(
        id: 'c1',
        title: 'Tư vấn học phần',
        createdAt: DateTime.utc(2026, 11, 17),
        updatedAt: DateTime.utc(2026, 11, 17),
        messageCount: 4,
        lastMessagePreview: 'Cảm ơn bạn.',
      );
      expect(conversation.id, 'c1');
      expect(conversation.messageCount, 4);
      expect(conversation.lastMessagePreview, 'Cảm ơn bạn.');
    });
  });

  group('ChatbotResponse', () {
    test('stores send-message result', () {
      final conversation = ChatbotConversation(
        id: 'c1',
        title: 'Tư vấn học tập',
        createdAt: DateTime.utc(2026, 11, 17),
        updatedAt: DateTime.utc(2026, 11, 17),
        messageCount: 2,
      );
      final userMessage = ChatbotMessage(
        id: 'm1',
        conversationId: 'c1',
        role: ChatbotMessageRole.user,
        content: 'Tôi cần tư vấn.',
        createdAt: DateTime.utc(2026, 11, 17),
      );
      final assistantMessage = ChatbotMessage(
        id: 'm2',
        conversationId: 'c1',
        role: ChatbotMessageRole.assistant,
        content: 'Tôi sẽ hỗ trợ bạn.',
        createdAt: DateTime.utc(2026, 11, 17),
      );
      final result = ChatbotSendMessageResult(
        conversation: conversation,
        userMessage: userMessage,
        assistantMessage: assistantMessage,
      );
      expect(result.conversation.id, 'c1');
      expect(result.userMessage.isFromUser, isTrue);
      expect(result.assistantMessage.isFromAssistant, isTrue);
    });

    test('stores conversation pagination', () {
      const page = ChatbotConversationPage(
        conversations: [],
        page: 1,
        pageSize: 20,
        total: 35,
        hasMore: true,
      );
      expect(page.page, 1);
      expect(page.total, 35);
      expect(page.hasMore, isTrue);
    });

    test('stores message pagination cursor', () {
      const page = ChatbotMessagePage(
        conversationId: 'c1',
        messages: [],
        nextCursor: 'cursor_001',
        hasMore: true,
      );
      expect(page.nextCursor, 'cursor_001');
      expect(page.hasMore, isTrue);
    });
  });

  group('ChatbotRepositoryException', () {
    test('stores failure code and retry state', () {
      const exception = ChatbotRepositoryException(
        code: ChatbotFailureCode.aiTimeout,
        message: 'AI phản hồi quá thời gian.',
        isRetryable: true,
      );
      expect(exception.code, ChatbotFailureCode.aiTimeout);
      expect(exception.isRetryable, isTrue);
      expect(exception.toString(), contains('AI phản hồi quá thời gian.'));
    });
  });
}
