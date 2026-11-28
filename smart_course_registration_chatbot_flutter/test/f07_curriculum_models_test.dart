import 'package:flutter_test/flutter_test.dart';
import 'package:smart_course_registration_chatbot_flutter/features/admin/curriculum_management/domain/managed_curriculum.dart';

void main() {
  test('Phiên bản published không thể chỉnh sửa cấu trúc', () {
    const summary = ManagedCurriculumVersionSummary(
      id: 1, curriculumId: 10, versionCode: 'V2024',
      effectiveYear: 2024, status: F07VersionStatus.published,
      totalCreditsRequired: 150,
    );
    const version = ManagedCurriculumVersionDetail(
      summary: summary, curriculumName: 'CNTT', curriculumCode: 'CNTT',
      revision: 2, blocks: [],
    );
    expect(version.isEditable, isFalse);
    expect(summary.status.label, 'Hiệu lực');
  });

  test('Bản nháp cho phép thay đổi khối nhưng không sửa bản gốc', () {
    const summary = ManagedCurriculumVersionSummary(
      id: 2, curriculumId: 10, versionCode: 'V2027',
      effectiveYear: 2027, status: F07VersionStatus.draft,
      totalCreditsRequired: 150,
    );
    const block = ManagedKnowledgeBlock(
      id: 1, code: 'DC', name: 'Đại cương', displayOrder: 1,
      requiredCredits: 42, items: [],
    );
    const before = ManagedCurriculumVersionDetail(
      summary: summary, curriculumName: 'CNTT', curriculumCode: 'CNTT',
      revision: 1, blocks: [block],
    );
    final after = before.copyWith(blocks: [block.copyWith(name: 'Cơ sở ngành')]);
    expect(before.isEditable, isTrue);
    expect(before.blocks.single.name, 'Đại cương');
    expect(after.blocks.single.name, 'Cơ sở ngành');
  });
}
