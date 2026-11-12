
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:serverpod/serverpod.dart';

import '../../generated/protocol.dart';

class GeminiChatService {
  static const String _model = 'gemini-3.5-flash-lite';

  // Quy tắc phản hồi của chatbot
  static const String _systemPrompt = '''
Bạn là trợ lý học vụ trong ứng dụng đăng ký môn học thông minh.
Trả lời bằng tiếng Việt, rõ ràng, thân thiện, chính xác.
Không tự suy đoán điểm số, điều kiện tiên quyết,
môn học đang mở hoặc môn đủ điều kiện đăng ký.
Khi sinh viên hỏi nên đăng ký môn nào, hãy giải thích
rằng cần kiểm tra dữ liệu từ Rule Engine ở backend.
''';

  // Gửi câu hỏi và nhận phản hồi từ Gemini
  static Future<String> sendMessage(
    Session session,
    String message,
  ) async {
    // Lấy API key từ backend
    final apiKey = session.passwords['geminiApiKey']?.trim();

    if (apiKey == null || apiKey.isEmpty) {
      throw AppException(
        code: 'AI_NOT_CONFIGURED',
        message: 'Chưa cấu hình Gemini API key.',
      );
    }

    // Địa chỉ Gemini API
    final uri = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/'
      'models/$_model:generateContent',
    );

    // Gửi yêu cầu đến Gemini
    late final http.Response response;

    try {
      response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'x-goog-api-key': apiKey,
        },
        body: jsonEncode({
          'systemInstruction': {
            'parts': [
              {'text': _systemPrompt},
            ],
          },
          'contents': [
            {
              'role': 'user',
              'parts': [
                {'text': message},
              ],
            },
          ],
          'generationConfig': {
            'maxOutputTokens': 1024,
          },
        }),
      ).timeout(const Duration(seconds: 45));
    } on TimeoutException {
      throw AppException(
        code: 'AI_TIMEOUT',
        message: 'Gemini phản hồi quá lâu.',
      );
    } on SocketException {
      throw AppException(
        code: 'AI_CONNECTION_ERROR',
        message: 'Không thể kết nối Gemini.',
      );
    } on http.ClientException {
      throw AppException(
        code: 'AI_CONNECTION_ERROR',
        message: 'Không thể kết nối Gemini.',
      );
    }

    // Kiểm tra lỗi từ API
    if (response.statusCode != 200) {
      throw AppException(
        code: response.statusCode == 429
            ? 'AI_RATE_LIMIT'
            : 'AI_API_ERROR',
        message: response.statusCode == 429
            ? 'Gemini đã hết hạn mức hoặc đang giới hạn lượt gọi.'
            : 'Gemini API lỗi (HTTP ${response.statusCode}).',
      );
    }

    // Đọc dữ liệu JSON trả về
    try {
      final data = jsonDecode(
        utf8.decode(response.bodyBytes),
      ) as Map<String, dynamic>;

      final candidates = data['candidates'] as List?;
      if (candidates == null || candidates.isEmpty) {
        throw const FormatException('Không có candidates');
      }

      final content = candidates.first['content'] as Map;
      final parts = content['parts'] as List;

      final answer = parts
          .where((part) => part is Map && part['thought'] != true)
          .map((part) => part['text'])
          .whereType<String>()
          .join('\n')
          .trim();

      if (answer.isEmpty) {
        throw const FormatException('Phản hồi rỗng');
      }

      return answer;
    } on FormatException catch (_) {
      throw AppException(
        code: 'AI_INVALID_RESPONSE',
        message: 'Gemini chưa trả về nội dung hợp lệ.',
      );
    } on TypeError catch (_) {
      throw AppException(
        code: 'AI_INVALID_RESPONSE',
        message: 'Gemini trả về dữ liệu không đúng định dạng.',
      );
    }
  }
}
