class CurriculumDetails {
  const CurriculumDetails({
    required this.code,
    required this.name,
    required this.majorCode,
    required this.versionCode,
    required this.effectiveYear,
    required this.versionStatus,
    required this.items,
  });

  final String code;
  final String name;
  final String majorCode;
  final String versionCode;
  final int effectiveYear;
  final String versionStatus;
  final List<CurriculumCourse> items;
}

class CurriculumCourse {
  const CurriculumCourse({
    required this.code,
    required this.name,
    required this.credits,
    required this.semester,
    required this.isRequired,
    this.description,
  });

  final String code;
  final String name;
  final int credits;
  final int semester;
  final bool isRequired;
  final String? description;
}

abstract class CurriculumLookupRepository {
  /// Kết quả null khi chưa gán CTĐT hoặc quan hệ Student–CTĐT chưa đầy đủ.
  Future<CurriculumDetails?> getMyCurriculum();
}
