import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:smart_course_registration_chatbot_client/smart_course_registration_chatbot_client.dart';
import 'package:smart_course_registration_chatbot_flutter/features/chat/data/chatbot_error_mapper.dart';
import 'package:smart_course_registration_chatbot_flutter/features/chat/domain/chatbot_repository_exception.dart';

void main() {
  group('mapChatbotDataSourceError', () {
    test('maps AUTH_REQUIRED and HTTP 401 to unauthenticated', () {
      final fromApp = mapChatbotDataSourceError(
        AppException(code: 'AUTH_REQUIRED', message: 'Vui lòng đăng nhập.'),
      );
      expect(fromApp.code, ChatbotFailureCode.unauthenticated);
      expect(fromApp.isRetryable, isFalse);

      final fromClient = mapChatbotDataSourceError(
        ServerpodClientException('Unauthorized', HttpStatus.unauthorized),
      );
      expect(fromClient.code, ChatbotFailureCode.unauthenticated);
      expect(fromClient.isRetryable, isFalse);
    });

    test('maps FORBIDDEN and account status codes to forbidden', () {
      for (final code in [
        'FORBIDDEN',
        'ACCOUNT_INACTIVE',
        'ACCOUNT_NOT_PROVISIONED',
        'STUDENT_NOT_FOUND',
      ]) {
        final mapped = mapChatbotDataSourceError(
          AppException(code: code, message: 'Không có quyền.'),
        );
        expect(mapped.code, ChatbotFailureCode.forbidden);
        expect(mapped.isRetryable, isFalse);
      }

      final fromHttp = mapChatbotDataSourceError(
        ServerpodClientException('Forbidden', HttpStatus.forbidden),
      );
      expect(fromHttp.code, ChatbotFailureCode.forbidden);
      expect(fromHttp.isRetryable, isFalse);
    });

    test('maps validation error codes to validationError', () {
      for (final code in [
        'CHAT_MESSAGE_INVALID',
        'CHAT_CONVERSATION_INVALID',
        'AI_INVALID_INPUT',
      ]) {
        final mapped = mapChatbotDataSourceError(
          AppException(code: code, message: 'Câu hỏi không hợp lệ.'),
        );
        expect(mapped.code, ChatbotFailureCode.validationError);
        expect(mapped.isRetryable, isFalse);
      }
    });

    test('maps CHAT_CONVERSATION_NOT_FOUND to conversationNotFound', () {
      final mapped = mapChatbotDataSourceError(
        AppException(
          code: 'CHAT_CONVERSATION_NOT_FOUND',
          message: 'Không tìm thấy hội thoại.',
        ),
      );
      expect(mapped.code, ChatbotFailureCode.conversationNotFound);
      expect(mapped.isRetryable, isFalse);
    });

    test('maps AI_TIMEOUT from server as retryable aiTimeout', () {
      final mapped = mapChatbotDataSourceError(
        AppException(code: 'AI_TIMEOUT', message: 'Ollama phản hồi quá lâu.'),
      );
      expect(mapped.code, ChatbotFailureCode.aiTimeout);
      expect(mapped.isRetryable, isTrue);
    });

    test(
      'maps client-side TimeoutException as non-retryable to avoid duplicate DB persistence',
      () {
        final mapped = mapChatbotDataSourceError(
          TimeoutException('Client timeout after 20s'),
        );
        expect(mapped.code, ChatbotFailureCode.aiTimeout);
        expect(mapped.isRetryable, isFalse);
      },
    );

    test('maps AI unavailable codes with appropriate retryability', () {
      for (final code in ['AI_LOCAL_CONNECTION_ERROR', 'AI_LOCAL_API_ERROR']) {
        final mapped = mapChatbotDataSourceError(
          AppException(code: code, message: 'Ollama lỗi kết nối.'),
        );
        expect(mapped.code, ChatbotFailureCode.aiUnavailable);
        expect(mapped.isRetryable, isTrue);
      }

      for (final code in [
        'AI_MODEL_NOT_FOUND',
        'AI_LOCAL_CONFIG_ERROR',
        'AI_INVALID_RESPONSE',
      ]) {
        final mapped = mapChatbotDataSourceError(
          AppException(code: code, message: 'Cấu hình AI lỗi.'),
        );
        expect(mapped.code, ChatbotFailureCode.aiUnavailable);
        expect(mapped.isRetryable, isFalse);
      }
    });

    test('maps RAG error codes to contextUnavailable', () {
      for (final code in [
        'RAG_FILE_NOT_FOUND',
        'RAG_FILE_EMPTY',
        'RAG_FILE_INVALID',
        'RAG_DUPLICATE_ID',
      ]) {
        final mapped = mapChatbotDataSourceError(
          AppException(code: code, message: 'Lỗi dữ liệu RAG.'),
        );
        expect(mapped.code, ChatbotFailureCode.contextUnavailable);
        expect(mapped.isRetryable, isFalse);
      }
    });

    test('maps SocketException and status <= 0 to networkUnavailable', () {
      final fromSocket = mapChatbotDataSourceError(
        const SocketException('Connection refused'),
      );
      expect(fromSocket.code, ChatbotFailureCode.networkUnavailable);
      expect(fromSocket.isRetryable, isTrue);

      final fromClient = mapChatbotDataSourceError(
        ServerpodClientException('SocketException', -1),
      );
      expect(fromClient.code, ChatbotFailureCode.networkUnavailable);
      expect(fromClient.isRetryable, isTrue);
    });

    test('maps unknown AppException or HTTP 500 to internalError', () {
      final fromApp = mapChatbotDataSourceError(
        AppException(code: 'UNEXPECTED_CODE', message: 'Lỗi máy chủ.'),
      );
      expect(fromApp.code, ChatbotFailureCode.internalError);
      expect(fromApp.isRetryable, isFalse);

      final fromHttp = mapChatbotDataSourceError(
        ServerpodClientException('Server error', HttpStatus.internalServerError),
      );
      expect(fromHttp.code, ChatbotFailureCode.internalError);
      expect(fromHttp.isRetryable, isFalse);
    });
  });
}
