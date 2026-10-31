import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import '../security/account_guard.dart';

class StudentEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  Future<CurriculumDetailsDto?> getMyCurriculum(
    Session session,
  ) async {
    // 1. Xác thực và kiểm tra quyền Student
    final account = await AccountGuard.requireRole(
      session,
      allowedRoles: {AccountRole.student},
    );

    // 2. Tìm hồ sơ sinh viên đang đăng nhập
    final student = await Student.db.findFirstRow(
      session,
      where: (t) => t.userAccountId.equals(account.id!),
    );

    if (student == null) return null;

    // 3. Lấy phiên bản chương trình đào tạo
    final version = await CurriculumVersion.db.findById(
      session,
      student.curriculumVersionId,
    );

    if (version == null) return null;

    // 4. Lấy chương trình đào tạo
    final curriculum = await Curriculum.db.findById(
      session,
      version.curriculumId,
    );

    if (curriculum == null) return null;

    // 5. Lấy các môn trong phiên bản CTĐT
    final items = await CurriculumItem.db.find(
      session,
      where: (t) => t.curriculumVersionId.equals(
        student.curriculumVersionId,
      ),
      orderBy: (t) => t.semester,
    );

    // 6. Tập hợp ID các môn học, loại trùng
    final courseIds = items.map((item) => item.courseId).toSet();

    // 7. Lấy nhiều Course trong một truy vấn
    final courses = courseIds.isEmpty
        ? <Course>[]
        : await Course.db.find(
            session,
            where: (t) => t.id.inSet(courseIds),
          );

    // 8. Tạo Map để tra cứu nhanh theo ID
    final courseById = <int, Course>{
      for (final course in courses)
        if (course.id != null) course.id!: course,
    };

    // 9. Ánh xạ dữ liệu sang DTO
    final itemDetails = <CurriculumItemDetailDto>[];

    for (final item in items) {
      final course = courseById[item.courseId];

      // Giữ hành vi code cũ nếu thiếu Course
      if (course == null) continue;

      itemDetails.add(
        CurriculumItemDetailDto(
          course: CourseItemDto(
            code: course.code,
            name: course.name,
            credits: course.credits,
            description: course.description,
          ),
          semester: item.semester,
          isRequired: item.isRequired,
        ),
      );
    }

    // 10. Trả kết quả về Flutter
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
