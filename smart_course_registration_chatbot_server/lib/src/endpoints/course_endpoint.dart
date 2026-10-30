import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';
import '../security/account_guard.dart';

class CourseEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  /// Lấy danh sách tất cả môn học.
  Future<List<CourseDto>> getAllCourses(Session session) async {
    await AccountGuard.require(
      session,
      allowedRoles: {AccountRole.admin},
    );

    var courses = await Course.db.find(session, orderBy: (t) => t.code);
    return courses
        .map((c) => CourseDto(
              id: c.id,
              code: c.code,
              name: c.name,
              credits: c.credits,
              description: c.description,
              isActive: c.isActive,
            ))
        .toList();
  }

  /// Tạo môn học mới.
  Future<CourseDto> createCourse(Session session, CourseDto courseDto) async {
    await AccountGuard.require(
      session,
      allowedRoles: {AccountRole.admin},
    );

    var course = Course(
      code: courseDto.code,
      name: courseDto.name,
      credits: courseDto.credits,
      description: courseDto.description,
      isActive: courseDto.isActive,
    );

    var savedCourse = await Course.db.insertRow(session, course);
    return courseDto.copyWith(id: savedCourse.id);
  }

  /// Cập nhật thông tin môn học.
  Future<CourseDto> updateCourse(Session session, CourseDto courseDto) async {
    await AccountGuard.require(
      session,
      allowedRoles: {AccountRole.admin},
    );

    if (courseDto.id == null) {
      throw AppException(code: 'ID_REQUIRED', message: 'ID môn học là bắt buộc để cập nhật.');
    }

    var course = await Course.db.findById(session, courseDto.id!);
    if (course == null) {
      throw AppException(code: 'NOT_FOUND', message: 'Không tìm thấy môn học.');
    }

    course.code = courseDto.code;
    course.name = courseDto.name;
    course.credits = courseDto.credits;
    course.description = courseDto.description;
    course.isActive = courseDto.isActive;

    await Course.db.updateRow(session, course);
    return courseDto;
  }

  /// Xóa môn học.
  Future<bool> deleteCourse(Session session, int courseId) async {
    await AccountGuard.require(
      session,
      allowedRoles: {AccountRole.admin},
    );

    var course = await Course.db.findById(session, courseId);
    if (course == null) return false;

    await Course.db.deleteRow(session, course);
    return true;
  }

  /// Tìm kiếm môn học.
  Future<List<CourseDto>> searchCourses(Session session, String query) async {
    await AccountGuard.require(
      session,
      allowedRoles: {AccountRole.admin},
    );

    var courses = await Course.db.find(
      session,
      where: (t) => t.code.ilike('%$query%') | t.name.ilike('%$query%'),
      orderBy: (t) => t.code,
    );

    return courses
        .map((c) => CourseDto(
              id: c.id,
              code: c.code,
              name: c.name,
              credits: c.credits,
              description: c.description,
              isActive: c.isActive,
            ))
        .toList();
  }
}
