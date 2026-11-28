import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:crypto/crypto.dart';
import 'package:diacritic/diacritic.dart';

import '../../generated/protocol.dart';
import 'ai_service.dart';

/// Truy xuất dữ liệu học vụ từ các file JSONL đã được tổng hợp sẵn.
class RagService {
  RagService({
    List<String> ragPaths = defaultRagPaths,
    String embeddingCachePath = defaultEmbeddingCachePath,
    AiService? aiService,
  }) : _ragPaths = List.unmodifiable(ragPaths),
       _embeddingCachePath = embeddingCachePath,
       _aiService = aiService ?? AiService.instance {
    _loaded = _load();
  }

  static const List<String> defaultRagPaths = [
    'config/academic_rag_2023_cntt.jsonl',
    'config/academic_rag_2023_attt.jsonl',
    'config/academic_rag_2023_ktdl.jsonl',
    'config/academic_rag_2026_cntt.jsonl',
    'config/academic_rag_2026_attt.jsonl',
    'config/academic_rag_2026_ktdl.jsonl',
    'config/academic_rag_2026_cntt_jp.jsonl',
  ];
  static const String defaultEmbeddingCachePath =
      'config/academic_rag.embeddings.json';
  static const int maxContextChars = 6500;
  static const int _topK = 6;
  static const Set<int> _supportedCohorts = {2023, 2026};

  static RagService? _instance;

  static RagService instance() => _instance ??= RagService();

  final List<String> _ragPaths;
  final String _embeddingCachePath;
  final AiService _aiService;

  late final Future<void> _loaded;
  List<RagRecord> _records = const [];
  Map<String, List<double>> _vectors = const {};

  /// Trả về văn bản ngữ cảnh đã lọc theo chương trình và khóa.
  Future<String> retrieve(
    String question, {
    String? defaultProgram,
    int? defaultCohort,
  }) async {
    await _loaded;

    final normalizedQuestion = _normalize(question);
    final programs = _detectPrograms(normalizedQuestion);
    final cohorts = _detectCohorts(normalizedQuestion);
    final unsupportedCohorts = RegExp(r'\b20\d{2}\b')
        .allMatches(normalizedQuestion)
        .map((match) => int.parse(match.group(0)!))
        .where((year) => !_supportedCohorts.contains(year))
        .toSet();

    final profileProgram = _canonicalProgram(defaultProgram);
    if (programs.isEmpty && profileProgram != null) {
      programs.add(profileProgram);
    }
    if (cohorts.isEmpty && _supportedCohorts.contains(defaultCohort)) {
      cohorts.add(defaultCohort!);
    }

    if (unsupportedCohorts.isNotEmpty) {
      return 'Dữ liệu RAG hiện chỉ hỗ trợ khóa 2023 và 2026. '
          'Bạn muốn tra cứu CTĐT áp dụng từ năm 2023 hay năm 2026?';
    }
    if (programs.isEmpty) {
      return 'Chưa xác định được chương trình đào tạo của bạn. '
          'Bạn đang học CNTT, ATTT, KTDL hay CNTT hệ tiếng Nhật?';
    }
    if (programs.length > 1) {
      return 'Câu hỏi đang nhắc đến nhiều chương trình đào tạo. '
          'Bạn muốn tra cứu chương trình nào trước?';
    }
    if (cohorts.isEmpty) {
      return 'Chưa xác định được khóa áp dụng. '
          'Bạn muốn tra cứu CTĐT áp dụng từ năm 2023 hay năm 2026?';
    }

    final program = programs.single;
    final candidates = _records
        .where(
          (record) =>
              record.program == program && cohorts.contains(record.cohort),
        )
        .toList(growable: false);

    // Ưu tiên bằng chứng đúng học phần khi người học hỏi lý do lựa chọn.
    var hits = _asksSelectionReason(normalizedQuestion)
        ? _selectionEvidence(normalizedQuestion, candidates, cohorts)
        : <RagRecord>[];
    if (hits.isEmpty) {
      hits = _structuredSearch(question, normalizedQuestion, candidates);
    }
    if (hits.isEmpty) {
      hits = await _semanticOrKeywordSearch(
        question,
        normalizedQuestion,
        candidates,
      );
    }

    if (hits.isEmpty) {
      return 'Không tìm thấy dữ liệu phù hợp trong chương trình $program, '
          'khóa ${(cohorts.toList()..sort()).join(' và ')}.';
    }

    return _buildContext(_balanceByCohort(hits, cohorts));
  }

  /// Tạo cache tài liệu bằng lệnh riêng trước khi khởi động ứng dụng.
  static Future<void> generateEmbeddingCache({
    List<String> ragPaths = defaultRagPaths,
    String outputPath = defaultEmbeddingCachePath,
    AiService? aiService,
  }) async {
    final records = await _readRecords(ragPaths);
    final service = aiService ?? AiService.instance;
    final vectors = <String, List<double>>{};

    const batchSize = 16;
    for (var i = 0; i < records.length; i += batchSize) {
      final batch = records.sublist(
        i,
        math.min(i + batchSize, records.length),
      );
      final output = await service.embedDocuments(
        batch.map((record) => record.embeddingText).toList(),
      );
      for (var j = 0; j < batch.length; j++) {
        vectors[batch[j].id] = _normalizeVector(output[j]);
      }
      stdout.writeln(
        '[RAG] Đã tạo embedding cho ${math.min(i + batchSize, records.length)}/'
        '${records.length} bản ghi.',
      );
    }

    final cache = {
      'model': AiService.embeddingModel,
      'dimensions': AiService.embeddingDimensions,
      'items': {
        for (final record in records)
          record.id: {'h': record.hash, 'v': vectors[record.id]},
      },
    };
    final outputFile = File(outputPath);
    await outputFile.parent.create(recursive: true);
    final temporaryFile = File('$outputPath.tmp');
    await temporaryFile.writeAsString(jsonEncode(cache));
    final temporaryJson = jsonDecode(await temporaryFile.readAsString());
    _validateCache(temporaryJson, records);

    String? backupPath;
    if (await outputFile.exists()) {
      final timestamp = DateTime.now().toUtc().toIso8601String().replaceAll(
        ':',
        '-',
      );
      backupPath = '$outputPath.$timestamp.bak';
      await outputFile.rename(backupPath);
    }
    try {
      await temporaryFile.rename(outputPath);
      final writtenJson = jsonDecode(await outputFile.readAsString());
      _validateCache(writtenJson, records);
      if (backupPath != null) {
        await File(backupPath).delete();
      }
    } catch (_) {
      if (await outputFile.exists()) {
        await outputFile.delete();
      }
      if (backupPath != null && await File(backupPath).exists()) {
        await File(backupPath).rename(outputPath);
      }
      rethrow;
    }
    stdout.writeln('[RAG] Đã lưu ${records.length} vector vào $outputPath.');
  }

  static bool _asksSelectionReason(String question) {
    const phrases = [
      'tai sao', 'vi sao', 'ly do', 'giai thich', 'vi ly do gi',
      'co nen chon', 'co nen hoc', 'co nen dang ky',
      'nen chon', 'nen dang ky', 'uu tien', 'loi ich',
    ];
    return phrases.any(question.contains);
  }

  static bool _isTeachingPlan(RagRecord record) {
    // Dữ liệu cũng có các bản ghi semester là ma trận PLO/PI và mô tả.
    // Không xem chúng là kế hoạch đăng ký học phần.
    final text = _normalize(record.text);
    return record.type == 'semester' &&
        record.semester != null &&
        (text.contains('ma mh') || text.contains('ma hp')) &&
        (text.contains('so tc') || text.contains('so tin chi'));
  }

  static bool _containsPhrase(String text, String phrase) =>
      phrase.isNotEmpty && ' $text '.contains(' $phrase ');

  List<RagRecord> _selectionEvidence(
    String question,
    List<RagRecord> candidates,
    Set<int> cohorts,
  ) {
    final output = <RagRecord>[];
    final semesters = RegExp(r'\b(?:hoc ky|hoc ki|hk|ky|ki)\s*(\d{1,2})\b')
        .allMatches(question)
        .map((match) => int.parse(match.group(1)!))
        .toSet();

    // Xử lý từng khóa độc lập để không lẫn căn cứ giữa các CTĐT.
    for (final cohort in cohorts.toList()..sort()) {
      final scoped = candidates.where((r) => r.cohort == cohort).toList();
      final courses = scoped.where((r) => r.type == 'course').toList();
      final byCode = courses.where((r) => r.courseCode != null &&
          _containsPhrase(question, _normalize(r.courseCode!))).toList();
      final byName = courses.where((r) {
        final name = _normalize(r.courseName ?? '');
        if (name.length < 5 || !_containsPhrase(question, name)) return false;
        final programPhrase = _containsPhrase(question, 'nganh $name') ||
            _containsPhrase(question, 'chuong trinh $name');
        return !programPhrase || _containsPhrase(question, 'mon $name') ||
            _containsPhrase(question, 'hoc phan $name');
      }).toList();
      // Tránh nhầm Cơ sở dữ liệu với Hệ quản trị cơ sở dữ liệu.
      final named = byName.where((r) => !byName.any((other) =>
          other.id != r.id &&
          _normalize(other.courseName ?? '').length >
              _normalize(r.courseName ?? '').length &&
          _containsPhrase(_normalize(other.courseName ?? ''),
              _normalize(r.courseName ?? ''))));
      final matched = <String, RagRecord>{
        for (final r in byCode) r.id: r,
        for (final r in named) r.id: r,
      }.values.toList();
      final plans = scoped.where(_isTeachingPlan).toList();
      final selected = <String, RagRecord>{};
      void add(RagRecord record) => selected[record.id] = record;

      // Có tên/mã môn rõ ràng: ưu tiên bản ghi môn và bảng kế hoạch
      // có mã đó. Mã xuất hiện có thể là môn học trước của môn khác,
      // nên giữ nguyên bảng để AI đọc đúng cột, không suy luận từ vị trí.
      if (matched.isNotEmpty) {
        for (final course in matched.take(3)) {
          add(course);
        }
        final codes = matched.take(3).map((r) => _normalize(r.courseCode ?? ''))
            .where((code) => code.isNotEmpty).toSet();
        bool mentionsCourse(RagRecord r) => codes.any(
            (code) => _containsPhrase(_normalize(r.text), code));
        final relevantPlans = plans.where(mentionsCourse).toList();
        relevantPlans.sort((a, b) {
          final aRequested = semesters.contains(a.semester) ? 0 : 1;
          final bRequested = semesters.contains(b.semester) ? 0 : 1;
          final priority = aRequested.compareTo(bRequested);
          return priority != 0 ? priority : a.semester!.compareTo(b.semester!);
        });
        for (final plan in relevantPlans.take(3)) {
          add(plan);
        }
        // Bảng khối kiến thức có thể cung cấp loại môn và điều kiện.
        // Chỉ đưa bảng chứa đúng mã; không tự gán bắt buộc/tự chọn.
        for (final record in scoped.where((r) => r.type == 'information' &&
            mentionsCourse(r) &&
            (_normalize(r.text).contains('bat buoc') ||
                _normalize(r.text).contains('tu chon') ||
                _normalize(r.text).contains('tien quyet') ||
                _normalize(r.text).contains('hoc phan truoc'))).take(2)) {
          add(record);
        }
      } else if (semesters.isNotEmpty) {
        // Tư vấn theo kỳ: chỉ lấy bảng kế hoạch đúng kỳ, không dùng PLO/PI
        // làm danh sách đăng ký và không tự chọn môn ngoài bảng.
        for (final plan in plans.where((r) => semesters.contains(r.semester))) {
          add(plan);
        }
      }
      output.addAll(selected.values);
    }
    return output;
  }

  List<RagRecord> _structuredSearch(
    String question,
    String normalizedQuestion,
    List<RagRecord> candidates,
  ) {
    final found = <String, RagRecord>{};
    final semesters = RegExp(r'\b(?:hoc ky|hoc ki|hk|ky|ki)\s*(\d{1,2})\b')
        .allMatches(normalizedQuestion)
        .map((match) => int.parse(match.group(1)!))
        .where((semester) => semester >= 1 && semester <= 10)
        .toSet();
    final courseCodes = RegExp(r'\b[A-Za-z]{4}\s?\d{6}\b')
        .allMatches(question)
        .map((match) => match.group(0)!.replaceAll(' ', '').toUpperCase())
        .toSet();

    if (_asksTotalCredits(normalizedQuestion)) {
      final matches = candidates.where(
        (record) {
          final content = record.normalizedContent;
          return content.contains('150 tin chi') ||
              content.contains('160 tc') ||
              content.contains('tong 150') ||
              content.contains('tong 160') ||
              content.contains('tong cong 150') ||
              content.contains('tong cong 160') ||
              _normalize(record.title).contains('khoi luong kien thuc') ||
              (record.type == 'overview' &&
                  content.contains('khoi luong hoc tap'));
        },
      );
      for (final record in matches.take(3)) {
        found[record.id] = record;
      }
    }

    if (semesters.isNotEmpty) {
      for (final semester in semesters) {
        final records = candidates.where((record) =>
            record.type == 'semester' && record.semester == semester).toList();
        final plans = records.where(_isTeachingPlan).toList();
        // Giữ cách truy xuất cũ nếu chưa có bảng kế hoạch chuẩn.
        for (final record in (plans.isEmpty ? records : plans).take(3)) {
          found[record.id] = record;
        }
      }
    }

    if (courseCodes.isNotEmpty) {
      final normalizedCodes = courseCodes.map(_normalize).toSet();
      final matches = candidates.where(
        (record) =>
            (record.courseCode != null &&
                courseCodes.contains(record.courseCode!.toUpperCase())) ||
            normalizedCodes.any(record.normalizedContent.contains),
      );
      for (final record in _courseFirst(matches).take(_topK)) {
        found[record.id] = record;
      }
    }

    for (final record in candidates.where(
      (record) => record.type == 'course' && record.courseName != null,
    )) {
      final name = _normalize(record.courseName!);
      if (name.length < 5 || !normalizedQuestion.contains(name)) continue;
      final isProgramPhrase =
          normalizedQuestion.contains('nganh $name') ||
          normalizedQuestion.contains('chuong trinh $name');
      final explicitlyCourse =
          normalizedQuestion.contains('mon $name') ||
          normalizedQuestion.contains('hoc phan $name');
      if (!isProgramPhrase || explicitlyCourse) found[record.id] = record;
    }

    if (normalizedQuestion.contains('tu chon')) {
      var matches = candidates.where(
        (record) => record.normalizedContent.contains('tu chon'),
      );
      const specializationAliases = {
        'cnpm': 'cong nghe phan mem',
        'httt': 'he thong thong tin',
        'ttnt': 'tri tue nhan tao',
      };
      for (final entry in specializationAliases.entries) {
        if (!normalizedQuestion.contains(entry.key) &&
            !normalizedQuestion.contains(entry.value)) {
          continue;
        }
        matches = matches.where(
          (record) =>
              record.normalizedContent.contains(entry.key) ||
              record.normalizedContent.contains(entry.value),
        );
      }
      for (final record in matches.take(3)) {
        found[record.id] = record;
      }
    }

    if (_hasDirectIntent(normalizedQuestion)) {
      for (final record in _keywordSearch(
        normalizedQuestion,
        candidates,
        _topK,
      )) {
        found[record.id] = record;
      }
    }

    return found.values.toList(growable: false);
  }

  Future<List<RagRecord>> _semanticOrKeywordSearch(
    String question,
    String normalizedQuestion,
    List<RagRecord> candidates,
  ) async {
    if (_vectors.isEmpty) {
      return _keywordSearch(normalizedQuestion, candidates, _topK);
    }

    try {
      final queryVector = _normalizeVector(
        await _aiService.embedQuery(question),
      );
      final scored = <MapEntry<RagRecord, double>>[];
      for (final record in candidates) {
        final vector = _vectors[record.id];
        if (vector == null) continue;
        final score = _cosine(queryVector, vector);
        if (score >= 0.35) scored.add(MapEntry(record, score));
      }
      scored.sort((a, b) => b.value.compareTo(a.value));
      return scored.take(_topK).map((entry) => entry.key).toList();
    } catch (error) {
      stdout.writeln('[RAG] Embedding query lỗi, dùng từ khóa: $error');
      return _keywordSearch(normalizedQuestion, candidates, _topK);
    }
  }

  List<RagRecord> _keywordSearch(
    String normalizedQuestion,
    List<RagRecord> candidates,
    int limit,
  ) {
    final queryTokens = _tokens(normalizedQuestion).toSet();
    if (queryTokens.isEmpty) return const [];

    final scored = <MapEntry<RagRecord, int>>[];
    for (final record in candidates) {
      final titleMatches = queryTokens
          .where(record.titleTokens.contains)
          .length;
      final contentMatches = queryTokens.where(record.tokens.contains).length;
      final score = titleMatches * 2 + contentMatches;
      if (score >= 3) scored.add(MapEntry(record, score));
    }
    scored.sort((a, b) => b.value.compareTo(a.value));
    return scored.take(limit).map((entry) => entry.key).toList();
  }

  Future<void> _load() async {
    _records = await _readRecords(_ragPaths);
    await _loadEmbeddingCache();
  }

  static Future<List<RagRecord>> _readRecords(List<String> paths) async {
    final records = <RagRecord>[];
    final ids = <String>{};

    for (final path in paths) {
      final file = File(path);
      late final List<String> lines;
      try {
        lines = await file.readAsLines();
      } on FileSystemException {
        throw AppException(
          code: 'RAG_FILE_NOT_FOUND',
          message: 'Không đọc được file dữ liệu RAG: $path.',
        );
      }

      for (var i = 0; i < lines.length; i++) {
        final line = lines[i].trim();
        if (line.isEmpty) continue;
        try {
          final json = jsonDecode(line);
          if (json is! Map<String, dynamic>) throw const FormatException();
          final record = RagRecord.fromJson(json);
          if (!ids.add(record.id)) {
            throw AppException(
              code: 'RAG_DUPLICATE_ID',
              message: 'ID RAG bị trùng: ${record.id}.',
            );
          }
          records.add(record);
        } on AppException {
          rethrow;
        } on Object {
          throw AppException(
            code: 'RAG_FILE_INVALID',
            message: 'Dữ liệu không hợp lệ tại $path, dòng ${i + 1}.',
          );
        }
      }
    }

    if (records.isEmpty) {
      throw AppException(
        code: 'RAG_FILE_EMPTY',
        message: 'Các file dữ liệu RAG đang trống.',
      );
    }
    return records;
  }

  Future<void> _loadEmbeddingCache() async {
    final cacheFile = File(_embeddingCachePath);
    if (!await cacheFile.exists()) {
      _reportInvalidCache('không tìm thấy file $_embeddingCachePath');
      return;
    }

    try {
      final json = jsonDecode(await cacheFile.readAsString());
      _vectors = _validateCache(json, _records);
    } on Object {
      _vectors = const {};
      _reportInvalidCache('model, hash hoặc vector không khớp dữ liệu mới');
    }
  }

  static Map<String, List<double>> _validateCache(
    Object? json,
    List<RagRecord> records,
  ) {
    if (json is! Map<String, dynamic> ||
        json['model'] != AiService.embeddingModel ||
        json['dimensions'] != AiService.embeddingDimensions ||
        json['items'] is! Map<String, dynamic>) {
      throw const FormatException('Embedding cache metadata không hợp lệ.');
    }

    final items = json['items'] as Map<String, dynamic>;
    if (items.length != records.length) {
      throw const FormatException('Embedding cache thiếu hoặc thừa ID.');
    }

    final vectors = <String, List<double>>{};
    for (final record in records) {
      final item = items[record.id];
      if (item is! Map<String, dynamic> ||
          item['h'] != record.hash ||
          item['v'] is! List ||
          (item['v'] as List).length != AiService.embeddingDimensions) {
        throw const FormatException('Embedding cache không khớp dữ liệu RAG.');
      }
      vectors[record.id] = _normalizeVector(
        (item['v'] as List)
            .map((value) => (value as num).toDouble())
            .toList(growable: false),
      );
    }
    return vectors;
  }

  void _reportInvalidCache(String reason) {
    stdout.writeln(
      '[RAG] Embedding cache không hợp lệ: $reason. '
      'Đang dùng keyword search. Tạo lại bằng: '
      'dart run bin/generate_rag_embeddings.dart',
    );
  }

  List<RagRecord> _balanceByCohort(
    List<RagRecord> records,
    Set<int> cohorts,
  ) {
    if (cohorts.length == 1) return records.take(_topK).toList();
    final result = <RagRecord>[];
    for (final cohort in cohorts.toList()..sort()) {
      result.addAll(records.where((record) => record.cohort == cohort).take(3));
    }
    return result;
  }

  String _buildContext(List<RagRecord> records) {
    final blocks = <String>[];
    var remaining = maxContextChars;
    for (final record in records) {
      final block =
          '[${record.program} ${record.cohort}] ${record.title}\n'
          '${record.text}';
      if (block.length <= remaining) {
        blocks.add(block);
        remaining -= block.length + 2;
      } else if (blocks.isEmpty && remaining > 100) {
        blocks.add(_truncate(block, remaining));
        break;
      }
    }
    return blocks.join('\n\n');
  }

  static Iterable<RagRecord> _courseFirst(Iterable<RagRecord> records) {
    final sorted = records.toList();
    sorted.sort(
      (a, b) => _typePriority(a.type).compareTo(_typePriority(b.type)),
    );
    return sorted;
  }

  static int _typePriority(String type) => switch (type) {
    'course' => 0,
    'semester' => 1,
    'overview' => 2,
    _ => 3,
  };

  static bool _hasDirectIntent(String question) {
    const phrases = [
      'tong tin chi',
      'tong so tin chi',
      'khoi luong kien thuc',
      'chuyen nganh',
      'tu chon',
      'tien quyet',
      'hoc phan truoc',
      'dieu kien tot nghiep',
      'muc tieu dao tao',
      'chuan dau ra',
    ];
    return phrases.any(question.contains);
  }

  static bool _asksTotalCredits(String question) {
    return question.contains('tong tin chi') ||
        question.contains('tong so tin chi') ||
        question.contains('bao nhieu tin chi') ||
        question.contains('khoi luong kien thuc');
  }

  static Set<String> _detectPrograms(String question) {
    final padded = ' $question ';
    final programs = <String>{};
    final japaneseProgram =
        padded.contains(' cntt jp ') ||
        padded.contains(' cntt nhat ') ||
        padded.contains(' he tieng nhat ') ||
        padded.contains(' chuong trinh tieng nhat ') ||
        padded.contains(' viet nhat ');
    if (japaneseProgram) programs.add('CNTT-JP');

    if (!japaneseProgram &&
        (padded.contains(' cntt ') ||
            padded.contains(' nganh cong nghe thong tin ') ||
            padded.contains(' chuong trinh cong nghe thong tin '))) {
      programs.add('CNTT');
    }
    if (padded.contains(' attt ') ||
        padded.contains(' nganh an toan thong tin ') ||
        padded.contains(' chuong trinh an toan thong tin ')) {
      programs.add('ATTT');
    }
    if (padded.contains(' ktdl ') ||
        padded.contains(' nganh ky thuat du lieu ') ||
        padded.contains(' chuong trinh ky thuat du lieu ')) {
      programs.add('KTDL');
    }
    return programs;
  }

  static String? _canonicalProgram(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final programs = _detectPrograms(_normalize(value));
    if (programs.length == 1) return programs.single;
    final upper = value.trim().toUpperCase();
    return const {'CNTT', 'ATTT', 'KTDL', 'CNTT-JP'}.contains(upper)
        ? upper
        : null;
  }

  static Set<int> _detectCohorts(String question) {
    final padded = ' $question ';
    return {
      if (padded.contains(' 2023 ') ||
          padded.contains(' k23 ') ||
          padded.contains(' khoa 23 '))
        2023,
      if (padded.contains(' 2026 ') ||
          padded.contains(' k26 ') ||
          padded.contains(' khoa 26 '))
        2026,
    };
  }

  static const Set<String> _stopwords = {
    'la',
    'cua',
    'va',
    'cho',
    'toi',
    'minh',
    'em',
    'ban',
    'co',
    'the',
    'khong',
    'nhung',
    'nao',
    'gi',
    'mon',
    'hoc',
    'nen',
    'duoc',
    'trong',
    've',
    'voi',
    'mot',
    'cac',
    'nay',
    'do',
    'thi',
    'se',
    'can',
    'goi',
    'y',
    'hay',
    'vay',
    'sao',
    'nhu',
    'de',
    'tu',
    'den',
    'khi',
    'neu',
    'phai',
    'muon',
    'biet',
    'nganh',
    'khoa',
    'chuong',
    'trinh',
  };

  static Iterable<String> _tokens(String text) => text
      .split(RegExp(r'[^a-z0-9]+'))
      .where((token) => token.length >= 2 && !_stopwords.contains(token));

  static List<double> _normalizeVector(List<double> vector) {
    if (vector.length != AiService.embeddingDimensions ||
        vector.any((value) => !value.isFinite)) {
      throw const FormatException('Vector embedding không hợp lệ.');
    }
    var squaredSum = 0.0;
    for (final value in vector) {
      squaredSum += value * value;
    }
    final magnitude = math.sqrt(squaredSum);
    if (!magnitude.isFinite || magnitude == 0) {
      throw const FormatException('Vector embedding rỗng hoặc bất thường.');
    }
    return vector.map((value) => value / magnitude).toList(growable: false);
  }

  static double _cosine(List<double> a, List<double> b) {
    var score = 0.0;
    for (var i = 0; i < math.min(a.length, b.length); i++) {
      score += a[i] * b[i];
    }
    return score;
  }

  static String _truncate(String text, int maxLength) =>
      text.length <= maxLength ? text : '${text.substring(0, maxLength)}…';
}

/// Một dòng theo schema của `academic_rag_*.jsonl`.
class RagRecord {
  RagRecord({
    required this.program,
    required this.cohort,
    required this.id,
    required this.type,
    required this.title,
    required this.text,
    this.semester,
    this.courseCode,
    this.courseName,
    this.tracks = const [],
  });

  factory RagRecord.fromJson(Map<String, dynamic> json) {
    return RagRecord(
      program: json['program'] as String,
      cohort: json['cohort'] as int,
      id: json['id'] as String,
      type: json['type'] as String,
      title: json['title'] as String,
      text: json['text'] as String,
      semester: json['semester'] as int?,
      courseCode: json['courseCode'] as String?,
      courseName: json['courseName'] as String?,
      tracks: (json['tracks'] as List? ?? const [])
          .whereType<String>()
          .toList(),
    );
  }

  final String program;
  final int cohort;
  final String id;
  final String type;
  final String title;
  final String text;
  final int? semester;
  final String? courseCode;
  final String? courseName;
  final List<String> tracks;

  String get embeddingText => text;

  late final String normalizedContent = _normalize(
    '$title $text ${courseCode ?? ''} ${courseName ?? ''} ${tracks.join(' ')}',
  );
  late final Set<String> titleTokens = RagService._tokens(
    _normalize(title),
  ).toSet();
  late final Set<String> tokens = RagService._tokens(normalizedContent).toSet();
  late final String hash = sha256
      .convert(utf8.encode(embeddingText))
      .toString();
}

String _normalize(String input) => removeDiacritics(
  input.toLowerCase(),
).replaceAll(RegExp(r'[^a-z0-9]+'), ' ').replaceAll(RegExp(r'\s+'), ' ').trim();
