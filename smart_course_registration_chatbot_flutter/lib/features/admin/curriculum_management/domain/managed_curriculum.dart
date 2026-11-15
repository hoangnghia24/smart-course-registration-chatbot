/// F07 domain contract proposed for Flutter. Not a generated Serverpod DTO.
enum F07VersionStatus { draft, published, archived }

extension F07VersionStatusText on F07VersionStatus {
  String get label => switch (this) {
    F07VersionStatus.draft => 'Bản nháp',
    F07VersionStatus.published => 'Hiệu lực',
    F07VersionStatus.archived => 'Lưu trữ',
  };
}

class ManagedCurriculum {
  const ManagedCurriculum({
    required this.id,
    required this.code,
    required this.name,
    required this.majorCode,
    required this.versions,
  });

  final int id;
  final String code;
  final String name;
  final String majorCode;
  final List<ManagedCurriculumVersionSummary> versions;
}

class ManagedCurriculumVersionSummary {
  const ManagedCurriculumVersionSummary({
    required this.id,
    required this.curriculumId,
    required this.versionCode,
    required this.effectiveYear,
    required this.status,
    required this.totalCreditsRequired,
  });

  final int id;
  final int curriculumId;
  final String versionCode;
  final int effectiveYear;
  final F07VersionStatus status;
  final int totalCreditsRequired;
}

class ManagedCourseItem {
  const ManagedCourseItem({
    required this.courseId,
    required this.courseCode,
    required this.courseName,
    required this.credits,
    required this.semester,
    required this.isRequired,
    this.electiveGroupId,
  });

  final int courseId;
  final String courseCode;
  final String courseName;
  final int credits;
  final int semester;
  final bool isRequired;
  final int? electiveGroupId;
}

class ManagedElectiveGroup {
  const ManagedElectiveGroup({
    required this.id,
    required this.name,
    required this.minCredits,
  });

  final int id;
  final String name;
  final int minCredits;
}

class ManagedKnowledgeBlock {
  const ManagedKnowledgeBlock({
    required this.id,
    required this.code,
    required this.name,
    required this.displayOrder,
    required this.requiredCredits,
    required this.items,
    this.electiveGroups = const [],
  });

  final int id;
  final String code;
  final String name;
  final int displayOrder;
  final int requiredCredits;
  final List<ManagedCourseItem> items;
  final List<ManagedElectiveGroup> electiveGroups;

  ManagedKnowledgeBlock copyWith({String? name, int? requiredCredits}) {
    return ManagedKnowledgeBlock(
      id: id,
      code: code,
      name: name ?? this.name,
      displayOrder: displayOrder,
      requiredCredits: requiredCredits ?? this.requiredCredits,
      items: items,
      electiveGroups: electiveGroups,
    );
  }
}

class ManagedCurriculumVersionDetail {
  const ManagedCurriculumVersionDetail({
    required this.summary,
    required this.curriculumName,
    required this.curriculumCode,
    required this.revision,
    required this.blocks,
  });

  final ManagedCurriculumVersionSummary summary;
  final String curriculumName;
  final String curriculumCode;
  final int revision;
  final List<ManagedKnowledgeBlock> blocks;

  bool get isEditable => summary.status == F07VersionStatus.draft;

  ManagedCurriculumVersionDetail copyWith({
    int? revision,
    List<ManagedKnowledgeBlock>? blocks,
  }) {
    return ManagedCurriculumVersionDetail(
      summary: summary,
      curriculumName: curriculumName,
      curriculumCode: curriculumCode,
      revision: revision ?? this.revision,
      blocks: blocks ?? this.blocks,
    );
  }
}
