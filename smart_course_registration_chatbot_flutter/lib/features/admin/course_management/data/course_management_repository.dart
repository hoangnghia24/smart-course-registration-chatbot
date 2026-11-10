import '../domain/admin_course.dart';

/// Contract ứng dụng: UI chỉ giao tiếp qua interface này.
/// Adapter Serverpod thật được triển khai ở bước sau.
abstract interface class CourseManagementRepository {
  Future<List<AdminCourse>> getPage({
    required int page,
    int pageSize = 20,
  });

  Future<List<AdminCourse>> search({
    required String query,
    int page = 1,
    int pageSize = 20,
  });

  Future<AdminCourse> getById(int courseId);

  Future<AdminCourse> create(AdminCourse course);

  Future<AdminCourse> update(AdminCourse course);

  /// Backend hiện dùng deleteCourse(courseId) để soft-delete.
  Future<bool> deactivate(int courseId);
}
