import 'package:serverpod/serverpod.dart';

import '../../generated/protocol.dart';
import '../../security/account_guard.dart';

/// F24 - Gợi ý môn học dựa hoàn toàn trên quy tắc nghiệp vụ.
///
/// [curriculumCourseIds] PHẢI lấy ở backend từ phiên bản CTĐT của [studentId]
/// (chẳng hạn service F04), tuyệt đối không lấy từ tham số của Flutter.
///
/// Kết quả chỉ là danh sách môn đủ điều kiện SƠ BỘ tại đợt học được xét.
/// Chưa thay thế kiểm tra trùng lịch, giới hạn tín chỉ, thời gian đăng ký
/// và giao dịch đăng ký thực tế.
class CourseRecommendationService {
  const CourseRecommendationService._();

  static Future<RecommendationResult> recommend(
    Session session, {
    required int termId,
    required int teachingPhase,
    required Set<int> curriculumCourseIds,
  }) async {
    final studentId = await AccountGuard.requireStudentId(session);
    if (studentId <= 0 || termId <= 0) {
      throw ArgumentError('studentId và termId phải lớn hơn 0.');
    }
    if (teachingPhase != 1 && teachingPhase != 2) {
      throw ArgumentError('teachingPhase phải là 1 hoặc 2.');
    }
    if (curriculumCourseIds.isEmpty) {
      throw StateError('Chương trình đào tạo chưa có danh sách môn học.');
    }

    // Không dựa vào termId để suy ra học kỳ trước/sau.
    final terms = await AcademicTerm.db.find(session);
    final termOrderById = buildAcademicTermOrder(terms);
    if (!termOrderById.containsKey(termId)) {
      throw StateError('Không tìm thấy học kỳ $termId.');
    }

    final courses = await Course.db.find(
      session,
      where: (t) => t.id.inSet(curriculumCourseIds),
    );
    if (courses.length != curriculumCourseIds.length) {
      throw StateError('CTĐT tham chiếu tới môn không tồn tại.');
    }

    // Chỉ OPEN trong ĐÚNG học kỳ và ĐÚNG đợt đang đăng ký.
    final openSections = await CourseSection.db.find(
      session,
      where: (t) =>
          t.termId.equals(termId) &
          t.teachingPhase.equals(teachingPhase) &
          t.status.equals('OPEN') &
          t.courseId.inSet(curriculumCourseIds),
    );

    final attempts = await Enrollment.db.find(
      session,
      where: (t) => t.studentId.equals(studentId),
    );
    final sectionIds = attempts.map((e) => e.sectionId).toSet();
    final historySections = sectionIds.isEmpty
        ? <CourseSection>[]
        : await CourseSection.db.find(
            session,
            where: (t) => t.id.inSet(sectionIds),
          );
    final sectionsById = <int, CourseSection>{
      for (final s in historySections)
        if (s.id != null) s.id!: s,
    };

    final history = <AttemptSnapshot>[];
    for (final enrollment in attempts) {
      final section = sectionsById[enrollment.sectionId];
      if (section == null) {
        throw StateError(
          'Enrollment tham chiếu Section không tồn tại: '
          '${enrollment.sectionId}',
        );
      }
      history.add(
        AttemptSnapshot(
          courseId: section.courseId,
          termId: section.termId,
          status: enrollment.status,
          gradeStatus: enrollment.gradeStatus,
          resultStatus: enrollment.resultStatus,
          hasPublishedAt: enrollment.publishedAt != null,
        ),
      );
    }

    // Kiểm tra số chỗ theo MỖI lớp học phần (không phải tổng các lớp).
    final openSectionIds = openSections
        .where((s) => s.id != null)
        .map((s) => s.id!)
        .toSet();
    final seatCounts = <int, int>{};
    if (openSectionIds.isNotEmpty) {
      final allOpenEnrollments = await Enrollment.db.find(
        session,
        where: (t) => t.sectionId.inSet(openSectionIds),
      );
      for (final e in allOpenEnrollments) {
        if (e.status == 'ENROLLED' || e.status == 'COMPLETED') {
          seatCounts.update(
            e.sectionId,
            (count) => count + 1,
            ifAbsent: () => 1,
          );
        }
      }
    }

    final edges = await Prerequisite.db.find(
      session,
      where: (t) => t.courseId.inSet(curriculumCourseIds),
    );

    return rankFromSnapshot(
      RecommendationSnapshot(
        studentId: studentId,
        termId: termId,
        teachingPhase: teachingPhase,
        curriculumCourseIds: curriculumCourseIds,
        termOrderById: termOrderById,
        courses: [
          for (final c in courses)
            CourseSnapshot(
              id: c.id!,
              code: c.code,
              name: c.name,
              credits: c.credits,
              isActive: c.isActive,
            ),
        ],
        sections: [
          for (final s in openSections)
            SectionSnapshot(
              id: s.id!,
              courseId: s.courseId,
              termId: s.termId,
              teachingPhase: s.teachingPhase,
              status: s.status,
              capacity: s.capacity,
              enrolledCount: seatCounts[s.id] ?? 0,
            ),
        ],
        attempts: history,
        prerequisites: [
          for (final edge in edges)
            PrerequisiteEdge(
              courseId: edge.courseId,
              prerequisiteCourseId: edge.prerequisiteCourseId,
            ),
        ],
      ),
    );
  }

  /// Nhận dạng CÓ KIỂM SOÁT các định dạng HK1/HK2, Học kỳ 1/2,
  /// semester 1/2, Học kỳ hè. Nếu dữ liệu khác quy ước, báo lỗi thay
  /// vì đoán thứ tự học kỳ. Dữ liệu học kỳ phải là tuần tự theo năm học.
  static Map<int, int> buildAcademicTermOrder(List<AcademicTerm> terms) {
    final order = <int, int>{};
    final occupied = <int>{};
    for (final t in terms) {
      final id = t.id;
      if (id == null) throw StateError('AcademicTerm chưa có id.');
      final year = RegExp(r'(?:19|20)\d{2}').firstMatch(t.academicYear);
      if (year == null) {
        throw StateError('Không đọc được năm học: ${t.academicYear}');
      }
      final yearStart = int.parse(year.group(0)!);
      final name = t.termName.trim().toLowerCase();
      final match = RegExp(
        r'^(?:hk|học\s*kỳ|hoc\s*ky|semester|term|kỳ)\s*([1-3])$',
      ).firstMatch(name);
      final isSummer = RegExp(
        r'^(?:(?:học\s*kỳ|hoc\s*ky)\s*)?'
        r'(?:hè|he|summer)$',
      ).hasMatch(name);
      if (match == null && !isSummer) {
        throw StateError(
          'Tên học kỳ "${t.termName}" chưa được hỗ trợ; '
          'hãy bổ sung quy tắc hoặc cột thứ tự học kỳ.',
        );
      }
      final number = isSummer ? 3 : int.parse(match!.group(1)!);
      final index = yearStart * 4 + number;
      if (!occupied.add(index)) {
        throw StateError('Hai học kỳ có cùng thứ tự: $index');
      }
      order[id] = index;
    }
    return order;
  }

  /// Core thuần Dart: có thể unit test không cần PostgreSQL/Gemini.
  static RecommendationResult rankFromSnapshot(
    RecommendationSnapshot input,
  ) {
    if (input.teachingPhase != 1 && input.teachingPhase != 2) {
      throw ArgumentError('teachingPhase phải là 1 hoặc 2.');
    }
    final currentOrder = input.termOrderById[input.termId];
    if (currentOrder == null) {
      throw StateError('Thiếu thứ tự của học kỳ đang xét.');
    }

    final courseById = {
      for (final c in input.courses) c.id: c,
    };
    if (!courseById.keys.toSet().containsAll(input.curriculumCourseIds)) {
      throw StateError('Thiếu thông tin môn thuộc CTĐT.');
    }

    final passedBefore = <int>{};
    final passedUntilNow = <int>{};
    final failedBefore = <int>{};
    final takenThisTerm = <int>{};
    final unresolvedAttempts = <int>{};

    for (final attempt in input.attempts) {
      final order = input.termOrderById[attempt.termId];
      if (order == null) {
        throw StateError(
          'Thiếu thứ tự học kỳ cho lịch sử học tập: ${attempt.termId}',
        );
      }
      if (order > currentOrder) continue;
      final wasCancelled =
          attempt.status == 'CANCELLED' ||
          attempt.status == 'SECTION_CANCELLED';
      if (wasCancelled) continue;

      if (order == currentOrder) takenThisTerm.add(attempt.courseId);

      final published =
          attempt.status == 'COMPLETED' &&
          attempt.gradeStatus == 'PUBLISHED' &&
          attempt.hasPublishedAt;
      if (published && attempt.resultStatus == 'PASSED') {
        passedUntilNow.add(attempt.courseId);
        if (order < currentOrder) passedBefore.add(attempt.courseId);
      } else if (published && attempt.resultStatus == 'FAILED') {
        if (order < currentOrder) failedBefore.add(attempt.courseId);
      } else {
        // Kết quả chưa chính thức, hoặc đang học; chưa thể gợi ý học lại.
        unresolvedAttempts.add(attempt.courseId);
      }
    }

    // Không đếm trùng các con cháu xuất hiện trên nhiều đường đi.
    final graph = PrerequisiteDependencyGraph(
      courseIds: input.curriculumCourseIds,
      edges: input.prerequisites,
    );
    final scores = graph.countUnfinishedDependents(passedUntilNow);

    final sectionsByCourse = <int, List<SectionSnapshot>>{};
    for (final s in input.sections) {
      if (!input.curriculumCourseIds.contains(s.courseId) ||
          s.termId != input.termId ||
          s.teachingPhase != input.teachingPhase ||
          s.status != 'OPEN') {
        continue;
      }
      sectionsByCourse.putIfAbsent(s.courseId, () => []).add(s);
    }

    final prerequisitesByCourse = <int, Set<int>>{};
    for (final edge in input.prerequisites) {
      if (!input.curriculumCourseIds.contains(edge.courseId)) continue;
      prerequisitesByCourse
          .putIfAbsent(edge.courseId, () => <int>{})
          .add(edge.prerequisiteCourseId);
    }

    final ranked = <RecommendedCourse>[];
    final excluded = <ExcludedCourse>[];

    for (final courseId in input.curriculumCourseIds) {
      final course = courseById[courseId]!;
      final reasons = <String>[];
      if (!course.isActive) reasons.add('INACTIVE_COURSE');
      if (passedUntilNow.contains(courseId)) reasons.add('ALREADY_PASSED');
      if (takenThisTerm.contains(courseId)) {
        reasons.add('ALREADY_TAKEN_THIS_TERM');
      }
      if (unresolvedAttempts.contains(courseId) &&
          !passedUntilNow.contains(courseId)) {
        reasons.add('UNRESOLVED_ENROLLMENT');
      }

      final allSections =
          sectionsByCourse[courseId] ?? const <SectionSnapshot>[];
      if (allSections.isEmpty) reasons.add('NOT_OFFERED_THIS_PHASE');
      final freeSections = allSections
          .where((s) => s.capacity > s.enrolledCount)
          .toList();
      if (allSections.isNotEmpty && freeSections.isEmpty) {
        reasons.add('NO_AVAILABLE_SEATS');
      }

      final missingPrerequisites =
          (prerequisitesByCourse[courseId] ?? <int>{})
              .difference(passedBefore)
              .toList()
            ..sort();
      if (missingPrerequisites.isNotEmpty) {
        reasons.add('PREREQUISITE_NOT_PASSED_PREVIOUS_TERM');
      }

      if (reasons.isNotEmpty) {
        excluded.add(
          ExcludedCourse(
            courseId: courseId,
            courseCode: course.code,
            reasons: reasons,
            missingPrerequisiteCourseIds: missingPrerequisites,
          ),
        );
        continue;
      }

      final counts = scores[courseId]!;
      ranked.add(
        RecommendedCourse(
          courseId: courseId,
          courseCode: course.code,
          courseName: course.name,
          credits: course.credits,
          isRetake: failedBefore.contains(courseId),
          directDependents: counts.direct,
          indirectDependents: counts.indirect,
          dependentCount: counts.total,
          sectionIds: freeSections.map((s) => s.id).toList()..sort(),
        ),
      );
    }

    ranked.sort((a, b) {
      final byDependents = b.dependentCount.compareTo(a.dependentCount);
      if (byDependents != 0) return byDependents;
      if (a.isRetake != b.isRetake) return a.isRetake ? -1 : 1;
      return 0; // ĐÚNG yêu cầu: không có tie-breaker khác.
    });

    // Gắn nhóm đồng hạng thay vì gán vị trí ưu tiên riêng.
    var group = 0;
    RecommendedCourse? previous;
    for (final item in ranked) {
      if (previous == null ||
          previous.dependentCount != item.dependentCount ||
          previous.isRetake != item.isRetake) {
        group++;
      }
      item.priorityGroup = group;
      previous = item;
    }

    return RecommendationResult(
      studentId: input.studentId,
      termId: input.termId,
      teachingPhase: input.teachingPhase,
      recommendations: ranked,
      excluded: excluded,
    );
  }
}

class CourseSnapshot {
  final int id;
  final String code;
  final String name;
  final int credits;
  final bool isActive;
  const CourseSnapshot({
    required this.id,
    required this.code,
    required this.name,
    required this.credits,
    required this.isActive,
  });
}

class SectionSnapshot {
  final int id;
  final int courseId;
  final int termId;
  final int teachingPhase;
  final String status;
  final int capacity;
  final int enrolledCount;
  const SectionSnapshot({
    required this.id,
    required this.courseId,
    required this.termId,
    required this.teachingPhase,
    required this.status,
    required this.capacity,
    required this.enrolledCount,
  });
}

class AttemptSnapshot {
  final int courseId;
  final int termId;
  final String status;
  final String gradeStatus;
  final String resultStatus;
  final bool hasPublishedAt;
  const AttemptSnapshot({
    required this.courseId,
    required this.termId,
    required this.status,
    required this.gradeStatus,
    required this.resultStatus,
    required this.hasPublishedAt,
  });
}

class PrerequisiteEdge {
  final int courseId;
  final int prerequisiteCourseId;
  const PrerequisiteEdge({
    required this.courseId,
    required this.prerequisiteCourseId,
  });
}

class RecommendationSnapshot {
  final int studentId;
  final int termId;
  final int teachingPhase;
  final Set<int> curriculumCourseIds;
  final Map<int, int> termOrderById;
  final List<CourseSnapshot> courses;
  final List<SectionSnapshot> sections;
  final List<AttemptSnapshot> attempts;
  final List<PrerequisiteEdge> prerequisites;
  const RecommendationSnapshot({
    required this.studentId,
    required this.termId,
    required this.teachingPhase,
    required this.curriculumCourseIds,
    required this.termOrderById,
    required this.courses,
    required this.sections,
    required this.attempts,
    required this.prerequisites,
  });
}

class DependentCounts {
  final int direct;
  final int indirect;
  int get total => direct + indirect;
  const DependentCounts({required this.direct, required this.indirect});
}

class PrerequisiteDependencyGraph {
  final Set<int> courseIds;
  final List<PrerequisiteEdge> edges;
  const PrerequisiteDependencyGraph({
    required this.courseIds,
    required this.edges,
  });

  Map<int, DependentCounts> countUnfinishedDependents(Set<int> passed) {
    final children = <int, Set<int>>{
      for (final id in courseIds) id: <int>{},
    };
    for (final e in edges) {
      // Prerequisite outside CTĐT vẫn được kiểm tra ở eligibility,
      // nhưng không được đếm thành môn phụ thuộc của CTĐT.
      if (courseIds.contains(e.courseId) &&
          courseIds.contains(e.prerequisiteCourseId)) {
        children[e.prerequisiteCourseId]!.add(e.courseId);
      }
    }
    final visited = <int, Set<int>>{};
    final visiting = <int>{};

    Set<int> descendants(int root) {
      if (visited.containsKey(root)) return visited[root]!;
      if (!visiting.add(root)) {
        throw StateError('Chu trình môn tiên quyết liên quan môn $root.');
      }
      final found = <int>{};
      for (final child in children[root]!) {
        found.add(child);
        found.addAll(descendants(child));
      }
      visiting.remove(root);
      visited[root] = found;
      return found;
    }

    return <int, DependentCounts>{
      for (final courseId in courseIds)
        courseId: DependentCounts(
          direct: children[courseId]!
              .where((id) => !passed.contains(id))
              .length,
          indirect: descendants(courseId)
              .where(
                (id) =>
                    !passed.contains(id) && !children[courseId]!.contains(id),
              )
              .length,
        ),
    };
  }
}

class RecommendedCourse {
  final int courseId;
  final String courseCode;
  final String courseName;
  final int credits;
  final bool isRetake;
  final int directDependents;
  final int indirectDependents;
  final int dependentCount;
  final List<int> sectionIds;
  int priorityGroup = 0;

  RecommendedCourse({
    required this.courseId,
    required this.courseCode,
    required this.courseName,
    required this.credits,
    required this.isRetake,
    required this.directDependents,
    required this.indirectDependents,
    required this.dependentCount,
    required this.sectionIds,
  });

  Map<String, dynamic> toJson() => {
    'courseId': courseId,
    'courseCode': courseCode,
    'courseName': courseName,
    'credits': credits,
    'isRetake': isRetake,
    'directDependents': directDependents,
    'indirectDependents': indirectDependents,
    'dependentCount': dependentCount,
    'priorityGroup': priorityGroup,
    'sectionIds': sectionIds,
  };
}

class ExcludedCourse {
  final int courseId;
  final String courseCode;
  final List<String> reasons;
  final List<int> missingPrerequisiteCourseIds;
  const ExcludedCourse({
    required this.courseId,
    required this.courseCode,
    required this.reasons,
    required this.missingPrerequisiteCourseIds,
  });
  Map<String, dynamic> toJson() => {
    'courseId': courseId,
    'courseCode': courseCode,
    'reasons': reasons,
    'missingPrerequisiteCourseIds': missingPrerequisiteCourseIds,
  };
}

class RecommendationResult {
  final int studentId;
  final int termId;
  final int teachingPhase;
  final List<RecommendedCourse> recommendations;
  final List<ExcludedCourse> excluded;
  const RecommendationResult({
    required this.studentId,
    required this.termId,
    required this.teachingPhase,
    required this.recommendations,
    required this.excluded,
  });
  Map<String, dynamic> toJson() => {
    'studentId': studentId,
    'termId': termId,
    'teachingPhase': teachingPhase,
    'recommendations': recommendations.map((c) => c.toJson()).toList(),
    'excluded': excluded.map((c) => c.toJson()).toList(),
  };
}
