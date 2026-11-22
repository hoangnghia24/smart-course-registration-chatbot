import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

/// Tạo embedding cục bộ bằng Ollama + Qwen3-Embedding 0.6B.
///
/// LƯU Ý:
/// - Cả document và query phải dùng cùng model + cùng dimensions.
/// - Nếu đổi từ Gemini Embedding sang model này, phải tạo lại toàn bộ
///   embedding cũ; không trộn vector của hai model trong cùng index.
class OllamaEmbeddingService {
  static const String model = 'qwen3-embedding:0.6b';
  static const int dimensions = 768;

  final http.Client _client;

  OllamaEmbeddingService({http.Client? client})
    : _client = client ?? http.Client();

  String get _baseUrl {
    final configured = Platform.environment['OLLAMA_BASE_URL']?.trim();

    final value = (configured == null || configured.isEmpty)
        ? 'http://127.0.0.1:11434'
        : configured;

    return value.replaceFirst(RegExp(r'/+$'), '');
  }

  /// Nội dung tài liệu: không thêm query instruction.
  Future<List<double>> embedDocument(String text) async {
    return (await _embedMany([text])).first;
  }

  /// Nhiều tài liệu trong một request (Ollama /api/embed nhận danh sách input).
  Future<List<List<double>>> embedDocuments(List<String> texts) {
    return _embedMany(texts);
  }

  /// Câu hỏi: dùng instruction riêng để tối ưu truy xuất.
  Future<List<double>> embedQuery(String question) async {
    final instructed =
        'Instruct: Given a university course registration question, '
        'retrieve the most relevant curriculum and academic policy passages.\n'
        'Query: ${question.trim()}';

    return (await _embedMany([instructed])).first;
  }

  Future<List<List<double>>> _embedMany(List<String> inputs) async {
    if (inputs.isEmpty || inputs.any((s) => s.trim().isEmpty)) {
      throw ArgumentError(
        'Embedding input must not be empty.',
      );
    }

    final uri = Uri.parse('$_baseUrl/api/embed');

    late final http.Response response;

    try {
      response = await _client
          .post(
            uri,
            headers: const {
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'model': model,
              'input': inputs.length == 1 ? inputs.first : inputs,
              'dimensions': dimensions,
              'truncate': false,
              'keep_alive': '10m',
            }),
          )
          .timeout(const Duration(seconds: 90));
    } on TimeoutException {
      throw StateError('OLLAMA_EMBEDDING_TIMEOUT');
    } on SocketException {
      throw StateError(
        'OLLAMA_EMBEDDING_CONNECTION_ERROR',
      );
    } on http.ClientException {
      throw StateError(
        'OLLAMA_EMBEDDING_CONNECTION_ERROR',
      );
    }

    if (response.statusCode != 200) {
      throw StateError(
        'OLLAMA_EMBEDDING_ERROR: HTTP ${response.statusCode}',
      );
    }

    final data =
        jsonDecode(
              utf8.decode(response.bodyBytes),
            )
            as Map<String, dynamic>;

    final embeddings = data['embeddings'];

    if (embeddings is! List ||
        embeddings.length != inputs.length ||
        embeddings.any((e) => e is! List)) {
      throw const FormatException(
        'Invalid Ollama embedding response.',
      );
    }

    return [
      for (final e in embeddings)
        _checked(
          (e as List)
              .map((value) => (value as num).toDouble())
              .toList(growable: false),
        ),
    ];
  }

  List<double> _checked(List<double> vector) {
    if (vector.length != dimensions) {
      throw StateError(
        'VECTOR_DIMENSION_MISMATCH: '
        'expected $dimensions, got ${vector.length}',
      );
    }
    return vector;
  }

  void close() {
    _client.close();
  }
}
