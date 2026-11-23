import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:serverpod/serverpod.dart';

import '../../generated/protocol.dart';
import 'ctdt_rag_retriever.dart';

/// LLM chat chạy cục bộ qua Ollama.
/// Giữ chữ ký sendMessage(Session, String) để endpoint hiện tại
/// ít phải thay đổi nhất.
///
/// Thay đổi so với bản cũ:
/// - KHÔNG nạp toàn bộ ctdt_rag.jsonl vào prompt nữa (≈225k token, vượt xa
///   num_ctx 8192 → Ollama cắt mất system prompt và phần lớn dữ liệu).
///   Mỗi câu hỏi chỉ đưa vào vài bản ghi do [CtdtRagRetriever] chọn.
/// - Dữ liệu tra cứu nằm trong tin nhắn user, tách khỏi system prompt,
///   nên quy tắc trả lời không bao giờ bị cắt.
/// - Làm sạch Markdown trước khi trả về client.
class LocalLlmChatService {
  static const String _systemPrompt = '''
Bạn là trợ lý học vụ của hệ thống Smart Course Registration Chatbot,
hỗ trợ sinh viên tra cứu chương trình đào tạo (CTĐT) và chọn học phần.

I. NGUYÊN TẮC TRẢ LỜI
1. Luôn trả lời bằng tiếng Việt, xưng "mình", gọi người dùng là "bạn".
2. Trả lời trực tiếp vào câu hỏi, ngắn gọn, tự nhiên như cố vấn học tập.
3. Mặc định không quá 100 từ; chỉ trình bày chi tiết khi người dùng yêu cầu.
4. Viết văn bản thuần: KHÔNG dùng Markdown (không **, không #, không bảng).
   Nếu cần liệt kê thì dùng tối đa 8 dòng bắt đầu bằng "- ".
5. Không nhắc lại câu hỏi, không chào hỏi dài dòng, không tự mở rộng chủ đề.

II. QUY TẮC DÙNG DỮ LIỆU
1. Chỉ dùng phần "DỮ LIỆU TRA CỨU" trong tin nhắn. Phần này do hệ thống tự
   truy xuất, người dùng không nhìn thấy: không được nói "tài liệu bạn cung cấp",
   hãy gọi là "theo CTĐT".
2. Không dùng kiến thức chung để đoán tên môn, mã môn, số tín chỉ, học kỳ,
   tiên quyết hay chương trình đào tạo. Không tự thêm khóa học bên ngoài.
3. Nếu DỮ LIỆU TRA CỨU không có thông tin cần thiết, nói ngắn gọn là chưa có
   dữ liệu phù hợp và gợi ý người dùng hỏi cụ thể hơn.
4. Phân biệt Khoa, ngành (CTĐT) và chuyên ngành. Khoa Công nghệ thông tin có
   nhiều ngành; không coi một ngành là đại diện cho cả Khoa.
5. "Học kỳ dự kiến" là kế hoạch của CTĐT, không có nghĩa lớp chắc chắn mở
   trong học kỳ hiện tại.
6. Chỉ nói một học phần là bắt buộc hoặc tự chọn khi dữ liệu ghi rõ.

III. KHI CÂU HỎI CHƯA RÕ NGÀNH
- Nếu dữ liệu cho thấy các ngành có phần chung (mục "Chung cho tất cả…"),
  hãy nêu ngắn phần chung, nói rõ môn nào khác nhau giữa các ngành, rồi hỏi
  lại MỘT câu: bạn học ngành nào.
- Nếu các ngành khác nhau nhiều, hỏi lại MỘT câu để xác định ngành trước.

IV. GỢI Ý HỌC PHẦN
1. Khi đã rõ nhu cầu, gợi ý tối đa 3 học phần, mỗi môn nêu tên và một lý do ngắn.
2. Không khẳng định học phần được mở trong kỳ nếu chưa có dữ liệu xác nhận.

V. BẢO TOÀN RULE ENGINE F24
Nếu có kết quả Rule Engine: không thay đổi status, reasonCode, eligibility,
thứ tự ưu tiên; không thêm/bớt học phần; chỉ giải thích kết quả đã có.
Không dùng suy luận của LLM để thay thế quy tắc nghiệp vụ F24.
''';

  static Future<String> sendMessage(
    Session session,
    String message,
  ) async {
    final question = message.trim();
    if (question.isEmpty) {
      throw AppException(
        code: 'AI_INVALID_INPUT',
        message: 'Nội dung câu hỏi không được để trống.',
      );
    }

    final rag = await _retrieve(question);
    session.log(
      'RAG: ${rag.recordIds.length} bản ghi, ${rag.text.length} ký tự, '
      'ngành=${rag.programs.join(",")}, HK=${rag.semesters.join(",")}, '
      'embedding=${rag.usedEmbedding} | ${rag.recordIds.take(12).join(", ")}',
      level: LogLevel.info,
    );

    final model = _model;
    final uri = Uri.parse('$_baseUrl/api/chat');

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
                {'role': 'system', 'content': _systemPrompt},
                {'role': 'user', 'content': _buildUserPrompt(question, rag)},
              ],
              'options': {
                'temperature': 0.2,
                'top_p': 0.85,
                'num_ctx': 8192,
                'num_predict': 400,
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
        final decoded = jsonDecode(utf8.decode(response.bodyBytes));
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
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;

      final messageData = data['message'];
      if (messageData is! Map<String, dynamic>) {
        throw const FormatException('Thiếu message');
      }

      final answer = messageData['content'];
      if (answer is! String || answer.trim().isEmpty) {
        throw const FormatException('Phản hồi rỗng');
      }

      return _cleanAnswer(answer);
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

  static Future<RagContext> _retrieve(String question) async {
    try {
      return await CtdtRagRetriever.instance().retrieve(question);
    } on StateError catch (e) {
      final notFound = e.message.startsWith('RAG_FILE_NOT_FOUND');
      throw AppException(
        code: notFound ? 'RAG_FILE_NOT_FOUND' : 'RAG_FILE_EMPTY',
        message: notFound
            ? 'Không đọc được file dữ liệu RAG: ${CtdtRagRetriever.defaultRagPath}.'
            : 'File dữ liệu RAG đang trống.',
      );
    } on FormatException {
      throw AppException(
        code: 'RAG_FILE_INVALID',
        message: 'File dữ liệu RAG không đúng định dạng JSONL.',
      );
    }
  }

  static String _buildUserPrompt(String question, RagContext rag) {
    final data = rag.isEmpty
        ? '(Không tìm thấy dữ liệu CTĐT liên quan đến câu hỏi.)'
        : rag.text;
    return 'DỮ LIỆU TRA CỨU (hệ thống tự truy xuất từ CTĐT, người dùng không nhìn thấy):\n'
        '<<<\n$data\n>>>\n\n'
        'CÂU HỎI CỦA SINH VIÊN: $question';
  }

  /// Bỏ Markdown để client hiển thị văn bản thuần.
  static String _cleanAnswer(String answer) {
    final lines = answer.trim().split('\n').map((line) {
      var l = line.replaceAll('**', '').replaceAll('__', '');
      l = l.replaceFirst(RegExp(r'^\s*#{1,6}\s*'), '');
      l = l.replaceFirstMapped(
        RegExp(r'^(\s*)[*•]\s+'),
        (m) => '${m.group(1)}- ',
      );
      return l.trimRight();
    });
    return lines
        .join('\n')
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        .trim();
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
}
