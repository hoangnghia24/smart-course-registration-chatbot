import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import '../security/account_guard.dart';

class StudentEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  Future<CurriculumDetailsDto?> getMyCurriculum(
    Session session,
  ) async {
    // 1. Xac thuc va kiem tra quyen Student
    final account = await AccountGuard.requireRole(
      session,
      allowedRoles: {AccountRole.student},
    );

    // 2. Tim ho so sinh vien dang dang nhap
    final student = await Student.db.findFirstRow(
      session,
      where: (t) => t.userAccountId.equals(account.id!),
    );

    if (student == null) return null;

    // 3. Lay phien ban chuong trinh dao tao
    final version = await CurriculumVersion.db.findById(
      session,
      student.curriculumVersionId,
    );

    if (version == null) return null;

    // 4. Lay chuong trinh dao tao
    final curriculum = await Curriculum.db.findById(
      session,
      version.curriculumId,
    );

    if (curriculum == null) return null;

    // 5. Lay cac hoc phan trong phien ban CTDT
    final items = await CurriculumItem.db.find(
      session,
      where: (t) => t.curriculumVersionId.equals(
        student.curriculumVersionId,
      ),
      orderBy: (t) => t.semester,
    );

    // 6. Lay cac khoi kien thuc thuoc phien ban CTDT
    final groups = await CurriculumGroup.db.find(
      session,
      where: (t) => t.curriculumVersionId.equals(
        student.curriculumVersionId,
      ),
    );

    // 7. Tao Map tra cuu khoi kien thuc theo ID
    final groupById = <int, CurriculumGroup>{
      for (final group in groups)
        if (group.id != null) group.id!: group,
    };

    // 8. Tap hop ID cac mon hoc, loai trung
    final courseIds = items.map((item) => item.courseId).toSet();

    // 9. Lay nhieu Course trong mot truy van
    final courses = courseIds.isEmpty
        ? <Course>[]
        : await Course.db.find(
            session,
            where: (t) => t.id.inSet(courseIds),
          );

    // 10. Tao Map tra cuu Course theo ID
    final courseById = <int, Course>{
      for (final course in courses)
        if (course.id != null) course.id!: course,
    };

    // 11. Anh xa du lieu sang DTO
    final itemDetails = <CurriculumItemDetailDto>[];

    for (final item in items) {
      final course = courseById[item.courseId];

      // Giu hanh vi cu neu thieu Course
      if (course == null) continue;

      // Tim khoi kien thuc cua hoc phan
      final group = item.groupId == null ? null : groupById[item.groupId];

      itemDetails.add(
        CurriculumItemDetailDto(
          course: CourseItemDto(
            code: course.code,
            name: course.name,
            credits: course.credits,
            description: course.description,
          ),

          // Cac truong cu
          semester: item.semester,
          isRequired: item.isRequired,

          // Bon truong moi cho F04
          groupCode: group?.groupCode,
          groupName: group?.groupName,
          groupOrder: group?.groupOrder,
          itemOrder: item.itemOrder,
        ),
      );
    }

    // 12. Sap xep hoc phan theo khoi kien thuc
    itemDetails.sort((a, b) {
      // Sap xep theo thu tu khoi
      final groupOrderCompare = (a.groupOrder ?? 999999).compareTo(
        b.groupOrder ?? 999999,
      );

      if (groupOrderCompare != 0) {
        return groupOrderCompare;
      }

      // Giu cac hoc phan cung khoi lien tiep
      final groupCodeCompare = (a.groupCode ?? '\uffff').compareTo(
        b.groupCode ?? '\uffff',
      );

      if (groupCodeCompare != 0) {
        return groupCodeCompare;
      }

      // Sap xep theo thu tu mon trong khoi
      final itemOrderCompare = (a.itemOrder ?? 999999).compareTo(
        b.itemOrder ?? 999999,
      );

      if (itemOrderCompare != 0) {
        return itemOrderCompare;
      }

      // Neu trung thu tu, sap xep theo ma mon
      return a.course.code.compareTo(b.course.code);
    });

    // 13. Tra ket qua ve Flutter
    return CurriculumDetailsDto(
      curriculum: CurriculumDto(
        code: curriculum.code,
        name: curriculum.name,
        majorCode: curriculum.majorCode,
      ),
      version: CurriculumVersionDto(
        versionCode: version.versionCode,
        effectiveYear: version.effectiveYear,
        status: version.status,
      ),
      items: itemDetails,
    );
  }
}
