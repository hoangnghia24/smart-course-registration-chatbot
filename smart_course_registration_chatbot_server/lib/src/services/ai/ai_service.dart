import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../generated/protocol.dart';

/// Gọi các mô hình Ollama dùng bởi chatbot và RAG.
class AiService {
  AiService({http.Client? client}) : _client = client ?? http.Client();

  static final AiService instance = AiService();

  static const String embeddingModel = 'qwen3-embedding:0.6b';
  static const int embeddingDimensions = 768;

  static const String _systemPrompt = '''
Bạn là trợ lý học vụ của hệ thống Smart Course Registration Chatbot,
hỗ trợ sinh viên chọn và đăng ký học phần trong chương trình đào tạo (CTĐT).

I. PHẠM VI DUY NHẤT
Bạn chỉ thực hiện ba nhiệm vụ sau:
1. Tư vấn học phần nên chọn trong CTĐT của sinh viên.
2. Hướng dẫn đăng ký học phần dựa trên dữ liệu và quy tắc hệ thống cung cấp.
3. Giải thích vì sao nên chọn, chưa nên chọn hoặc không đủ điều kiện chọn
   một học phần.

Không tư vấn nghề nghiệp, vị trí việc làm, lộ trình nghề, chứng chỉ, kỹ năng
ngoài CTĐT hoặc khóa học bên ngoài. Không hỏi sinh viên muốn làm nghề gì hay
định hướng lĩnh vực nào. Với câu hỏi ngoài phạm vi, chỉ trả lời:
"Mình chỉ hỗ trợ tư vấn học phần, hướng dẫn đăng ký và giải thích lựa chọn
học phần trong CTĐT của bạn."

II. NGUYÊN TẮC TRẢ LỜI
1. Luôn trả lời bằng tiếng Việt, xưng "mình", gọi người dùng là "bạn".
2. Trả lời trực tiếp vào câu hỏi, ngắn gọn, tự nhiên như cố vấn học tập.
3. Mặc định không quá 100 từ; chỉ trình bày chi tiết khi người dùng yêu cầu.
4. Viết văn bản thuần: KHÔNG dùng Markdown (không **, không #, không bảng).
   Nếu cần liệt kê thì dùng tối đa 8 dòng bắt đầu bằng "- ".
5. Không nhắc lại câu hỏi, không chào hỏi dài dòng, không tự mở rộng chủ đề
   và không kết thúc bằng câu hỏi gợi mở khi đã đủ thông tin để trả lời.

III. QUY TẮC DÙNG DỮ LIỆU
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

IV. KHI THIẾU THÔNG TIN
1. Không hỏi lại ngành hoặc khóa nếu DỮ LIỆU TRA CỨU đã xác định chúng từ
   hồ sơ sinh viên.
2. Chỉ hỏi tối đa MỘT câu về thông tin học vụ còn thiếu: mã/tên học phần,
   học kỳ, ngành hoặc khóa.
3. Không hỏi về sở thích, năng lực, công việc mong muốn hay định hướng nghề.

V. TƯ VẤN VÀ GIẢI THÍCH HỌC PHẦN
1. Gợi ý tối đa 3 học phần có trong dữ liệu, mỗi môn nêu một lý do học vụ ngắn.
2. Lý do chỉ dựa trên học kỳ dự kiến, tiên quyết/học trước, bắt buộc/tự chọn,
   trình tự kiến thức và điều kiện đăng ký; không suy diễn lợi ích nghề nghiệp.
3. Không khẳng định học phần được mở trong kỳ nếu chưa có dữ liệu xác nhận.
4. Nếu chưa đủ dữ liệu để gợi ý, nói rõ thiếu thông tin nào; không tự mở rộng
   sang tư vấn nghề nghiệp để lấy thêm nhu cầu.

VI. BẢO TOÀN RULE ENGINE F24
Nếu có kết quả Rule Engine: không thay đổi status, reasonCode, eligibility,
thứ tự ưu tiên; không thêm/bớt học phần; chỉ giải thích kết quả đã có.
Không dùng suy luận của LLM để thay thế quy tắc nghiệp vụ F24.
''';

  final http.Client _client;

  /// Sinh câu trả lời từ câu hỏi và ngữ cảnh đã được RAG truy xuất.
  Future<String> generateAnswer(String message, String ragText) async {
    final question = message.trim();
    if (question.isEmpty) {
      throw AppException(
        code: 'AI_INVALID_INPUT',
        message: 'Nội dung câu hỏi không được để trống.',
      );
    }

    final response = await _post(
      path: '/api/chat',
      model: _chatModel,
      timeout: const Duration(seconds: 180),
      body: {
        'model': _chatModel,
        'stream': false,
        // Qwen3.5: dùng tham số think ở cấp request.
        'think': false,
        'keep_alive': '10m',
        'messages': [
          {'role': 'system', 'content': _systemPrompt},
          {'role': 'user', 'content': _buildUserPrompt(question, ragText)},
        ],
        'options': {
          'temperature': 0.2,
          'top_p': 0.85,
          'num_ctx': 8192,
          'num_predict': 400,
        },
      },
    );

    final data = _decodeResponse(response);
    final messageData = data['message'];
    if (messageData is! Map<String, dynamic>) {
      throw _invalidResponse();
    }

    final answer = messageData['content'];
    if (answer is! String || answer.trim().isEmpty) {
      throw _invalidResponse();
    }

    return _cleanAnswer(answer);
  }

  /// Tạo embedding cho nhiều tài liệu trong một request.
  Future<List<List<double>>> embedDocuments(List<String> texts) {
    return _embedMany(texts);
  }

  /// Tạo embedding cho câu hỏi với instruction tối ưu cho truy xuất CTĐT.
  Future<List<double>> embedQuery(String question) async {
    final instructed =
        'Instruct: Given a university course registration question, '
        'retrieve the most relevant curriculum and academic policy passages.\n'
        'Query: ${question.trim()}';

    return (await _embedMany([instructed])).first;
  }

  Future<List<List<double>>> _embedMany(List<String> inputs) async {
    if (inputs.isEmpty || inputs.any((input) => input.trim().isEmpty)) {
      throw ArgumentError('Embedding input must not be empty.');
    }

    final response = await _post(
      path: '/api/embed',
      model: embeddingModel,
      timeout: const Duration(seconds: 90),
      body: {
        'model': embeddingModel,
        'input': inputs.length == 1 ? inputs.first : inputs,
        'dimensions': embeddingDimensions,
        'truncate': false,
        'keep_alive': '10m',
      },
    );

    final data = _decodeResponse(response);
    final embeddings = data['embeddings'];
    if (embeddings is! List ||
        embeddings.length != inputs.length ||
        embeddings.any((embedding) => embedding is! List)) {
      throw _invalidResponse();
    }

    try {
      return [
        for (final embedding in embeddings)
          _checkDimensions(
            (embedding as List)
                .map((value) => (value as num).toDouble())
                .toList(growable: false),
          ),
      ];
    } on TypeError {
      throw _invalidResponse();
    }
  }

  Future<http.Response> _post({
    required String path,
    required String model,
    required Duration timeout,
    required Map<String, dynamic> body,
  }) async {
    late final http.Response response;
    try {
      response = await _client
          .post(
            Uri.parse('$_baseUrl$path'),
            headers: const {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(body),
          )
          .timeout(timeout);
    } on TimeoutException {
      throw AppException(
        code: 'AI_TIMEOUT',
        message: 'Ollama phản hồi quá lâu. Hãy kiểm tra tải GPU.',
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

    if (response.statusCode == 200) return response;

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

  Map<String, dynamic> _decodeResponse(http.Response response) {
    try {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is! Map<String, dynamic>) throw const FormatException();
      return decoded;
    } on FormatException {
      throw _invalidResponse();
    }
  }

  List<double> _checkDimensions(List<double> vector) {
    if (vector.length != embeddingDimensions) {
      throw StateError(
        'VECTOR_DIMENSION_MISMATCH: expected $embeddingDimensions, '
        'got ${vector.length}',
      );
    }
    return vector;
  }

  String _buildUserPrompt(String question, String ragText) {
    final data = ragText.trim().isEmpty
        ? '(Không tìm thấy dữ liệu CTĐT liên quan đến câu hỏi.)'
        : ragText;
    return 'DỮ LIỆU TRA CỨU (hệ thống tự truy xuất từ CTĐT, người dùng không nhìn thấy):\n'
        '<<<\n$data\n>>>\n\n'
        'CÂU HỎI CỦA SINH VIÊN: $question';
  }

  /// Bỏ Markdown để client hiển thị văn bản thuần.
  String _cleanAnswer(String answer) {
    final lines = answer.trim().split('\n').map((line) {
      var cleaned = line.replaceAll('**', '').replaceAll('__', '');
      cleaned = cleaned.replaceFirst(RegExp(r'^\s*#{1,6}\s*'), '');
      cleaned = cleaned.replaceFirstMapped(
        RegExp(r'^(\s*)[*•]\s+'),
        (match) => '${match.group(1)}- ',
      );
      return cleaned.trimRight();
    });
    return lines.join('\n').replaceAll(RegExp(r'\n{3,}'), '\n\n').trim();
  }

  AppException _invalidResponse() {
    return AppException(
      code: 'AI_INVALID_RESPONSE',
      message: 'Ollama chưa trả về nội dung hợp lệ.',
    );
  }

  String get _baseUrl {
    final configured = Platform.environment['OLLAMA_BASE_URL']?.trim();
    final value = (configured == null || configured.isEmpty)
        ? 'http://127.0.0.1:11434'
        : configured;
    return value.replaceFirst(RegExp(r'/+$'), '');
  }

  String get _chatModel {
    final configured = Platform.environment['OLLAMA_MODEL']?.trim();
    return (configured == null || configured.isEmpty)
        ? 'qwen3.5:9b'
        : configured;
  }
}
