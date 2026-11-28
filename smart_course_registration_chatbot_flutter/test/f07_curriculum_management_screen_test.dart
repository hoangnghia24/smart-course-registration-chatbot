import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_course_registration_chatbot_flutter/features/admin/curriculum_management/data/curriculum_management_repository.dart';
import 'package:smart_course_registration_chatbot_flutter/features/admin/curriculum_management/domain/managed_curriculum.dart';
import 'package:smart_course_registration_chatbot_flutter/features/admin/curriculum_management/presentation/curriculum_management_screen.dart';

class _FakeRepo implements CurriculumManagementRepository {
  @override
  Future<List<ManagedCurriculum>> listCurriculums({String query = ''}) async => [
    const ManagedCurriculum(id: 3, code: 'CNTT',
      name: 'Công nghệ thông tin', majorCode: '7480201', versions: [
        ManagedCurriculumVersionSummary(id: 12, curriculumId: 3,
          versionCode: 'V2027', effectiveYear: 2027,
          status: F07VersionStatus.draft, totalCreditsRequired: 150),
      ]),
  ];

  @override
  Future<ManagedCurriculumVersionDetail> getVersionById(int versionId) async {
    return const ManagedCurriculumVersionDetail(
      summary: ManagedCurriculumVersionSummary(id: 12, curriculumId: 3,
        versionCode: 'V2027', effectiveYear: 2027,
        status: F07VersionStatus.draft, totalCreditsRequired: 150),
      curriculumName: 'Công nghệ thông tin', curriculumCode: 'CNTT',
      revision: 1, blocks: [],
    );
  }

  @override
  Future<ManagedCurriculumVersionDetail> saveDraftVersion(
    ManagedCurriculumVersionDetail version, {
    required int expectedRevision,
  }) async => version.copyWith(revision: expectedRevision + 1);
}

void main() {
  testWidgets('F07 list dùng SharedAppHeader và mở chi tiết phiên bản', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(MaterialApp(home:
      CurriculumManagementScreen(repository: _FakeRepo())));
    await tester.pumpAndSettle();
    expect(find.text('Quản trị hệ thống · Admin'), findsOneWidget);
    expect(find.text('Công nghệ thông tin'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('f07-version-12')));
    await tester.pumpAndSettle();
    expect(find.text('Quản lý phiên bản CTĐT'), findsOneWidget);
    expect(find.byKey(const ValueKey('f07-save-draft')), findsOneWidget);
  });
}
