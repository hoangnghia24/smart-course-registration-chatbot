import 'package:test/test.dart';

import '../lib/src/services/recommendation/course_recommendation_service.dart';

void main() {
  // IDs are test-only, not real user IDs or CTDT primary keys.
  const program = CourseSnapshot(
    id: 1, code: 'INPR130285', name: 'Nhập môn lập trình',
    credits: 3, isActive: true,
  );
  const dataStructure = CourseSnapshot(
    id: 2, code: 'DASA230179', name: 'Cấu trúc dữ liệu và giải thuật',
    credits: 3, isActive: true,
  );
  const oop = CourseSnapshot(
    id: 3, code: 'OOPR230279', name: 'Lập trình hướng đối tượng',
    credits: 3, isActive: true,
  );
  const software = CourseSnapshot(
    id: 4, code: 'WEPR330479', name: 'Lập trình Web',
    credits: 3, isActive: true,
  );
  const elective = CourseSnapshot(
    id: 5, code: 'CLCO332779', name: 'Điện toán đám mây',
    credits: 3, isActive: true,
  );
  const courses = [program, dataStructure, oop, software, elective];
  const prereqs = [
    PrerequisiteEdge(courseId: 2, prerequisiteCourseId: 1),
    PrerequisiteEdge(courseId: 3, prerequisiteCourseId: 1),
    PrerequisiteEdge(courseId: 4, prerequisiteCourseId: 3),
  ];

  RecommendationSnapshot makeSnapshot({
    List<AttemptSnapshot> attempts = const [],
    int phase = 1,
    List<SectionSnapshot>? sections,
  }) {
    return RecommendationSnapshot(
      studentId: 101,
      termId: 202,
      teachingPhase: phase,
      curriculumCourseIds: const {1, 2, 3, 4, 5},
      requiredCourseIds: const {1, 2, 3, 4},
      termOrderById: const {201: 1, 202: 2},
      courses: courses,
      sections: sections ?? [
        for (final id in [1, 2, 3, 4, 5])
          SectionSnapshot(
            id: id * 10 + phase, courseId: id, termId: 202,
            teachingPhase: phase, status: 'OPEN',
            capacity: 25, enrolledCount: 0,
          ),
      ],
      attempts: attempts,
      prerequisites: prereqs,
    );
  }

  const passedIntro = AttemptSnapshot(
    courseId: 1, termId: 201, status: 'COMPLETED',
    gradeStatus: 'PUBLISHED', resultStatus: 'PASSED',
    hasPublishedAt: true,
  );

  test('Chỉ gợi ý môn có tiên quyết đã đạt từ học kỳ trước', () {
    final result = CourseRecommendationService.rankFromSnapshot(
      makeSnapshot(attempts: [passedIntro]),
    );
    final recommendedCodes = result.recommendations
        .map((c) => c.courseCode).toSet();
    expect(recommendedCodes, contains('DASA230179'));
    expect(recommendedCodes, contains('OOPR230279'));
    expect(recommendedCodes, isNot(contains('WEPR330479')));
    final web = result.excluded.singleWhere((e) => e.courseCode == 'WEPR330479');
    expect(web.reasons, contains('PREREQUISITE_NOT_PASSED_PREVIOUS_TERM'));
  });

  test('Chưa công bố điểm không được dùng để mở tiên quyết', () {
    const pendingIntro = AttemptSnapshot(
      courseId: 1, termId: 201, status: 'COMPLETED',
      gradeStatus: 'FINALIZED', resultStatus: 'PASSED',
      hasPublishedAt: false,
    );
    final result = CourseRecommendationService.rankFromSnapshot(
      makeSnapshot(attempts: [pendingIntro]),
    );
    expect(result.excluded.singleWhere((e) => e.courseId == 2).reasons,
        contains('PREREQUISITE_NOT_PASSED_PREVIOUS_TERM'));
    expect(result.excluded.singleWhere((e) => e.courseId == 1).reasons,
        contains('UNRESOLVED_ENROLLMENT'));
  });

  test('Môn học lại có ưu tiên hơn môn mới khi cùng số môn phụ thuộc', () {
    const failedDataStructure = AttemptSnapshot(
      courseId: 2, termId: 201, status: 'COMPLETED',
      gradeStatus: 'PUBLISHED', resultStatus: 'FAILED',
      hasPublishedAt: true,
    );
    // Both data structure and OOP have zero unfinished required descendants
    // except OOP points to Web; so for a real tie, limit Web as already passed.
    const passedWeb = AttemptSnapshot(
      courseId: 4, termId: 201, status: 'COMPLETED',
      gradeStatus: 'PUBLISHED', resultStatus: 'PASSED',
      hasPublishedAt: true,
    );
    final result = CourseRecommendationService.rankFromSnapshot(
      makeSnapshot(attempts: [passedIntro, failedDataStructure, passedWeb]),
    );
    final retake = result.recommendations.firstWhere((c) => c.courseId == 2);
    final fresh = result.recommendations.firstWhere((c) => c.courseId == 3);
    expect(retake.dependentCount, fresh.dependentCount);
    expect(retake.priorityGroup, lessThan(fresh.priorityGroup));
  });

  test('Không gợi ý học lại trong học kỳ vừa học dù sang đợt 2', () {
    const failedSameTerm = AttemptSnapshot(
      courseId: 2, termId: 202, status: 'COMPLETED',
      gradeStatus: 'PUBLISHED', resultStatus: 'FAILED',
      hasPublishedAt: true,
    );
    final result = CourseRecommendationService.rankFromSnapshot(
      makeSnapshot(phase: 2, attempts: [passedIntro, failedSameTerm]),
    );
    expect(result.excluded.singleWhere((e) => e.courseId == 2).reasons,
        contains('ALREADY_TAKEN_THIS_TERM'));
  });

  test('Ứng viên tự chọn không được tự động khẳng định hợp lệ', () {
    final result = CourseRecommendationService.rankFromSnapshot(
      makeSnapshot(attempts: [passedIntro]),
    );
    expect(result.excluded.singleWhere((e) => e.courseId == 5).reasons,
        contains('ELECTIVE_RULES_NOT_CONFIGURED'));
    expect(result.recommendations.map((e) => e.courseId), isNot(contains(5)));
  });

  test('Lớp hết chỗ không được gợi ý', () {
    final sections = [
      for (final id in [1, 2, 3, 4, 5])
        SectionSnapshot(
          id: id * 10, courseId: id, termId: 202,
          teachingPhase: 1, status: 'OPEN',
          capacity: 20, enrolledCount: id == 2 ? 20 : 0,
        ),
    ];
    final result = CourseRecommendationService.rankFromSnapshot(
      makeSnapshot(attempts: [passedIntro], sections: sections),
    );
    expect(result.excluded.singleWhere((e) => e.courseId == 2).reasons,
        contains('NO_AVAILABLE_SEATS'));
  });

  test('Không gợi ý môn khi không có CourseSection OPEN', () {
    final result = CourseRecommendationService.rankFromSnapshot(
      makeSnapshot(attempts: [passedIntro], sections: <SectionSnapshot>[]),
    );
    expect(result.recommendations, isEmpty);
    expect(result.excluded.singleWhere((e) => e.courseId == 3).reasons,
        contains('NOT_OFFERED_THIS_PHASE'));
  });
}
