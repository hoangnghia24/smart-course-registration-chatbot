import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'ollama_embedding_service.dart';

/// Truy xuất ngữ cảnh RAG cho chatbot từ `config/ctdt_rag.jsonl`.
///
/// Thay vì nhét cả file (hàng trăm nghìn token) vào prompt, mỗi câu hỏi chỉ
/// lấy vài bản ghi liên quan, giới hạn bởi [maxContextChars]:
/// 1. Câu hỏi theo học kỳ ("học kỳ 1", "năm nhất"…) → tra trực tiếp
///    `curriculum_item`, gom môn chung / môn riêng giữa các CTĐT.
/// 2. Câu hỏi về một học phần (mã hoặc tên môn) → `course`, `curriculum_item`,
///    `prerequisite` của môn đó.
/// 3. Phần còn lại → tìm kiếm ngữ nghĩa bằng embedding (Ollama); nếu chưa có
///    embedding thì dùng tìm kiếm từ khóa.
class CtdtRagRetriever {
  CtdtRagRetriever._(this._ragPath, this._embeddingCachePath);

  static const String defaultRagPath = 'config/ctdt_rag.jsonl';
  static const String defaultEmbeddingCachePath =
      'config/ctdt_rag.embeddings.json';

  /// Ngân sách ngữ cảnh (ký tự). ~6.500 ký tự tiếng Việt ≈ 2.500–3.000 token,
  /// đủ chỗ cho system prompt + câu trả lời trong num_ctx 8192.
  static const int maxContextChars = 6500;

  static CtdtRagRetriever? _instance;

  /// Singleton dùng chung cho mọi request.
  static CtdtRagRetriever instance({
    String ragPath = defaultRagPath,
    String embeddingCachePath = defaultEmbeddingCachePath,
  }) {
    return _instance ??= CtdtRagRetriever._(ragPath, embeddingCachePath);
  }

  final String _ragPath;
  final String _embeddingCachePath;

  List<RagRecord> _records = const [];
  Map<String, RagRecord> _byId = const {};
  Map<String, RagRecord> _courses = const {}; // courseCode -> course record
  Map<String, String> _curriculumNames = const {}; // code -> tên CTĐT
  List<MapEntry<String, String>> _courseNamesNorm = const []; // (normName, code)
  DateTime? _loadedModified;

  // Tìm kiếm từ khóa (fallback).
  Map<String, int> _docFreq = const {};

  // Tìm kiếm ngữ nghĩa.
  final OllamaEmbeddingService _embedder = OllamaEmbeddingService();
  Map<String, List<double>> _vectors = const {};
  Future<void>? _indexBuild;
  bool _embeddingUnavailable = false;

  // ------------------------------------------------------------------ public

  /// Khởi động sớm (tùy chọn, gọi trong server.dart): đọc file và bắt đầu
  /// tạo embedding chạy nền để request đầu tiên không phải chờ.
  Future<void> warmUp() async {
    await _ensureLoaded();
    _startIndexBuild();
  }

  Future<RagContext> retrieve(String question) async {
    await _ensureLoaded();
    _startIndexBuild(); // không chờ; dùng từ khóa cho tới khi xong

    final q = RagQuery.parse(question, this);
    final blocks = <String>[];
    final usedIds = <String>{};
    var budget = maxContextChars;

    bool add(String text, {String? id}) {
      final t = text.trim();
      if (t.isEmpty || (id != null && usedIds.contains(id))) return false;
      if (t.length > budget) return false;
      blocks.add(t);
      budget -= t.length + 2;
      if (id != null) usedIds.add(id);
      return true;
    }

    // Phạm vi CTĐT: ngành được nêu rõ, nếu không thì toàn bộ CTĐT trong dữ liệu.
    final scope = q.programs.isNotEmpty
        ? q.programs
        : _curriculumNames.keys.toSet();

    if (q.programs.isEmpty && _curriculumNames.length > 1) {
      add(
        'Phạm vi dữ liệu: ${q.facultyLevel ? 'Khoa Công nghệ thông tin' : 'Hệ thống'} '
        'có ${_curriculumNames.length} chương trình đào tạo: '
        '${_curriculumNames.entries.map((e) => '${e.value} (${e.key})').join(', ')}. '
        'Câu hỏi chưa nêu rõ ngành.',
      );
    }

    var structured = false;

    // 1) Theo học kỳ.
    if (q.semesters.isNotEmpty) {
      for (final s in q.semesters.toList()..sort()) {
        final block = _semesterBlock(s, scope,
            electivesOnly: q.asksElective, tracks: q.tracks);
        if (block != null && add(block)) structured = true;
      }
    }

    // 2) Theo học phần.
    for (final code in q.courseCodes.take(3)) {
      final course = _courses[code];
      if (course == null) continue;
      structured = true;
      add(_truncate(course.text, 900), id: course.id);
      for (final r in _records) {
        if (r.type == 'curriculum_item' &&
            r.data['courseCode'] == code &&
            r.curriculumCodes.any(scope.contains)) {
          add(r.text, id: r.id);
        }
      }
      final dependents = <String>[];
      for (final r in _records) {
        if (r.type != 'prerequisite' || !r.curriculumCodes.any(scope.contains)) {
          continue;
        }
        if (r.data['courseCode'] == code) add(r.text, id: r.id);
        if (r.data['prerequisiteCourseCode'] == code) {
          dependents.add(_courseLabel(r.data['courseCode'] as String));
        }
      }
      if (dependents.isNotEmpty) {
        add('${_courseLabel(code)} là học phần trước/tiên quyết của: '
            '${dependents.join(', ')}.');
      }
    }

    // 3) Tìm kiếm ngữ nghĩa / từ khóa để bổ sung.
    final topK = structured ? 2 : 6;
    final hits = await _search(question, q, scope, topK + 4);
    var taken = 0;
    for (final r in hits) {
      if (taken >= topK) break;
      // Đã có dữ liệu có cấu trúc → không chèn thêm môn/tiên quyết lạc đề
      // (ví dụ môn của học kỳ khác), chỉ bổ sung văn bản mô tả chung.
      if (structured &&
          (r.type == 'curriculum_item' || r.type == 'prerequisite')) {
        continue;
      }
      if (add(_truncate(r.text, 1600), id: r.id)) taken++;
    }

    return RagContext(
      text: blocks.join('\n\n'),
      recordIds: usedIds.toList(),
      programs: scope,
      semesters: q.semesters,
      usedEmbedding: _vectors.isNotEmpty,
    );
  }

  // ------------------------------------------------------------ structured

  String? _semesterBlock(int semester, Set<String> scope,
      {bool electivesOnly = false, Set<String> tracks = const {}}) {
    // courseCode -> (set CTĐT, isRequired?, ghi chú)
    final byCourse = <String, _SemesterEntry>{};
    for (final r in _records) {
      if (r.type != 'curriculum_item') continue;
      final cur = r.data['curriculumCode'] as String?;
      if (cur == null || !scope.contains(cur)) continue;
      final semesters = <int>{
        if (r.data['semester'] is int) r.data['semester'] as int,
        ...((r.extra['semesters'] as List?) ?? const []).whereType<int>(),
      };
      if (!semesters.contains(semester)) continue;
      final isRequired = r.data['isRequired'] == true;
      if (electivesOnly && isRequired) continue;
      final itemTrack = r.extra['track'] as String?;
      if (tracks.isNotEmpty && itemTrack != null && !tracks.contains(itemTrack)) {
        continue; // môn của chuyên ngành khác
      }
      final code = r.data['courseCode'] as String;
      final e = byCourse.putIfAbsent(code, () => _SemesterEntry(code));
      e.programs.add(cur);
      e.required[cur] = isRequired;
      final group = r.data['groupCode'] as String? ?? '';
      if (group.startsWith('III') || group.startsWith('IV')) {
        e.notCounted = true;
      }
      final track = r.extra['track'] as String?;
      if (track != null) e.tracks.add(track);
    }
    if (byCourse.isEmpty) return null;

    // Gom theo tập CTĐT có môn đó.
    final groups = <String, List<_SemesterEntry>>{};
    for (final e in byCourse.values) {
      final key = (e.programs.toList()..sort()).join(',');
      groups.putIfAbsent(key, () => []).add(e);
    }
    final keys = groups.keys.toList()
      ..sort((a, b) => b.split(',').length.compareTo(a.split(',').length));

    final lines = <String>[];
    final scopeName = scope.length == 1
        ? 'CTĐT ${_curriculumNames[scope.first] ?? scope.first}'
        : '${scope.length} CTĐT (${(scope.toList()..sort()).join(', ')})';
    lines.add('Kế hoạch giảng dạy dự kiến – Học kỳ $semester – $scopeName:');
    for (final key in keys) {
      final progs = key.split(',');
      final label = scope.length == 1
          ? '- Các học phần'
          : progs.length == scope.length
              ? '- Chung cho tất cả ${progs.join(', ')}'
              : '- Chỉ có ở ${progs.join(', ')}';
      final items = groups[key]!
        ..sort((a, b) => _courseName(a.code).compareTo(_courseName(b.code)));
      final desc = items.map((e) {
        final parts = <String>[e.code, '${_courseCredits(e.code)} TC'];
        final allRequired = e.required.values.every((v) => v);
        final noneRequired = e.required.values.every((v) => !v);
        if (noneRequired) parts.add('tự chọn');
        if (!allRequired && !noneRequired) parts.add('bắt buộc/tự chọn tùy ngành');
        if (e.tracks.isNotEmpty) parts.add('theo ${e.tracks.join(', ')}');
        if (e.notCounted) parts.add('không tính vào tổng TC tốt nghiệp');
        return '${_courseName(e.code)} (${parts.join(', ')})';
      }).join('; ');
      lines.add('$label: $desc.');
    }
    return lines.join('\n');
  }

  String _courseName(String code) =>
      (_courses[code]?.data['name'] as String?) ?? code;

  Object _courseCredits(String code) =>
      _courses[code]?.data['credits'] ?? '?';

  String _courseLabel(String code) => '${_courseName(code)} ($code)';

  // ----------------------------------------------------------------- search

  Future<List<RagRecord>> _search(
    String question,
    RagQuery q,
    Set<String> scope,
    int k,
  ) async {
    bool inScope(RagRecord r) =>
        r.curriculumCodes.isEmpty || r.curriculumCodes.any(scope.contains);

    final candidates = _records.where(inScope).toList();

    if (_vectors.isNotEmpty) {
      try {
        final qv = _normalize(await _embedder.embedQuery(question));
        final scored = <MapEntry<RagRecord, double>>[];
        for (final r in candidates) {
          final v = _vectors[r.id];
          if (v == null) continue;
          scored.add(MapEntry(r, _dot(qv, v)));
        }
        scored.sort((a, b) => b.value.compareTo(a.value));
        return scored.take(k).map((e) => e.key).toList();
      } catch (e) {
        stdout.writeln('[RAG] Embedding query lỗi, dùng từ khóa: $e');
      }
    }
    return _keywordSearch(q.norm, candidates, k);
  }

  List<RagRecord> _keywordSearch(
      String normQuestion, List<RagRecord> candidates, int k) {
    final tokens = _tokens(normQuestion).toSet();
    if (tokens.isEmpty) return const [];
    final n = math.max(_records.length, 1);
    final bigrams = _bigrams(normQuestion);
    final scored = <MapEntry<RagRecord, double>>[];
    for (final r in candidates) {
      var score = 0.0;
      for (final t in tokens) {
        if (r.tokenSet.contains(t)) {
          score += math.log(n / (1 + (_docFreq[t] ?? 0))) + 1;
        }
      }
      for (final b in bigrams) {
        if (r.normText.contains(b)) score += 1.5;
      }
      if (score > 0) scored.add(MapEntry(r, score / math.sqrt(r.tokenSet.length + 20)));
    }
    scored.sort((a, b) => b.value.compareTo(a.value));
    return scored.take(k).map((e) => e.key).toList();
  }

  // ------------------------------------------------------------ load/index

  Future<void> _ensureLoaded() async {
    final file = File(_ragPath);
    late final DateTime modified;
    try {
      modified = await file.lastModified();
    } on FileSystemException {
      throw StateError('RAG_FILE_NOT_FOUND: $_ragPath');
    }
    if (_loadedModified == modified && _records.isNotEmpty) return;

    final records = <RagRecord>[];
    for (final line in await file.readAsLines()) {
      if (line.trim().isEmpty) continue;
      final json = jsonDecode(line);
      if (json is Map<String, dynamic>) records.add(RagRecord.fromJson(json));
    }
    if (records.isEmpty) throw StateError('RAG_FILE_EMPTY: $_ragPath');

    final courses = <String, RagRecord>{};
    final curricula = <String, String>{};
    for (final r in records) {
      if (r.type == 'course' && r.data['code'] is String) {
        courses[r.data['code'] as String] = r;
      } else if (r.type == 'curriculum' && r.data['code'] is String) {
        curricula[r.data['code'] as String] = r.data['name'] as String? ?? '';
      }
    }
    final names = <MapEntry<String, String>>[];
    courses.forEach((code, r) {
      final name = r.data['name'] as String? ?? '';
      // Tên đầy đủ và tên bỏ phần trong ngoặc: "Giải tích 1 (Giải tích một biến số)".
      for (final variant in {name, name.replaceAll(RegExp(r'\s*\(.*?\)'), '')}) {
        final n = VnText.normalize(variant).trim();
        if (n.length >= 5) names.add(MapEntry(n, code));
      }
      final inner = RegExp(r'\((.*?)\)').firstMatch(name)?.group(1);
      if (inner != null && VnText.normalize(inner).length >= 8) {
        names.add(MapEntry(VnText.normalize(inner).trim(), code));
      }
    });
    names.sort((a, b) => b.key.length.compareTo(a.key.length));

    final df = <String, int>{};
    for (final r in records) {
      for (final t in r.tokenSet) {
        df[t] = (df[t] ?? 0) + 1;
      }
    }

    _records = records;
    _byId = {for (final r in records) r.id: r};
    _courses = courses;
    _curriculumNames = curricula;
    _courseNamesNorm = names;
    _docFreq = df;
    _loadedModified = modified;
    // File đổi → các vector cũ có thể lệch; giữ lại vector của id còn tồn tại,
    // bản ghi mới/đổi nội dung sẽ được tạo lại ở lần build kế tiếp.
    _vectors = {
      for (final e in _vectors.entries)
        if (_byId.containsKey(e.key)) e.key: e.value,
    };
    _indexBuild = null;
  }

  void _startIndexBuild() {
    if (_embeddingUnavailable || _indexBuild != null) return;
    _indexBuild = _buildIndex().catchError((Object e) {
      _embeddingUnavailable = true;
      stdout.writeln(
        '[RAG] Không tạo được embedding ($e). Chatbot dùng tìm kiếm từ khóa. '
        'Kiểm tra: ollama pull ${OllamaEmbeddingService.model}',
      );
    });
  }

  Future<void> _buildIndex() async {
    // Đọc cache: {model, dimensions, items: {id: {h: hash, v: [..]}}}
    final cacheFile = File(_embeddingCachePath);
    final cached = <String, Map<String, dynamic>>{};
    if (await cacheFile.exists()) {
      try {
        final json = jsonDecode(await cacheFile.readAsString());
        if (json is Map<String, dynamic> &&
            json['model'] == OllamaEmbeddingService.model &&
            json['dimensions'] == OllamaEmbeddingService.dimensions &&
            json['items'] is Map<String, dynamic>) {
          (json['items'] as Map<String, dynamic>).forEach((id, v) {
            if (v is Map<String, dynamic>) cached[id] = v;
          });
        }
      } catch (_) {
        // cache hỏng → tạo lại
      }
    }

    final vectors = <String, List<double>>{};
    final missing = <RagRecord>[];
    for (final r in _records) {
      final c = cached[r.id];
      if (c != null && c['h'] == r.hash && c['v'] is List) {
        vectors[r.id] = (c['v'] as List).map((x) => (x as num).toDouble()).toList();
      } else {
        missing.add(r);
      }
    }

    if (missing.isNotEmpty) {
      stdout.writeln('[RAG] Đang tạo embedding cho ${missing.length} bản ghi…');
      const batchSize = 16;
      for (var i = 0; i < missing.length; i += batchSize) {
        final batch = missing.sublist(i, math.min(i + batchSize, missing.length));
        final out = await _embedder
            .embedDocuments(batch.map((r) => _truncate(r.text, 2000)).toList());
        for (var j = 0; j < batch.length; j++) {
          vectors[batch[j].id] = _normalize(out[j]);
        }
      }
      final items = <String, dynamic>{
        for (final r in _records)
          if (vectors[r.id] != null) r.id: {'h': r.hash, 'v': vectors[r.id]},
      };
      await cacheFile.writeAsString(jsonEncode({
        'model': OllamaEmbeddingService.model,
        'dimensions': OllamaEmbeddingService.dimensions,
        'items': items,
      }));
      stdout.writeln('[RAG] Đã lưu embedding vào $_embeddingCachePath');
    }
    _vectors = vectors;
  }

  // ---------------------------------------------------------------- helpers

  static String _truncate(String s, int max) =>
      s.length <= max ? s : '${s.substring(0, max)}…';

  static List<double> _normalize(List<double> v) {
    var sum = 0.0;
    for (final x in v) {
      sum += x * x;
    }
    final norm = math.sqrt(sum);
    if (norm == 0) return v;
    return v.map((x) => x / norm).toList(growable: false);
  }

  static double _dot(List<double> a, List<double> b) {
    final n = math.min(a.length, b.length);
    var s = 0.0;
    for (var i = 0; i < n; i++) {
      s += a[i] * b[i];
    }
    return s;
  }

  static const Set<String> _stopwords = {
    'la', 'cua', 'va', 'cho', 'toi', 'minh', 'em', 'ban', 'co', 'the', 'khong',
    'nhung', 'nao', 'gi', 'mon', 'hoc', 'nen', 'duoc', 'trong', 've', 'voi',
    'mot', 'cac', 'nay', 'do', 'thi', 'se', 'can', 'goi', 'y', 'hay', 'a', 'oi',
    'vay', 'sao', 'nhu', 'de', 'tu', 'den', 'khi', 'neu', 'phai', 'muon', 'biet',
  };

  static Iterable<String> _tokens(String norm) => norm
      .split(RegExp(r'[^a-z0-9]+'))
      .where((t) => t.length >= 2 && !_stopwords.contains(t));

  static List<String> _bigrams(String norm) {
    final t = norm.split(RegExp(r'[^a-z0-9]+')).where((x) => x.isNotEmpty).toList();
    return [
      for (var i = 0; i + 1 < t.length; i++)
        if (!_stopwords.contains(t[i]) || !_stopwords.contains(t[i + 1]))
          '${t[i]} ${t[i + 1]}',
    ];
  }
}

class _SemesterEntry {
  _SemesterEntry(this.code);
  final String code;
  final Set<String> programs = {};
  final Map<String, bool> required = {};
  final Set<String> tracks = {};
  bool notCounted = false;
}

/// Kết quả truy xuất đưa vào prompt.
class RagContext {
  RagContext({
    required this.text,
    required this.recordIds,
    required this.programs,
    required this.semesters,
    required this.usedEmbedding,
  });

  final String text;
  final List<String> recordIds;
  final Set<String> programs;
  final Set<int> semesters;
  final bool usedEmbedding;

  bool get isEmpty => text.trim().isEmpty;
}

/// Một dòng của ctdt_rag.jsonl.
class RagRecord {
  RagRecord({
    required this.id,
    required this.type,
    required this.text,
    required this.data,
    required this.extra,
    required this.curriculumCodes,
  });

  factory RagRecord.fromJson(Map<String, dynamic> json) {
    final data = (json['data'] as Map?)?.cast<String, dynamic>() ?? {};
    final extra = (json['extra'] as Map?)?.cast<String, dynamic>() ?? {};
    final type = json['type'] as String? ?? '';
    final codes = <String>{};
    void addAll(Object? v) {
      if (v is String) codes.add(v);
      if (v is List) codes.addAll(v.whereType<String>());
    }

    addAll(data['curriculumCode']);
    addAll(data['curriculumCodes']);
    addAll(extra['curriculumCodes']);
    if (type == 'curriculum') addAll(data['code']);
    return RagRecord(
      id: json['id'] as String,
      type: type,
      text: json['text'] as String? ?? '',
      data: data,
      extra: extra,
      curriculumCodes: codes,
    );
  }

  final String id;
  final String type;
  final String text;
  final Map<String, dynamic> data;
  final Map<String, dynamic> extra;
  final Set<String> curriculumCodes;

  late final String normText = VnText.normalize(text);
  late final Set<String> tokenSet =
      CtdtRagRetriever._tokens(normText).toSet();

  /// FNV-1a 32-bit của text, dùng để biết embedding cũ còn hợp lệ không.
  late final String hash = () {
    var h = 0x811c9dc5;
    for (final b in utf8.encode(text)) {
      h ^= b;
      h = (h * 0x01000193) & 0xffffffff;
    }
    return h.toRadixString(16);
  }();
}

/// Phân tích câu hỏi: ngành, học kỳ, học phần.
class RagQuery {
  RagQuery._(this.norm);

  final String norm;
  final Set<String> programs = {};
  bool facultyLevel = false;
  final Set<int> semesters = {};
  final Set<String> courseCodes = {};
  final Set<String> tracks = {}; // "Chuyên ngành …" như trong extra.track
  bool asksElective = false;

  static RagQuery parse(String question, CtdtRagRetriever retriever) {
    final q = RagQuery._(VnText.normalize(question));
    var s = ' ${q.norm} ';

    // "khoa công nghệ thông tin" là cấp Khoa (gồm nhiều ngành), không phải ngành CNTT.
    final faculty = RegExp(r' khoa (cong nghe thong tin|cntt) ');
    if (faculty.hasMatch(s)) {
      q.facultyLevel = true;
      s = s.replaceAll(faculty, ' ');
    }
    final known = retriever._curriculumNames.keys.toSet();
    void program(String code, String pattern) {
      if (known.contains(code) && RegExp(pattern).hasMatch(s)) {
        q.programs.add(code);
      }
    }

    program('CNTT', r' (cntt|nganh cong nghe thong tin|ctdt cong nghe thong tin|chuong trinh cong nghe thong tin) ');
    program('ATTT', r' (attt|nganh an toan thong tin|ctdt an toan thong tin|chuong trinh an toan thong tin) ');
    program('KTDL', r' (ktdl|ky thuat du lieu) ');
    // "công nghệ thông tin" đứng một mình (không phải tên môn) → ngành CNTT.
    if (q.programs.isEmpty &&
        RegExp(r' cong nghe thong tin ').hasMatch(s) &&
        !RegExp(r' (mon|hoc phan) cong nghe thong tin ').hasMatch(s)) {
      if (known.contains('CNTT')) q.programs.add('CNTT');
    }

    // Chuyên ngành (của CTĐT CNTT). Bỏ cụm này trước khi dò tên môn để
    // "chuyên ngành trí tuệ nhân tạo" không bị hiểu là môn Trí tuệ nhân tạo.
    const trackPatterns = {
      r' (chuyen nganh |cn )?(cong nghe phan mem|cnpm) ': 'Chuyên ngành Công nghệ phần mềm',
      r' (chuyen nganh |cn )?(he thong thong tin|httt) ': 'Chuyên ngành Hệ thống thông tin',
      r' (chuyen nganh |cn )(tri tue nhan tao) | ttnt ': 'Chuyên ngành Trí tuệ nhân tạo',
    };
    trackPatterns.forEach((pattern, track) {
      final re = RegExp(pattern);
      final m = re.firstMatch(s);
      if (m == null) return;
      // "công nghệ phần mềm"/"hệ thống thông tin" không có chữ "chuyên ngành"
      // có thể là tên môn → chỉ nhận là chuyên ngành khi có chữ "chuyên ngành"
      // hoặc viết tắt.
      final text = m.group(0)!;
      if (!text.contains('chuyen nganh') && !RegExp(r' (cn |cnpm|httt|ttnt)').hasMatch(text)) {
        return;
      }
      q.tracks.add(track);
      s = s.replaceAll(re, ' ');
    });
    if (q.tracks.isNotEmpty && known.contains('CNTT')) q.programs.add('CNTT');

    // Học kỳ.
    for (final m in RegExp(r'\b(?:hoc ky|hoc ki|hk|ky|ki)\s*(\d{1,2})\b').allMatches(q.norm)) {
      final n = int.parse(m.group(1)!);
      if (n >= 1 && n <= 10) q.semesters.add(n);
    }
    const years = {
      r'\bnam (nhat|1|mot)\b': [1, 2],
      r'\bnam (hai|2)\b': [3, 4],
      r'\bnam (ba|3)\b': [5, 6],
      r'\bnam (tu|4|cuoi)\b': [7, 8],
    };
    years.forEach((pattern, sems) {
      if (RegExp(pattern).hasMatch(q.norm)) q.semesters.addAll(sems);
    });

    // Mã học phần.
    for (final m in RegExp(r'\b([A-Za-z]{4})\s?(\d{6})\b').allMatches(question)) {
      final code = '${m.group(1)!.toUpperCase()}${m.group(2)}';
      if (retriever._courses.containsKey(code)) q.courseCodes.add(code);
    }
    // Tên học phần (ưu tiên tên dài; bỏ tên trùng với tên ngành vừa nhận).
    var rest = s;
    for (final e in retriever._courseNamesNorm) {
      if (q.courseCodes.length >= 3) break;
      final pattern = ' ${e.key} ';
      if (!rest.contains(pattern)) continue;
      final isProgramName = (e.key == 'cong nghe thong tin' && q.programs.contains('CNTT')) ||
          (e.key == 'an toan thong tin' && q.programs.contains('ATTT') &&
              !RegExp(r' (mon|hoc phan) an toan thong tin ').hasMatch(rest));
      if (isProgramName) continue;
      q.courseCodes.add(e.value);
      rest = rest.replaceAll(pattern, ' ');
    }

    q.asksElective = RegExp(r'\btu chon\b').hasMatch(q.norm);
    return q;
  }
}

/// Chuẩn hóa tiếng Việt: chữ thường, bỏ dấu, gộp khoảng trắng.
class VnText {
  static const Map<String, String> _map = {
    'a': 'àáạảãâầấậẩẫăằắặẳẵ',
    'e': 'èéẹẻẽêềếệểễ',
    'i': 'ìíịỉĩ',
    'o': 'òóọỏõôồốộổỗơờớợởỡ',
    'u': 'ùúụủũưừứựửữ',
    'y': 'ỳýỵỷỹ',
    'd': 'đ',
  };

  static final Map<int, String> _lookup = {
    for (final e in _map.entries)
      for (final c in e.value.runes) c: e.key,
  };

  static final RegExp _combining = RegExp('[̀-ͯ]');

  static String normalize(String input) {
    final lower = input.toLowerCase().replaceAll(_combining, '');
    final sb = StringBuffer();
    for (final r in lower.runes) {
      sb.write(_lookup[r] ?? String.fromCharCode(r));
    }
    return sb
        .toString()
        .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}
