import 'recommendation_repository.dart';

/// Adapter độc lập với generated DTO của Serverpod.
/// `load` PHẢI gọi API F24/F27 thật. Map là JSON sinh bởi DTO `.toJson()`.
/// Không gọi REST và không tự kết luận nghiệp vụ trên Flutter.
class ContractRecommendationRepository implements RecommendationRepository {
  const ContractRecommendationRepository({required this.load});

  final Future<Map<String, dynamic>?> Function() load;

  @override
  Future<RecommendationOverview?> getOverview() async {
    final response = await load();
    if (response == null) return null;
    return parseRecommendationContract(response);
  }
}

/// Chuyển đổi response theo hợp đồng BE-FE đã thống nhất.
/// Những trường tùy chọn thiếu/null được giữ là null. Không tự đoán eligibility.
RecommendationOverview parseRecommendationContract(Map<String, dynamic> response) {
  final rawItems = response['items'];
  if (rawItems is! List) {
    throw const FormatException('F24_CONTRACT_INVALID: items phải là List.');
  }
  final items = <RecommendationCourse>[];
  var invalidItems = 0;
  for (final raw in rawItems) {
    if (raw is! Map) {
      invalidItems++;
      continue;
    }
    final data = Map<String, dynamic>.from(raw);
    final code = _string(data['code']);
    final name = _string(data['name']);
    if (code == null || name == null) {
      // Không tự tạo mã môn/tên môn giả để thay dữ liệu BE.
      invalidItems++;
      continue;
    }
    final reasonCodes = _strings(data['reasonCodes']);
    final explanations = <String>[
      ..._strings(data['explanations']),
      ..._detailMessages(data['reasonDetails']),
    ];
    items.add(RecommendationCourse(
      code: code,
      name: name,
      courseId: _int(data['courseId']),
      credits: _int(data['credits']),
      semester: _int(data['semester']),
      isRequired: data['isRequired'] is bool ? data['isRequired'] as bool : null,
      groupName: _string(data['groupName']),
      progressStatus: _string(data['progressStatus']),
      eligible: data['eligible'] is bool ? data['eligible'] as bool : null,
      eligibilityStatus: _string(data['eligibilityStatus']),
      priorityRank: _int(data['priority']),
      score: data['score'] is num ? data['score'] as num : null,
      reasonCodes: List.unmodifiable(reasonCodes),
      explanations: List.unmodifiable(explanations),
      reasonCode: reasonCodes.isEmpty ? null : reasonCodes.first,
      availableClassCount: _int(data['availableClassCount']),
      lastAcademicScore: data['lastAcademicScore'] is num
          ? (data['lastAcademicScore'] as num).toDouble() : null,
    ));
  }

  return RecommendationOverview(
    courses: List.unmodifiable(items),
    hasCurriculum: true,
    hasProgress: false,
    isOfficialRecommendation: true,
    semesterId: _int(response['semesterId']),
    policyVersion: _string(response['policyVersion']),
    calculatedAt: _dateTime(response['calculatedAt']),
    earnedCredits: _int(response['earnedCredits']),
    totalCredits: _int(response['totalCredits']),
    failedCourseCount: _int(response['failedCourseCount']),
    curriculumName: _string(response['curriculumName']),
    partialMessage: invalidItems == 0 ? null :
        '$invalidItems học phần thiếu mã/tên trong phản hồi F24 đã được bỏ qua.',
  );
}

String? _string(Object? value) =>
    value is String && value.trim().isNotEmpty ? value.trim() : null;

int? _int(Object? value) => value is int ? value : null;

List<String> _strings(Object? value) => value is List
    ? value.map(_string).whereType<String>().toList(growable: false)
    : const [];

List<String> _detailMessages(Object? value) {
  if (value is! List) return const [];
  final messages = <String>[];
  for (final item in value) {
    if (item is Map) {
      final message = _string(item['message']);
      if (message != null) messages.add(message);
    }
  }
  return messages;
}

DateTime? _dateTime(Object? value) {
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value);
  return null;
}
