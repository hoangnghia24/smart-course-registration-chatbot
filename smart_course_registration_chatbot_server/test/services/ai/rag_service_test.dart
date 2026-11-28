import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:smart_course_registration_chatbot_server/src/generated/protocol.dart';
import 'package:smart_course_registration_chatbot_server/src/services/ai/ai_service.dart';
import 'package:smart_course_registration_chatbot_server/src/services/ai/rag_service.dart';
import 'package:test/test.dart';

void main() {
  late Directory tempDirectory;
  late RagService service;
  var embeddingCalls = 0;

  setUpAll(() async {
    tempDirectory = await Directory.systemTemp.createTemp('rag-service-test-');
    service = RagService(
      embeddingCachePath:
          '${tempDirectory.path}${Platform.pathSeparator}missing-cache.json',
      aiService: AiService(
        client: MockClient((request) async {
          embeddingCalls++;
          throw http.ClientException('Ollama unavailable', request.url);
        }),
      ),
    );
  });

  tearDownAll(() async {
    if (await tempDirectory.exists()) {
      await tempDirectory.delete(recursive: true);
    }
  });

  test(
    'retrieves total credits for every supported program and cohort',
    () async {
      const scopes = [
        ('CNTT', 2023, '150'),
        ('CNTT', 2026, '150'),
        ('ATTT', 2023, '150'),
        ('ATTT', 2026, '150'),
        ('KTDL', 2023, '150'),
        ('KTDL', 2026, '150'),
        ('CNTT hệ tiếng Nhật', 2026, '160'),
      ];

      for (final (program, cohort, credits) in scopes) {
        final context = await service.retrieve(
          'Tổng số tín chỉ ngành $program khóa $cohort là bao nhiêu?',
        );
        expect(context, contains(credits), reason: '$program $cohort');
      }
    },
  );

  test('retrieves pre-aggregated semester records', () async {
    final cntt = await service.retrieve('CNTT khóa 2023 học kỳ 3 học môn gì?');
    final attt = await service.retrieve('ATTT K26 học kỳ 1 gồm môn nào?');
    final japanese = await service.retrieve(
      'CNTT hệ tiếng Nhật khóa 2026 học kỳ 1 gồm môn nào?',
    );

    expect(cntt, contains('DASA230179'));
    expect(attt, contains('INPR130285'));
    expect(japanese, contains('VJEC131847'));
  });

  test(
    'uses only the student cohort for an unspecified semester question',
    () async {
      final context = await service.retrieve(
        'Học kỳ 7 học những môn gì?',
        defaultProgram: 'CNTT',
        defaultCohort: 2023,
      );

      expect(context, contains('[CNTT 2023]'));
      expect(context, isNot(contains('[CNTT 2026]')));
    },
  );

  test('requires student scope before answering a semester question', () async {
    final context = await service.retrieve('Học kỳ 7 học những môn gì?');

    expect(context, contains('Chưa xác định được chương trình'));
  });

  test('retrieves course code, credits and prerequisites', () async {
    final context = await service.retrieve(
      'Môn DBSY240184 của CNTT khóa 2023 có bao nhiêu tín chỉ và tiên quyết gì?',
    );

    expect(context, contains('Cơ sở dữ liệu'));
    expect(context, contains('4 tín chỉ'));
    expect(context, contains('DASA230179'));
  });

  test('retrieves electives and specializations', () async {
    final electives = await service.retrieve(
      'Nhóm học phần tự chọn chuyên ngành CNPM của CNTT khóa 2023 gồm môn nào?',
    );
    final specializations = await service.retrieve(
      'CNTT khóa 2023 có các chuyên ngành nào?',
    );

    expect(electives, anyOf(contains('TOEN430979'), contains('tự chọn')));
    expect(specializations, contains('Công nghệ phần mềm'));
  });

  test('keeps both cohorts separate when comparing them', () async {
    final context = await service.retrieve(
      'So sánh tổng số tín chỉ CNTT khóa 2023 và 2026.',
    );

    expect(context, contains('[CNTT 2023]'));
    expect(context, contains('[CNTT 2026]'));
  });

  test(
    'uses student scope and handles questions outside available data',
    () async {
      final scoped = await service.retrieve(
        'Tổng số tín chỉ là bao nhiêu?',
        defaultProgram: 'ATTT',
        defaultCohort: 2026,
      );
      final outside = await service.retrieve(
        'Thời tiết hôm nay thế nào?',
        defaultProgram: 'ATTT',
        defaultCohort: 2026,
      );

      expect(scoped, contains('[ATTT 2026]'));
      expect(outside, startsWith('Không tìm thấy dữ liệu phù hợp'));
    },
  );

  test('asks for missing scope and rejects unsupported cohorts', () async {
    expect(
      await service.retrieve('Tổng số tín chỉ là bao nhiêu?'),
      contains('Chưa xác định được chương trình'),
    );
    expect(
      await service.retrieve('CNTT khóa 2024 có bao nhiêu tín chỉ?'),
      contains('chỉ hỗ trợ khóa 2023 và 2026'),
    );
  });

  test(
    'uses keyword search without calling embedding when cache is absent',
    () async {
      final context = await service.retrieve(
        'Mục tiêu đào tạo của ngành KTDL khóa 2026 là gì?',
      );

      expect(context, contains('[KTDL 2026]'));
      expect(context.toLowerCase(), contains('mục tiêu'));
      expect(embeddingCalls, 0);
    },
  );

  test('uses semantic search only with a fully valid cache', () async {
    final fixture = await _writeFixture(tempDirectory, validCache: true);
    var queryCalls = 0;
    final semanticService = RagService(
      ragPaths: [fixture.rag.path],
      embeddingCachePath: fixture.cache.path,
      aiService: AiService(
        client: MockClient((request) async {
          queryCalls++;
          return http.Response(
            jsonEncode({
              'embeddings': [_vector(0)],
            }),
            200,
          );
        }),
      ),
    );

    final context = await semanticService.retrieve(
      'nội dung không có từ khóa trực tiếp',
      defaultProgram: 'CNTT',
      defaultCohort: 2023,
    );

    expect(context, contains('Bản ghi semantic'));
    expect(queryCalls, 1);
  });

  test('accepts the generated cache for all current RAG files', () async {
    final cacheJson =
        jsonDecode(
              await File(RagService.defaultEmbeddingCachePath).readAsString(),
            )
            as Map<String, dynamic>;
    final items = cacheJson['items'] as Map<String, dynamic>;
    final firstItem = items.values.first as Map<String, dynamic>;
    final vector = (firstItem['v'] as List)
        .map((value) => (value as num).toDouble())
        .toList(growable: false);
    var queryCalls = 0;
    final generatedCacheService = RagService(
      aiService: AiService(
        client: MockClient((request) async {
          queryCalls++;
          return http.Response(
            jsonEncode({
              'embeddings': [vector],
            }),
            200,
          );
        }),
      ),
    );

    final context = await generatedCacheService.retrieve(
      'truy vấn semantic không trùng từ khóa dữ liệu',
      defaultProgram: 'CNTT',
      defaultCohort: 2023,
    );

    expect(context, contains('[CNTT 2023]'));
    expect(queryCalls, 1);
  });

  test(
    'rejects an incompatible cache and falls back to keyword search',
    () async {
      final fixture = await _writeFixture(tempDirectory, validCache: false);
      var queryCalls = 0;
      final fallbackService = RagService(
        ragPaths: [fixture.rag.path],
        embeddingCachePath: fixture.cache.path,
        aiService: AiService(
          client: MockClient((request) async {
            queryCalls++;
            throw http.ClientException('Unexpected embedding call');
          }),
        ),
      );

      final context = await fallbackService.retrieve(
        'dữ liệu semantic',
        defaultProgram: 'CNTT',
        defaultCohort: 2023,
      );

      expect(context, contains('Bản ghi semantic'));
      expect(queryCalls, 0);
    },
  );

  test('rejects an abnormal vector and falls back to keyword search', () async {
    final fixture = await _writeFixture(tempDirectory, validCache: true);
    final json = jsonDecode(await fixture.cache.readAsString());
    final items =
        (json as Map<String, dynamic>)['items'] as Map<String, dynamic>;
    (items['fixture_1'] as Map<String, dynamic>)['v'] = List<double>.filled(
      AiService.embeddingDimensions,
      0,
    );
    await fixture.cache.writeAsString(jsonEncode(json));
    var queryCalls = 0;
    final fallbackService = RagService(
      ragPaths: [fixture.rag.path],
      embeddingCachePath: fixture.cache.path,
      aiService: AiService(
        client: MockClient((request) async {
          queryCalls++;
          throw http.ClientException('Unexpected embedding call');
        }),
      ),
    );

    final context = await fallbackService.retrieve(
      'dữ liệu semantic',
      defaultProgram: 'CNTT',
      defaultCohort: 2023,
    );

    expect(context, contains('Bản ghi semantic'));
    expect(queryCalls, 0);
  });

  test('rejects duplicate record IDs across files', () async {
    final first = File('${tempDirectory.path}${Platform.pathSeparator}a.jsonl');
    final second = File(
      '${tempDirectory.path}${Platform.pathSeparator}b.jsonl',
    );
    final record = jsonEncode(_fixtureRecord);
    await first.writeAsString(record);
    await second.writeAsString(record);
    final duplicateService = RagService(
      ragPaths: [first.path, second.path],
      embeddingCachePath:
          '${tempDirectory.path}${Platform.pathSeparator}none.json',
    );

    await expectLater(
      duplicateService.retrieve(
        'CNTT 2023',
        defaultProgram: 'CNTT',
        defaultCohort: 2023,
      ),
      throwsA(
        isA<AppException>().having(
          (error) => error.code,
          'code',
          'RAG_DUPLICATE_ID',
        ),
      ),
    );
  });

  test('precomputes a cache with model, dimensions and SHA-256 hash', () async {
    final rag = File(
      '${tempDirectory.path}${Platform.pathSeparator}generator.jsonl',
    );
    final cache = File(
      '${tempDirectory.path}${Platform.pathSeparator}generated-cache.json',
    );
    await rag.writeAsString(jsonEncode(_fixtureRecord));
    await cache.writeAsString('previous cache');
    var documentCalls = 0;

    await RagService.generateEmbeddingCache(
      ragPaths: [rag.path],
      outputPath: cache.path,
      aiService: AiService(
        client: MockClient((request) async {
          documentCalls++;
          return http.Response(
            jsonEncode({
              'embeddings': [_vector(0)],
            }),
            200,
          );
        }),
      ),
    );

    final json = jsonDecode(await cache.readAsString()) as Map<String, dynamic>;
    final item =
        (json['items'] as Map<String, dynamic>)['fixture_1']
            as Map<String, dynamic>;
    expect(json['model'], AiService.embeddingModel);
    expect(json['dimensions'], AiService.embeddingDimensions);
    expect(
      item['h'],
      sha256.convert(utf8.encode(_fixtureRecord['text']! as String)).toString(),
    );
    expect(documentCalls, 1);
    final backups = await tempDirectory
        .list()
        .where(
          (entity) =>
              entity.path.startsWith('${cache.path}.') &&
              entity.path.endsWith('.bak'),
        )
        .toList();
    expect(backups, isEmpty);
  });

  test('keeps the previous cache when embedding generation fails', () async {
    final rag = File(
      '${tempDirectory.path}${Platform.pathSeparator}failed-generator.jsonl',
    );
    final cache = File(
      '${tempDirectory.path}${Platform.pathSeparator}preserved-cache.json',
    );
    await rag.writeAsString(jsonEncode(_fixtureRecord));
    await cache.writeAsString('previous cache');

    await expectLater(
      RagService.generateEmbeddingCache(
        ragPaths: [rag.path],
        outputPath: cache.path,
        aiService: AiService(
          client: MockClient(
            (request) async => http.Response(
              jsonEncode({
                'embeddings': [
                  List<double>.filled(AiService.embeddingDimensions, 0),
                ],
              }),
              200,
            ),
          ),
        ),
      ),
      throwsA(isA<FormatException>()),
    );

    expect(await cache.readAsString(), 'previous cache');
  });
}

const _fixtureRecord = {
  'program': 'CNTT',
  'cohort': 2023,
  'id': 'fixture_1',
  'type': 'information',
  'title': 'Bản ghi semantic',
  'text': 'Nội dung dữ liệu semantic dành cho kiểm thử.',
  'pages': [1],
};

Future<({File rag, File cache})> _writeFixture(
  Directory directory, {
  required bool validCache,
}) async {
  final suffix = validCache ? 'valid' : 'invalid';
  final rag = File(
    '${directory.path}${Platform.pathSeparator}fixture-$suffix.jsonl',
  );
  final cache = File(
    '${directory.path}${Platform.pathSeparator}fixture-$suffix-cache.json',
  );
  await rag.writeAsString(jsonEncode(_fixtureRecord));

  final hashSource = _fixtureRecord['text']! as String;
  await cache.writeAsString(
    jsonEncode({
      'model': AiService.embeddingModel,
      'dimensions': AiService.embeddingDimensions,
      'items': {
        'fixture_1': {
          'h': validCache
              ? sha256.convert(utf8.encode(hashSource)).toString()
              : 'incompatible',
          'v': _vector(0),
        },
      },
    }),
  );
  return (rag: rag, cache: cache);
}

List<double> _vector(int position) => List<double>.generate(
  AiService.embeddingDimensions,
  (index) => index == position ? 1 : 0,
  growable: false,
);
