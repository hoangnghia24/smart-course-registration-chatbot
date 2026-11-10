import 'package:flutter_test/flutter_test.dart';
import 'package:smart_course_registration_chatbot_flutter/features/recommendation/data/contract_recommendation_repository.dart';

void main() {
  test('Official contract: eligible và priority độc lập, reasonCodes nguyên trạng', () {
    final result = parseRecommendationContract({
      'semesterId': 6,
      'policyVersion': 'RULES-1',
      'calculatedAt': '2026-11-07T00:00:00Z',
      'items': [
        {
          'courseId': 12, 'code': 'SE202', 'name': 'Cấu trúc dữ liệu',
          'credits': 3, 'eligible': true, 'priority': 1, 'score': 90,
          'reasonCodes': ['REQUIRED_IN_CURRICULUM', 'PREREQUISITES_SATISFIED'],
          'reasonDetails': [
            {'code': 'PREREQUISITES_SATISFIED', 'message': 'Đã đáp ứng môn tiên quyết.'}
          ],
          'availableClassCount': 2,
        },
        {
          'courseId': 13, 'code': 'SE203', 'name': 'Cơ sở dữ liệu',
          'credits': 3, 'eligible': false, 'priority': null,
          'reasonCodes': ['PREREQUISITE_NOT_MET'],
          'availableClassCount': null,
        },
      ],
    });
    expect(result.isOfficialRecommendation, isTrue);
    expect(result.semesterId, 6);
    expect(result.policyVersion, 'RULES-1');
    expect(result.calculatedAt, isNotNull);
    expect(result.courses.length, 2);
    expect(result.courses.first.eligible, isTrue);
    expect(result.courses.first.priorityRank, 1);
    expect(result.courses.first.reasonCodes.length, 2);
    expect(result.courses.first.explanations.single, 'Đã đáp ứng môn tiên quyết.');
    expect(result.courses.last.eligible, isFalse);
    expect(result.courses.last.priorityRank, isNull);
    expect(result.courses.last.availableClassCount, isNull);
  });

  test('Thiếu trường chưa chốt: giữ null, không phán đoán', () {
    final data = parseRecommendationContract({'items': [
      {'code': 'CS101', 'name': 'Môn A'},
    ]});
    final course = data.courses.single;
    expect(course.eligible, isNull);
    expect(course.priorityRank, isNull);
    expect(course.score, isNull);
    expect(course.credits, isNull);
    expect(course.reasonCodes, isEmpty);
    expect(course.availableClassCount, isNull);
  });

  test('Danh sách trống không bị biến thành lỗi hay dữ liệu mẫu', () {
    final data = parseRecommendationContract({'items': []});
    expect(data.courses, isEmpty);
    expect(data.isOfficialRecommendation, isTrue);
  });

  test('Missing items là contract error; không trả danh sách giả', () {
    expect(() => parseRecommendationContract({}), throwsFormatException);
  });

  test('Record thiếu code/name bị bỏ qua và báo số lượng', () {
    final data = parseRecommendationContract({'items': [
      {'code': 'X'},
      {'code': 'CS101', 'name': 'Môn hợp lệ'},
    ]});
    expect(data.courses, hasLength(1));
    expect(data.partialMessage, contains('1 học phần'));
  });

  test('Giữ nguyên mã lý do backend chưa biết', () {
    final data = parseRecommendationContract({'items': [
      {'code': 'CS101', 'name': 'Môn A', 'reasonCodes': ['NEW_REASON_2027']},
    ]});
    expect(data.courses.single.reasonCodes, ['NEW_REASON_2027']);
  });

  test('Lỗi API không bị diễn giải thành response trống', () async {
    final repository = ContractRecommendationRepository(
      load: () async => throw StateError('SERVICE_UNAVAILABLE'),
    );
    await expectLater(repository.getOverview(), throwsStateError);
  });
}
