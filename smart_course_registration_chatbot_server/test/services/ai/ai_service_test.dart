import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:smart_course_registration_chatbot_server/src/services/ai/ai_service.dart';
import 'package:test/test.dart';

void main() {
  test('limits chatbot scope to course selection and registration', () async {
    late Map<String, dynamic> requestBody;
    final service = AiService(
      client: MockClient((request) async {
        requestBody = jsonDecode(request.body) as Map<String, dynamic>;
        return http.Response.bytes(
          utf8.encode(
            jsonEncode({
              'message': {'content': 'Câu trả lời học vụ'},
            }),
          ),
          200,
          headers: const {'content-type': 'application/json; charset=utf-8'},
        );
      }),
    );

    await service.generateAnswer(
      'Tại sao nên chọn học phần này?',
      '[CNTT 2023] Học phần kiểm thử',
    );

    final messages = requestBody['messages'] as List;
    final systemPrompt =
        (messages.first as Map<String, dynamic>)['content'] as String;
    expect(systemPrompt, contains('PHẠM VI DUY NHẤT'));
    expect(systemPrompt, contains('Không tư vấn nghề nghiệp'));
    expect(systemPrompt, contains('Không hỏi sinh viên muốn làm nghề gì'));
    expect(systemPrompt, contains('hướng dẫn đăng ký'));
    expect(systemPrompt, contains('Giải thích vì sao nên chọn'));
  });
}
