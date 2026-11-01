import 'package:smart_course_registration_chatbot_client/smart_course_registration_chatbot_client.dart';

import 'course_lookup_repository.dart';

/// Adapter cho Serverpod RPC F03, không tự khai báo URL REST.
/// Theo contract 31/10: searchCourses(query, page, pageSize), getCourseById(id).
/// Backend ILIKE chưa bảo đảm tìm không dấu; không tự khẳng định có khả năng này.
class ServerpodCourseLookupRepository implements CourseLookupRepository, CourseDetailsRepository {
  ServerpodCourseLookupRepository(Client client)
      : this.fromRpc(
          search: (query, page, pageSize) =>
              client.course.searchCourses(query, page, pageSize),
          detail: (courseId) => client.course.getCourseById(courseId),
        );

  /// Cho phép test adapter bằng fake RPC, không cần Serverpod đang chạy.
  const ServerpodCourseLookupRepository.fromRpc({
    required Future<List<CourseDto>> Function(String, int, int) search,
    required Future<CourseDto> Function(int) detail,
  })  : _search = search,
        _detail = detail;

  final Future<List<CourseDto>> Function(String, int, int) _search;
  final Future<CourseDto> Function(int) _detail;

  static const int pageSize = 50;

  @override
  Future<List<CourseInfo>> lookup({
    required String query,
    required CourseLookupFilter filter,
  }) async {
    final term = query.trim();
    // searchCourses(query rỗng) theo contract trả []; không dùng API F06
    // getCoursesPage vì API đó CHỈ dành cho Admin.
    if (term.isEmpty) return const [];
    if (filter == CourseLookupFilter.majorOnly) {
      throw UnsupportedError('F03 chưa trả dữ liệu thuộc ngành/CTĐT.');
    }
    final rows = await _search(term, 1, pageSize);
    return rows
        .where((row) => row.isActive)
        .where((row) =>
            filter != CourseLookupFilter.threeCredits || row.credits == 3)
        .map(_toCourse)
        .toList(growable: false);
  }

  @override
  Future<CourseInfo> getCourseById(int courseId) async {
    if (courseId <= 0) throw ArgumentError.value(courseId, 'courseId');
    final row = await _detail(courseId);
    return _toCourse(row);
  }

  CourseInfo _toCourse(CourseDto row) => CourseInfo(
        id: row.id,
        code: row.code,
        name: row.name,
        credits: row.credits,
        description: row.description,
        isActive: row.isActive,
        // Chưa có API F05/F09/điểm/CTĐT. Không suy diễn dữ liệu cá nhân.
        inMajor: false,
        isCompleted: false,
      );
}
