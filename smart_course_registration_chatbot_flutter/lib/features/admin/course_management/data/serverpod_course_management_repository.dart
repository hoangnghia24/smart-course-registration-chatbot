import 'package:smart_course_registration_chatbot_client/smart_course_registration_chatbot_client.dart';

import '../domain/admin_course.dart';
import 'course_management_repository.dart';

/// F06: adapter Serverpod hiện có, độc lập với widget.
///
/// Khi Nghĩa thay đổi generated API, cập nhật các RPC và mapping ở đây;
/// không sửa generated client thủ công hay đưa CourseDto vào UI.
class ServerpodCourseManagementRepository
    implements CourseManagementRepository {
  final Future<List<CourseDto>> Function(int, int) _getCoursesPage;
  final Future<List<CourseDto>> Function(String, int, int) _searchCourses;
  final Future<CourseDto> Function(int) _getCourseById;
  final Future<CourseDto> Function(CourseDto) _createCourse;
  final Future<CourseDto> Function(CourseDto) _updateCourse;
  final Future<bool> Function(int) _deleteCourse;

  ServerpodCourseManagementRepository(Client client)
    : this.fromRpc(
        getCoursesPage: client.course.getCoursesPage,
        searchCourses: client.course.searchCourses,
        getCourseById: client.course.getCourseById,
        createCourse: client.course.createCourse,
        updateCourse: client.course.updateCourse,
        deleteCourse: client.course.deleteCourse,
      );

  /// Cho phép kiểm thử mapping/forward lỗi mà không cần chạy Serverpod.
  ServerpodCourseManagementRepository.fromRpc({
    required Future<List<CourseDto>> Function(int, int) getCoursesPage,
    required Future<List<CourseDto>> Function(String, int, int) searchCourses,
    required Future<CourseDto> Function(int) getCourseById,
    required Future<CourseDto> Function(CourseDto) createCourse,
    required Future<CourseDto> Function(CourseDto) updateCourse,
    required Future<bool> Function(int) deleteCourse,
  }) : _getCoursesPage = getCoursesPage,
       _searchCourses = searchCourses,
       _getCourseById = getCourseById,
       _createCourse = createCourse,
       _updateCourse = updateCourse,
       _deleteCourse = deleteCourse;

  static AdminCourse _fromDto(CourseDto dto) => AdminCourse(
    id: dto.id,
    code: dto.code,
    name: dto.name,
    credits: dto.credits,
    description: dto.description,
    isActive: dto.isActive,
  );

  static CourseDto _toDto(AdminCourse course, {required bool forCreate}) =>
      CourseDto(
        id: forCreate ? null : course.id,
        code: course.code,
        name: course.name,
        credits: course.credits,
        description: course.description,
        isActive: course.isActive,
      );

  static void _checkPage(int page, int pageSize) {
    if (page < 1) {
      throw ArgumentError.value(page, 'page', 'Phải >= 1');
    }
    if (pageSize < 1 || pageSize > 50) {
      throw ArgumentError.value(pageSize, 'pageSize', 'Phải từ 1 đến 50');
    }
  }

  static void _checkId(int id) {
    if (id <= 0) {
      throw ArgumentError.value(id, 'courseId', 'Phải > 0');
    }
  }

  @override
  Future<List<AdminCourse>> getPage({
    required int page,
    int pageSize = 20,
  }) async {
    _checkPage(page, pageSize);
    final dtos = await _getCoursesPage(page, pageSize);
    return dtos.map(_fromDto).toList(growable: false);
  }

  @override
  Future<List<AdminCourse>> search({
    required String query,
    int page = 1,
    int pageSize = 20,
  }) async {
    _checkPage(page, pageSize);
    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty) return const <AdminCourse>[];
    final dtos = await _searchCourses(cleanQuery, page, pageSize);
    return dtos.map(_fromDto).toList(growable: false);
  }

  @override
  Future<AdminCourse> getById(int courseId) async {
    _checkId(courseId);
    return _fromDto(await _getCourseById(courseId));
  }

  @override
  Future<AdminCourse> create(AdminCourse course) async {
    final created = await _createCourse(_toDto(course, forCreate: true));
    return _fromDto(created);
  }

  @override
  Future<AdminCourse> update(AdminCourse course) async {
    final id = course.id;
    if (id == null) {
      throw ArgumentError('Cập nhật môn học cần id');
    }
    _checkId(id);
    final updated = await _updateCourse(_toDto(course, forCreate: false));
    return _fromDto(updated);
  }

  @override
  Future<bool> deactivate(int courseId) async {
    _checkId(courseId);
    // RPC deleteCourse thực hiện soft-delete (isActive=false) tại BE.
    // false là trạng thái thất bại/không tìm thấy, không tự coi là thành công.
    return _deleteCourse(courseId);
  }
}
