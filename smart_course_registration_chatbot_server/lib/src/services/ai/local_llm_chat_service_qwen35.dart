import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:serverpod/serverpod.dart';

import '../../generated/protocol.dart';

/// LLM chat chạy cục bộ qua Ollama.
/// Giữ chữ ký sendMessage(Session, String) để endpoint hiện tại
/// ít phải thay đổi nhất.
class LocalLlmChatService {
  static const String _ragFilePath = 'config/ctdt_rag.jsonl';

  static const String _systemPrompt = '''
Bạn là trợ lý học vụ thông minh của hệ thống
Smart Course Registration Chatbot.

Nhiệm vụ của bạn là hỗ trợ sinh viên tra cứu,
tìm hiểu và lựa chọn học phần dựa trên dữ liệu RAG
và kết quả nghiệp vụ do hệ thống cung cấp.

==============================
I. NGUYÊN TẮC TRẢ LỜI
==============================

1. Luôn trả lời bằng tiếng Việt.
2. Trả lời trực tiếp vào câu hỏi.
3. Ưu tiên ngắn gọn, dễ hiểu, tự nhiên.
4. Mặc định không quá 100 từ.
5. Chỉ sử dụng tối đa 3 gạch đầu dòng
   nếu thực sự cần thiết.
6. Không tự chia câu trả lời thành nhiều mục
   hoặc nhiều tiêu đề khi người dùng không yêu cầu.
7. Không liệt kê toàn bộ dữ liệu RAG.
8. Chỉ cung cấp thông tin cần thiết để giải quyết
   câu hỏi hiện tại.
9. Chỉ trình bày chi tiết khi người dùng yêu cầu.

==============================
II. XỬ LÝ CÂU HỎI CHUNG CHUNG
==============================

Khi người dùng đặt câu hỏi chưa rõ mục tiêu,
không được tự suy diễn hoặc đưa ra danh sách dài.

Hãy hỏi lại đúng MỘT câu ngắn gọn để xác định
nhu cầu trước khi trả lời chi tiết.

Ví dụ:

Người dùng:
"Bạn có thể gợi ý môn học cho khoa CNTT không?"

Cách trả lời:
"Được chứ! Bạn muốn tham khảo môn học theo
định hướng nào: Công nghệ phần mềm, AI - Khoa học
dữ liệu, Mạng máy tính hay IoT?"

Không tự động liệt kê toàn bộ môn học.

==============================
III. QUY TẮC SỬ DỤNG RAG
==============================

1. Chỉ sử dụng dữ liệu có trong RAG.
2. Không tự tạo mã môn, tên môn, số tín chỉ,
   học phần tiên quyết hoặc chương trình đào tạo.
3. Không tự suy luận rằng một chương trình đào tạo
   đại diện cho toàn bộ Khoa.
4. Không nhầm lẫn giữa Khoa, ngành, chuyên ngành
   và chương trình đào tạo.
5. Nếu có nhiều chương trình đào tạo,
   phải xác định đúng chương trình người dùng hỏi.
6. Nếu chưa xác định được chương trình phù hợp,
   hãy hỏi lại người dùng.
7. Không tự thêm các khóa học MOOC,
   Coursera hoặc tài liệu bên ngoài RAG.
8. Nếu không tìm thấy căn cứ, phải nói rõ
   chưa có dữ liệu phù hợp.

==============================
IV. QUY TẮC GỢI Ý HỌC PHẦN
==============================

1. Chỉ gợi ý học phần khi có đủ căn cứ dữ liệu.
2. Nếu người dùng hỏi chung, hãy hỏi rõ định hướng.
3. Khi đã xác định được nhu cầu,
   ưu tiên gợi ý tối đa 3 học phần.
4. Mỗi học phần chỉ cần nêu tên và một lý do ngắn.
5. Không tự khẳng định học phần là bắt buộc
   hoặc tự chọn nếu dữ liệu không xác nhận.
6. Không khẳng định học phần được mở trong kỳ
   nếu chưa có dữ liệu xác nhận.

==============================
V. BẢO TOÀN RULE ENGINE F24
==============================

Rule Engine là nguồn quyết định nghiệp vụ duy nhất.

Nếu có kết quả Rule Engine:

1. Không thay đổi status.
2. Không thay đổi reasonCode.
3. Không thay đổi eligibility.
4. Không thay đổi thứ tự ưu tiên.
5. Không tự thêm hoặc loại bỏ học phần.
6. Chỉ giải thích kết quả đã được xác định.

Không sử dụng kiến thức suy luận của LLM
để thay thế quy tắc nghiệp vụ F24.

==============================
VI. PHONG CÁCH GIAO TIẾP
==============================

- Thân thiện như một cố vấn học tập.
- Không diễn giải dài dòng.
- Không nhắc lại toàn bộ câu hỏi.
- Không đưa thông tin ngoài phạm vi yêu cầu.
- Không tự mở rộng chủ đề.
- Khi cần làm rõ, chỉ hỏi một câu.
''';

  static Future<String> sendMessage(
    Session session,
    String message,
  ) async {
    if (message.trim().isEmpty) {
      throw AppException(
        code: 'AI_INVALID_INPUT',
        message: 'Nội dung câu hỏi không được để trống.',
      );
    }

    final ragContext = await _loadRagContext();
    final model = _model;
    final uri = Uri.parse('${_baseUrl}/api/chat');

    late final http.Response response;

    try {
      response = await http
          .post(
            uri,
            headers: const {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'model': model,
              'stream': false,
              // Qwen3.5: dùng tham số think ở cấp request.
              'think': false,
              'keep_alive': '10m',
              'messages': [
                {
                  'role': 'system',
                  'content':
                      '$_systemPrompt\n\n'
                      'NGUỒN DỮ LIỆU RAG:\n$ragContext',
                },
                {
                  'role': 'user',
                  'content': message.trim(),
                },
              ],
              'options': {
                'temperature': 0.2,
                'top_p': 0.85,
                'num_ctx': 8192,
                'num_predict': 350,
              },
            }),
          )
          .timeout(const Duration(seconds: 180));
    } on TimeoutException {
      throw AppException(
        code: 'AI_TIMEOUT',
        message:
            'LLM Local phản hồi quá lâu. Hãy kiểm tra tải GPU hoặc giảm kích thước ngữ cảnh.',
      );
    } on SocketException {
      throw AppException(
        code: 'AI_LOCAL_CONNECTION_ERROR',
        message: 'Không thể kết nối Ollama tại $_baseUrl.',
      );
    } on http.ClientException {
      throw AppException(
        code: 'AI_LOCAL_CONNECTION_ERROR',
        message: 'Không thể gửi yêu cầu đến Ollama.',
      );
    } on FormatException {
      throw AppException(
        code: 'AI_LOCAL_CONFIG_ERROR',
        message: 'OLLAMA_BASE_URL chưa hợp lệ.',
      );
    }

    if (response.statusCode != 200) {
      String? providerError;

      try {
        final decoded = jsonDecode(
          utf8.decode(response.bodyBytes),
        );

        if (decoded is Map<String, dynamic>) {
          providerError = decoded['error']?.toString();
        }
      } on FormatException {
        // Bỏ qua body lỗi không phải JSON.
      }

      final missingModel =
          response.statusCode == 404 ||
          (providerError?.toLowerCase().contains('not found') ?? false);

      if (missingModel) {
        throw AppException(
          code: 'AI_MODEL_NOT_FOUND',
          message:
              'Không tìm thấy mô hình "$model". Hãy chạy: ollama pull $model',
        );
      }

      throw AppException(
        code: 'AI_LOCAL_API_ERROR',
        message: 'Ollama trả về HTTP ${response.statusCode}.',
      );
    }

    try {
      final data =
          jsonDecode(
                utf8.decode(response.bodyBytes),
              )
              as Map<String, dynamic>;

      final messageData = data['message'];

      if (messageData is! Map<String, dynamic>) {
        throw const FormatException('Thiếu message');
      }

      final answer = messageData['content'];

      if (answer is! String || answer.trim().isEmpty) {
        throw const FormatException('Phản hồi rỗng');
      }

      return answer.trim();
    } on FormatException {
      throw AppException(
        code: 'AI_INVALID_RESPONSE',
        message: 'Ollama chưa trả về nội dung hợp lệ.',
      );
    } on TypeError {
      throw AppException(
        code: 'AI_INVALID_RESPONSE',
        message: 'Ollama trả về dữ liệu không đúng định dạng.',
      );
    }
  }

  static String get _baseUrl {
    final configured = Platform.environment['OLLAMA_BASE_URL']?.trim();

    final value = (configured == null || configured.isEmpty)
        ? 'http://127.0.0.1:11434'
        : configured;

    return value.replaceFirst(RegExp(r'/+$'), '');
  }

  static String get _model {
    final configured = Platform.environment['OLLAMA_MODEL']?.trim();

    return (configured == null || configured.isEmpty)
        ? 'qwen3.5:9b'
        : configured;
  }

  static Future<String> _loadRagContext() async {
    try {
      final content = await File(_ragFilePath).readAsString();

      if (content.trim().isEmpty) {
        throw AppException(
          code: 'RAG_FILE_EMPTY',
          message: 'File dữ liệu RAG đang trống.',
        );
      }

      return content;
    } on FileSystemException {
      throw AppException(
        code: 'RAG_FILE_NOT_FOUND',
        message: 'Không đọc được file dữ liệu RAG: $_ragFilePath.',
      );
    }
  }
}
