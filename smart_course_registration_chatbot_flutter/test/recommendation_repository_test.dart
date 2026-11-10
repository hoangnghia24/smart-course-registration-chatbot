import 'package:flutter_test/flutter_test.dart';
import 'package:smart_course_registration_chatbot_flutter/features/academic_progress/data/academic_progress_repository.dart';
import 'package:smart_course_registration_chatbot_flutter/features/curriculum_lookup/data/curriculum_lookup_repository.dart';
import 'package:smart_course_registration_chatbot_flutter/features/recommendation/data/serverpod_recommendation_repository.dart';

class _F04 implements CurriculumLookupRepository {
  _F04(this.load);
  final Future<CurriculumDetails?> Function() load;
  @override
  Future<CurriculumDetails?> getMyCurriculum() => load();
}

class _F23 implements AcademicProgressRepository {
  _F23(this.load);
  final Future<AcademicProgressDetails?> Function() load;
  @override
  Future<AcademicProgressDetails?> getMyProgress() => load();
}

const _curriculum = CurriculumDetails(
  code: 'CNTT', name: 'Công nghệ thông tin', majorCode: '7480201',
  versionCode: '2025', effectiveYear: 2025, versionStatus: 'ACTIVE',
  items: [
    CurriculumCourse(code: 'CS101', name: 'Nhập môn lập trình',
        credits: 3, semester: 1, isRequired: true),
    CurriculumCourse(code: 'CS102', name: 'Toán rời rạc',
        credits: 3, semester: 2, isRequired: true),
  ],
);

const _progress = AcademicProgressDetails(
  creditStatus: 'POLICY_PENDING', gpaStatus: 'NO_DATA',
  courses: [
    AcademicCourseProgress(code: 'CS101', name: 'Nhập môn lập trình',
      credits: 3, isRequired: true, status: 'PASSED',
      scoreStatus: 'AVAILABLE'),
    AcademicCourseProgress(code: 'CS102', name: 'Toán rời rạc',
      credits: 3, isRequired: true, status: 'NOT_STARTED',
      scoreStatus: 'NO_DATA'),
  ],
);

ServerpodRecommendationRepository _repo(
  Future<CurriculumDetails?> Function() f04,
  Future<AcademicProgressDetails?> Function() f23,
) => ServerpodRecommendationRepository.fromRepositories(
  curriculum: _F04(f04), progress: _F23(f23),
);

void main() {
  test('Có F04 và F23: ghép đúng trạng thái, không gán eligibility/priority', () async {
    final data = await _repo(() async => _curriculum,
        () async => _progress).getOverview();
    expect(data, isNotNull);
    expect(data!.courses.length, 2);
    expect(data.courses[0].progressStatus, 'PASSED');
    expect(data.courses[1].progressStatus, 'NOT_STARTED');
    expect(data.courses[1].eligibilityStatus, isNull);
    expect(data.courses[1].priorityRank, isNull);
    expect(data.courses[1].reasonCode, isNull);
    expect(data.hasRuleEngineResult, false);
  });

  test('F04 có dữ liệu, F23 null: vẫn hiển thị CTĐT, tiến độ chưa rõ', () async {
    final data = await _repo(() async => _curriculum,
        () async => null).getOverview();
    expect(data!.courses.length, 2);
    expect(data.hasCurriculum, true);
    expect(data.hasProgress, false);
    expect(data.courses[0].progressStatus, isNull);
    expect(data.partialMessage, contains('F23'));
  });

  test('F04 null, F23 có dữ liệu: fallback danh sách F23', () async {
    final data = await _repo(() async => null,
        () async => _progress).getOverview();
    expect(data!.courses.length, 2);
    expect(data.hasCurriculum, false);
    expect(data.hasProgress, true);
    expect(data.partialMessage, contains('F04'));
  });

  test('Cả hai null: không giả lập danh sách môn', () async {
    expect(await _repo(() async => null,
        () async => null).getOverview(), isNull);
  });

  test('F04 trả danh sách trống: không tự thêm môn F23 ngoài CTĐT', () async {
    const empty = CurriculumDetails(
      code: 'CNTT', name: 'CNTT', majorCode: '7480201',
      versionCode: '2025', effectiveYear: 2025,
      versionStatus: 'ACTIVE', items: [],
    );
    final data = await _repo(() async => empty,
        () async => _progress).getOverview();
    expect(data!.courses, isEmpty);
  });

  test('Một API lỗi mạng: vẫn dùng dữ liệu API còn lại', () async {
    final data = await _repo(() async => throw Exception('NETWORK'),
        () async => _progress).getOverview();
    expect(data!.courses.length, 2);
    expect(data.partialMessage, contains('Không tải được'));
  });

  test('Cả hai API lỗi mạng: trả lỗi, không giả như empty', () async {
    await expectLater(
      _repo(() async => throw Exception('NETWORK'),
          () async => throw Exception('NETWORK')).getOverview(),
      throwsStateError,
    );
  });

  test('Mã môn trùng F23 thì không suy đoán trạng thái', () async {
    const duplicates = AcademicProgressDetails(
      creditStatus: 'NO_DATA', gpaStatus: 'NO_DATA', courses: [
        AcademicCourseProgress(code: 'CS101', name: 'Môn 1',
          credits: 3, isRequired: true, status: 'FAILED',
          scoreStatus: 'NO_DATA'),
        AcademicCourseProgress(code: 'CS101', name: 'Môn 1',
          credits: 3, isRequired: true, status: 'PASSED',
          scoreStatus: 'AVAILABLE'),
      ],
    );
    final data = await _repo(() async => _curriculum,
        () async => duplicates).getOverview();
    expect(data!.courses[0].progressStatus, isNull);
    expect(data.partialMessage, contains('trùng'));
  });

  test('Lỗi phân quyền không bị che bởi API còn lại', () async {
    await expectLater(
      _repo(() async => throw Exception('FORBIDDEN'),
          () async => _progress).getOverview(),
      throwsA(isA<Exception>()),
    );
  });

  test('Khác kiểu chữ ở mã môn vẫn ghép; mã không khớp không suy đoán', () async {
    const altered = AcademicProgressDetails(
      creditStatus: 'NO_DATA', gpaStatus: 'NO_DATA', courses: [
        AcademicCourseProgress(code: ' cs101 ', name: 'Nhập môn lập trình',
          credits: 3, isRequired: true, status: 'FAILED',
          scoreStatus: 'NO_DATA'),
      ],
    );
    final data = await _repo(() async => _curriculum,
        () async => altered).getOverview();
    expect(data!.courses[0].progressStatus, 'FAILED');
    expect(data.courses[1].progressStatus, null);
  });
}
