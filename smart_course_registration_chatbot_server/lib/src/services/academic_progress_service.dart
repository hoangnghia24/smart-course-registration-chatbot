import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';

class AcademicProgressService {
  static Future<AcademicProgressDto?> getProgress(
    Session session,
    Student student,
  ) async {
    final versionId = student.curriculumVersionId;

    // 1. Kiem tra phien ban CTDT
    final version = await CurriculumVersion.db.findById(
      session,
      versionId,
    );

    if (version == null) return null;

    // 2. Lay cac hoc phan trong CTDT
    final items = await CurriculumItem.db.find(
      session,
      where: (t) => t.curriculumVersionId.equals(versionId),
    );

    // 3. Lay thong tin nhom kien thuc (F04)
    final groups = await CurriculumGroup.db.find(
      session,
      where: (t) => t.curriculumVersionId.equals(versionId),
    );

    final groupsById = <int, CurriculumGroup>{
      for (final group in groups)
        if (group.id != null) group.id!: group,
    };

    // 4. Lay Course theo lo
    final courseIds = items.map((e) => e.courseId).toSet();

    final courses = courseIds.isEmpty
        ? <Course>[]
        : await Course.db.find(
            session,
            where: (t) => t.id.inSet(courseIds),
          );

    final coursesById = <int, Course>{
      for (final course in courses)
        if (course.id != null) course.id!: course,
    };

    // 5. Lay lich su hoc tap cua Student
    final enrollments = student.id == null
        ? <Enrollment>[]
        : await Enrollment.db.find(
            session,
            where: (t) => t.studentId.equals(student.id!),
          );

    // 6. Lay cac lop hoc phan lien quan
    final sectionIds = enrollments.map((e) => e.sectionId).toSet();

    final sections = sectionIds.isEmpty
        ? <CourseSection>[]
        : await CourseSection.db.find(
            session,
            where: (t) => t.id.inSet(sectionIds),
          );

    final sectionsById = <int, CourseSection>{
      for (final section in sections)
        if (section.id != null) section.id!: section,
    };

    // 7. Nhom cac lan hoc theo courseId
    final historyByCourse = <int, List<Enrollment>>{};

    for (final enrollment in enrollments) {
      // Khong tinh dang ky da huy
      if (enrollment.status == 'CANCELLED' ||
          enrollment.status == 'SECTION_CANCELLED') {
        continue;
      }

      final section = sectionsById[enrollment.sectionId];

      if (section == null || section.status == 'CANCELLED') {
        continue;
      }

      historyByCourse
          .putIfAbsent(section.courseId, () => <Enrollment>[])
          .add(enrollment);
    }

    // 8. Tong hop trang thai tung hoc phan
    final progressCourses = <AcademicCourseProgressDto>[];

    for (final item in items) {
      final course = coursesById[item.courseId];

      if (course == null) {
        throw StateError(
          'Missing Course for courseId=${item.courseId}',
        );
      }

      final group = item.groupId == null ? null : groupsById[item.groupId];

      if (item.groupId != null && group == null) {
        throw StateError(
          'Invalid CurriculumGroup for courseId=${item.courseId}',
        );
      }

      final history = historyByCourse[item.courseId] ?? <Enrollment>[];

      // Chi su dung ket qua da cong bo
      final official = history.where((enrollment) {
        return enrollment.gradeStatus == 'PUBLISHED' &&
            enrollment.publishedAt != null &&
            (enrollment.resultStatus == 'PASSED' ||
                enrollment.resultStatus == 'FAILED');
      }).toList();

      final hasPassed = official.any(
        (e) => e.resultStatus == 'PASSED',
      );

      final hasFailed = official.any(
        (e) => e.resultStatus == 'FAILED',
      );

      // Dang hoc hoac da xong nhung chua co ket qua chinh thuc
      final isInProgress = history.any((e) {
        if (e.status == 'ENROLLED') return true;

        return e.status == 'COMPLETED' &&
            !(e.gradeStatus == 'PUBLISHED' &&
                e.publishedAt != null &&
                (e.resultStatus == 'PASSED' || e.resultStatus == 'FAILED'));
      });

      String status;
      String? statusDetail;

      if (hasPassed) {
        status = 'PASSED';
      } else if (isInProgress) {
        status = 'IN_PROGRESS';

        final waitingForGrade = history.any(
          (e) => e.status == 'COMPLETED' && e.gradeStatus != 'PUBLISHED',
        );

        statusDetail = waitingForGrade ? 'PENDING_GRADE' : 'CURRENTLY_ENROLLED';
      } else if (hasFailed) {
        status = 'FAILED';
      } else {
        status = 'NOT_STARTED';
      }

      // Khong tu chon diem khi co nhieu luot hoc chinh thuc
      double? score;
      String scoreStatus;

      if (official.length > 1) {
        scoreStatus = 'POLICY_PENDING';
      } else if (official.length == 1 && official.first.score != null) {
        score = official.first.score;
        scoreStatus = 'AVAILABLE';
      } else if (official.length == 1) {
        scoreStatus = 'NO_DATA';
      } else if (history.isNotEmpty) {
        scoreStatus = 'NOT_PUBLISHED';
      } else {
        scoreStatus = 'NO_DATA';
      }

      progressCourses.add(
        AcademicCourseProgressDto(
          courseId: item.courseId,
          course: CourseItemDto(
            code: course.code,
            name: course.name,
            credits: course.credits,
            description: course.description,
          ),
          semester: item.semester,
          isRequired: item.isRequired,
          groupCode: group?.groupCode,
          groupName: group?.groupName,
          groupOrder: group?.groupOrder,
          itemOrder: item.itemOrder,
          status: status,
          statusDetail: statusDetail,
          score: score,
          scoreStatus: scoreStatus,
        ),
      );
    }

    // 9. Sap xep theo khoi kien thuc va thu tu mon
    progressCourses.sort((a, b) {
      final g = (a.groupOrder ?? 999999).compareTo(b.groupOrder ?? 999999);
      if (g != 0) return g;

      final code = (a.groupCode ?? '\uffff').compareTo(b.groupCode ?? '\uffff');
      if (code != 0) return code;

      final i = (a.itemOrder ?? 999999).compareTo(b.itemOrder ?? 999999);
      if (i != 0) return i;

      return a.course.code.compareTo(b.course.code);
    });

    // 10. Tinh tin chi khi CTDT du quy tac
    //
    // Chua co chi tieu nhom tu chon:
    // Khong tu suy ra tong tin chi neu co mon tu chon.
    final canCalculateCredits =
        items.isNotEmpty && items.every((e) => e.isRequired);

    double? totalCredits;
    double? earnedCredits;
    double? remainingCredits;

    if (canCalculateCredits) {
      // Chi tinh mot lan cho moi courseId
      final uniqueCredits = <int, double>{};

      for (final item in items) {
        final course = coursesById[item.courseId]!;
        uniqueCredits[item.courseId] = course.credits.toDouble();
      }

      totalCredits = uniqueCredits.values.fold<double>(
        0.0,
        (sum, value) => sum + value,
      );

      final passedIds = progressCourses
          .where((e) => e.status == 'PASSED')
          .map((e) => e.courseId)
          .toSet();

      earnedCredits = passedIds.fold<double>(
        0.0,
        (sum, id) => sum + (uniqueCredits[id] ?? 0.0),
      );

      final difference = totalCredits - earnedCredits;
      remainingCredits = difference < 0.0 ? 0.0 : difference;
    }

    // 11. GPA: chua tu tinh khi chua co quy che
    final hasOfficialResults = progressCourses.any(
      (e) =>
          e.status == 'PASSED' ||
          e.status == 'FAILED' ||
          e.scoreStatus == 'POLICY_PENDING',
    );

    return AcademicProgressDto(
      curriculumVersionId: versionId,
      totalCredits: totalCredits,
      earnedCredits: earnedCredits,
      remainingCredits: remainingCredits,
      creditStatus: canCalculateCredits ? 'CONFIRMED' : 'POLICY_PENDING',
      gpa: null,
      gpaStatus: hasOfficialResults ? 'POLICY_PENDING' : 'NO_DATA',
      courses: progressCourses,
    );
  }
}
