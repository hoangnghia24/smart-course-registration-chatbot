import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_course_registration_chatbot_flutter/features/admin/curriculum_management/data/curriculum_management_repository.dart';
import 'package:smart_course_registration_chatbot_flutter/features/admin/curriculum_management/domain/managed_curriculum.dart';
import 'package:smart_course_registration_chatbot_flutter/features/admin/curriculum_management/presentation/curriculum_version_screen.dart';

class _InlineCoursesRepo implements CurriculumManagementRepository {
  _InlineCoursesRepo(this.status);

  final F07VersionStatus status;

  @override
  Future<List<ManagedCurriculum>> listCurriculums({String query = ''}) async => [];

  @override
  Future<ManagedCurriculumVersionDetail> getVersionById(int versionId) async =>
      ManagedCurriculumVersionDetail(
        summary: ManagedCurriculumVersionSummary(
          id: versionId,
          curriculumId: 3,
          versionCode: 'V2027',
          effectiveYear: 2027,
          status: status,
          totalCreditsRequired: 150,
        ),
        curriculumName: 'Công nghệ thông tin',
        curriculumCode: 'CNTT',
        revision: 1,
        blocks: const [
          ManagedKnowledgeBlock(
            id: 1,
            code: 'DC',
            name: 'Kiến thức giáo dục đại cương',
            displayOrder: 1,
            requiredCredits: 42,
            items: [
              ManagedCourseItem(
                courseId: 11,
                courseCode: 'LLCT101',
                courseName: 'Triết học Mác – Lênin',
                credits: 3,
                semester: 1,
                isRequired: true,
              ),
              ManagedCourseItem(
                courseId: 12,
                courseCode: 'ENGL301',
                courseName: 'Anh văn 3',
                credits: 3,
                semester: 3,
                isRequired: true,
              ),
            ],
          ),
          ManagedKnowledgeBlock(
            id: 2,
            code: 'CS',
            name: 'Kiến thức cơ sở ngành',
            displayOrder: 2,
            requiredCredits: 38,
            items: [
              ManagedCourseItem(
                courseId: 13,
                courseCode: 'CS101',
                courseName: 'Nhập môn lập trình',
                credits: 3,
                semester: 1,
                isRequired: true,
              ),
            ],
          ),
          ManagedKnowledgeBlock(
            id: 3,
            code: 'CN',
            name: 'Kiến thức chuyên ngành',
            displayOrder: 3,
            requiredCredits: 70,
            items: [],
            electiveGroups: [
              ManagedElectiveGroup(
                id: 5,
                name: 'Tự chọn chuyên ngành',
                minCredits: 12,
              ),
            ],
          ),
        ],
      );

  @override
  Future<ManagedCurriculumVersionDetail> saveDraftVersion(
    ManagedCurriculumVersionDetail version, {
    required int expectedRevision,
  }) async => version.copyWith(revision: expectedRevision + 1);
}

Future<void> _pumpScreen(
  WidgetTester tester,
  F07VersionStatus status,
) async {
  await tester.binding.setSurfaceSize(const Size(390, 844));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(MaterialApp(
    home: CurriculumVersionScreen(
      repository: _InlineCoursesRepo(status),
      versionId: 102,
      preview: true,
    ),
  ));
  await tester.pumpAndSettle();
}

// ListView chỉ dựng các phần tử gần vùng đang hiển thị. Với khối thứ ba,
// nút có thể CHƯA được dựng; ensureVisible lúc đó không thể tìm được nút.
// Cuộn ListView cho đến khi nút xuất hiện, rồi bảo đảm nút nằm trong viewport.
Future<void> _tapVisibleBlockToggle(WidgetTester tester, int blockId) async {
  final toggle = find.byKey(ValueKey('f07-toggle-block-$blockId'));
  final scrollable = find.descendant(
    of: find.byKey(const ValueKey('f07-version-scroll')),
    matching: find.byType(Scrollable),
  );
  expect(scrollable, findsOneWidget);

  if (toggle.evaluate().isEmpty) {
    await tester.scrollUntilVisible(
      toggle,
      180.0,
      scrollable: scrollable,
      maxScrolls: 20,
    );
  }

  await tester.ensureVisible(toggle);
  await tester.pumpAndSettle();
  expect(toggle, findsOneWidget);
  await tester.tap(toggle);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('F07 mở sẵn học phần khối đầu theo Frame-24, không dùng bottom sheet',
      (tester) async {
    await _pumpScreen(tester, F07VersionStatus.published);
    expect(find.byKey(const ValueKey('f07-inline-courses-1')), findsOneWidget);
    expect(find.text('Triết học Mác – Lênin'), findsOneWidget);
    expect(find.text('Anh văn 3'), findsOneWidget);
    expect(find.byType(BottomSheet), findsNothing);
    expect(find.byKey(const ValueKey('f07-edit-block-1')), findsNothing);
    expect(find.byKey(const ValueKey('f07-save-draft')), findsNothing);
  });

  testWidgets('F07 thu gọn và mở rộng học phần trực tiếp trong khối',
      (tester) async {
    await _pumpScreen(tester, F07VersionStatus.draft);
    await _tapVisibleBlockToggle(tester, 1);
    expect(find.byKey(const ValueKey('f07-inline-courses-1')), findsNothing);
    expect(find.text('Triết học Mác – Lênin'), findsNothing);

    await _tapVisibleBlockToggle(tester, 2);
    expect(find.byKey(const ValueKey('f07-inline-courses-2')), findsOneWidget);
    expect(find.text('Nhập môn lập trình'), findsOneWidget);
    expect(find.byType(BottomSheet), findsNothing);
    expect(find.byKey(const ValueKey('f07-edit-block-2')), findsOneWidget);
    expect(find.byKey(const ValueKey('f07-save-draft')), findsOneWidget);
  });

  testWidgets('F07 hiển thị nhóm tự chọn trong nội dung khối mở rộng',
      (tester) async {
    await _pumpScreen(tester, F07VersionStatus.draft);
    await _tapVisibleBlockToggle(tester, 3);
    expect(find.textContaining('Tự chọn chuyên ngành'), findsOneWidget);
    expect(find.textContaining('Tối thiểu 12 TC'), findsOneWidget);
    expect(find.byType(BottomSheet), findsNothing);
  });
}
