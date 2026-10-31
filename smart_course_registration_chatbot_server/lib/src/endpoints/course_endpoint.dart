import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';
import '../security/account_guard.dart';

class CourseEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  //lấy một trang danh sách môn học với phân trang
  Future<List<CourseDto>> getCoursesPage(
    Session session,
    int page,
    int pageSize,
  ) async {
    await AccountGuard.requireRole(
      session,
      allowedRoles: {AccountRole.admin},
    );

    if (page < 1 || page > 1000 || pageSize < 1 || pageSize > 50) {
      throw AppException(
        code: 'INVALID_PAGINATION',
        message: 'Tham số phân trang không hợp lệ.',
      );
    }

    final courses = await Course.db.find(
      session,
      orderBy: (t) => t.code,
      limit: pageSize,
      offset: (page - 1) * pageSize,
    );

    return courses
        .map(
          (c) => CourseDto(
            id: c.id,
            code: c.code,
            name: c.name,
            credits: c.credits,
            description: c.description,
            isActive: c.isActive,
          ),
        )
        .toList();
  }

  Future<CourseDto> createCourse(
    Session session,
    CourseDto courseDto,
  ) async {
    // 1. Chỉ Admin được tạo môn học.
    await AccountGuard.requireRole(
      session,
      allowedRoles: {AccountRole.admin},
    );

    // 2. Không cho client tự chỉ định ID.
    if (courseDto.id != null) {
      throw AppException(
        code: 'INVALID_ID',
        message: 'Không được cung cấp ID khi tạo môn học.',
      );
    }

    // 3. Chuẩn hóa mã môn và tên môn.
    final code = courseDto.code.trim().toUpperCase();
    final name = courseDto.name.trim();

    // 4. Kiểm tra mã môn.
    if (code.isEmpty || code.length > 20) {
      throw AppException(
        code: 'INVALID_COURSE_CODE',
        message: 'Mã môn học phải có từ 1 đến 20 ký tự.',
      );
    }

    // 5. Kiểm tra tên môn.
    if (name.isEmpty || name.runes.length > 150) {
      throw AppException(
        code: 'INVALID_COURSE_NAME',
        message: 'Tên môn học không hợp lệ.',
      );
    }

    // 6. Kiểm tra số tín chỉ.
    if (courseDto.credits < 1 || courseDto.credits > 12) {
      throw AppException(
        code: 'INVALID_CREDITS',
        message: 'Số tín chỉ phải từ 1 đến 12.',
      );
    }

    // 7. Kiểm tra mã môn đã tồn tại.
    final existingCourse = await Course.db.findFirstRow(
      session,
      where: (t) => t.code.equals(code),
    );

    if (existingCourse != null) {
      throw AppException(
        code: 'COURSE_CODE_EXISTS',
        message: 'Mã môn học đã tồn tại.',
      );
    }

    // 8. Tạo đối tượng Course.
    final course = Course(
      code: code,
      name: name,
      credits: courseDto.credits,
      description: courseDto.description,
      isActive: courseDto.isActive,
    );

    // 9. Lưu dữ liệu và xử lý trùng mã
    // khi có các request tạo đồng thời.
    late final Course savedCourse;

    try {
      savedCourse = await Course.db.insertRow(session, course);
    } on DatabaseQueryException catch (e) {
      if (e.code == '23505' && e.constraintName == 'course_code_idx') {
        throw AppException(
          code: 'COURSE_CODE_EXISTS',
          message: 'Mã môn học đã tồn tại.',
        );
      }

      rethrow;
    }

    // 10. Trả về dữ liệu thực tế đã lưu.
    return CourseDto(
      id: savedCourse.id,
      code: savedCourse.code,
      name: savedCourse.name,
      credits: savedCourse.credits,
      description: savedCourse.description,
      isActive: savedCourse.isActive,
    );
  }

  /// Cập nhật thông tin môn học.
  Future<CourseDto> updateCourse(Session session, CourseDto courseDto) async {
    await AccountGuard.requireRole(
      session,
      allowedRoles: {AccountRole.admin},
    );

    if (courseDto.id == null) {
      throw AppException(
        code: 'ID_REQUIRED',
        message: 'ID môn học là bắt buộc để cập nhật.',
      );
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

  Future<bool> deleteCourse(
    Session session,
    int courseId,
  ) async {
    // 1. Chỉ Admin được thực hiện.
    await AccountGuard.requireRole(
      session,
      allowedRoles: {AccountRole.admin},
    );

    // 2. Kiểm tra ID.
    if (courseId <= 0) {
      throw AppException(
        code: 'INVALID_COURSE_ID',
        message: 'ID môn học không hợp lệ.',
      );
    }

    // 3. Chỉ cập nhật trạng thái isActive.
    try {
      await Course.db.updateById(
        session,
        courseId,
        columnValues: (t) => [
          t.isActive(false),
        ],
      );

      return true;
    } on DatabaseUpdateRowException {
      // Không tìm thấy Course theo ID.
      return false;
    }
  }

  /// Tìm kiếm môn học.

  /// Escape các ký tự đặc biệt trong mẫu ILIKE.
  static String _escapeLikePattern(String value) {
    return value
        .replaceAll(r'\', r'\\')
        .replaceAll('%', r'\%')
        .replaceAll('_', r'\_');
  }

  /// Tìm kiếm môn học có phân trang.
  Future<List<CourseDto>> searchCourses(
    Session session,
    String query,
    int page,
    int pageSize,
  ) async {
    // 1. Kiểm tra quyền Admin.
    await AccountGuard.requireRole(
      session,
      allowedRoles: {AccountRole.admin},
    );

    // 2. Chuẩn hóa từ khóa.
    final keyword = query.trim();

    // 3. Không truy vấn khi không nhập từ khóa.
    if (keyword.isEmpty) {
      return [];
    }

    // 4. Giới hạn độ dài từ khóa.
    if (keyword.runes.length > 64) {
      throw AppException(
        code: 'INVALID_SEARCH_QUERY',
        message: 'Từ khóa tìm kiếm quá dài.',
      );
    }

    // 5. Kiểm tra tham số phân trang.
    if (page < 1 || pageSize < 1 || pageSize > 50) {
      throw AppException(
        code: 'INVALID_PAGINATION',
        message: 'Tham số phân trang không hợp lệ.',
      );
    }

    // 6. Escape wildcard và tạo mẫu tìm kiếm.
    final escapedKeyword = _escapeLikePattern(keyword);
    final pattern = '%$escapedKeyword%';

    // 7. Tính vị trí bắt đầu.
    final offset = (page - 1) * pageSize;

    // 8. Truy vấn Database.
    final courses = await Course.db.find(
      session,
      where: (t) => t.code.ilike(pattern) | t.name.ilike(pattern),

      orderByList: (t) => [
        Order(column: t.code, orderDescending: false),
        Order(column: t.id, orderDescending: false),
      ],

      limit: pageSize,
      offset: offset,
    );

    // 9. Chuyển Course thành CourseDto.
    return courses
        .map(
          (c) => CourseDto(
            id: c.id,
            code: c.code,
            name: c.name,
            credits: c.credits,
            description: c.description,
            isActive: c.isActive,
          ),
        )
        .toList();
  }
}
