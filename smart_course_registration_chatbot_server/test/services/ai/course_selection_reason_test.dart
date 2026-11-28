import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:smart_course_registration_chatbot_server/src/services/ai/ai_service.dart';
import 'package:smart_course_registration_chatbot_server/src/services/ai/rag_service.dart';
import 'package:test/test.dart';

void main() {
  test('reason search prefers the teaching plan and exact course', () async {
    final temp = await Directory.systemTemp.createTemp('reason-rag-');
    try {
      final service = RagService(
        embeddingCachePath: '${temp.path}/missing.json',
        aiService: AiService(client: MockClient((request) async {
          fail('Structured reason retrieval must not require embedding');
        })),
      );
      final result = await service.retrieve(
        'Tại sao nên chọn môn Lập trình Web ngành CNTT khóa 2026 kỳ 5?',
      );
      expect(result, contains('[CNTT 2026]'));
      expect(result, isNot(contains('[CNTT 2023]')));
      expect(result, contains('WEPR330479'));
      expect(result, contains('OOPR230279'));
      expect(result, contains('Học kỳ 5'));
      expect(result, contains('Mã MH trước, MH tiên quyết'));
      expect(result, isNot(contains('PLO1 PLO2')));
      final semester = await service.retrieve(
        'Tôi nên đăng ký những môn nào kỳ 5?',
        defaultProgram: 'CNTT', defaultCohort: 2026,
      );
      expect(semester, contains('WEPR330479'));
      expect(semester, contains('DBMS330284'));
      expect(semester, contains('Tổng 24'));
      expect(semester, isNot(contains('[CNTT 2023]')));
      expect(semester, isNot(contains('PLO1 PLO2')));
    } finally {
      await temp.delete(recursive: true);
    }
  });

  test('answer prompt requests grounded explanations and preserves F24', () async {
    late Map<String, dynamic> body;
    final service = AiService(client: MockClient((request) async {
      body = jsonDecode(request.body) as Map<String, dynamic>;
      return http.Response.bytes(utf8.encode(jsonEncode({
        'message': {'content': 'Lý do theo kế hoạch học kỳ.'},
      })), 200);
    }));
    await service.generateAnswer('Tại sao nên chọn môn đó?', 'CTĐT kiểm thử');
    final messages = body['messages'] as List;
    final prompt = messages.first['content'] as String;
    expect(prompt, contains('lý do học vụ cụ thể'));
    expect(prompt, contains('Không tự tạo reasonCode'));
    expect(prompt, contains('không phải bảng kế hoạch đăng ký'));
    expect(prompt, contains('Không suy ra đã học qua'));
    expect(messages.last['content'], contains('CTĐT kiểm thử'));
  });
}
