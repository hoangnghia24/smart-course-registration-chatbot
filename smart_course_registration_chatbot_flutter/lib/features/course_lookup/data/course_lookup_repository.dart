/// Hợp đồng dữ liệu của màn hình F03.
///
/// Chưa gọi Serverpod: gói bàn giao 24/10/2026 chỉ có F01 (Auth).
/// Khi BE giao generated client F03, triển khai một repository mới và
/// truyền vào CourseLookupScreen(repository: ...) thay vì đoán endpoint.
enum CourseLookupFilter { all, majorOnly, threeCredits }

class CourseClassInfo {
  const CourseClassInfo({
    required this.classCode,
    required this.schedule,
    required this.registered,
    required this.capacity,
  });

  final String classCode;
  final String schedule;
  final int registered;
  final int capacity;
  int get remaining => capacity - registered;
}

class CourseInfo {
  const CourseInfo({
    required this.code,
    required this.name,
    required this.credits,
    required this.inMajor,
    required this.isCompleted,
    this.sampleGrade,
    this.classes = const [],
  });

  final String code;
  final String name;
  final int credits;
  final bool inMajor;
  final bool isCompleted;
  final double? sampleGrade;
  final List<CourseClassInfo> classes;
}

abstract class CourseLookupRepository {
  Future<List<CourseInfo>> lookup({
    required String query,
    required CourseLookupFilter filter,
  });
}

/// DỮ LIỆU MINH HỌA CỦA FIGMA, KHÔNG LẤY TỪ CƠ SỞ DỮ LIỆU.
class DemoCourseLookupRepository implements CourseLookupRepository {
  const DemoCourseLookupRepository();

  static const List<CourseInfo> _sampleCourses = [
    CourseInfo(
      code: 'MOPR331279',
      name: 'Lập trình di động',
      credits: 3,
      inMajor: true,
      isCompleted: false,
      classes: [
        CourseClassInfo(
          classCode: 'MOPR331279_01CLC',
          schedule: 'Thứ 4 · Tiết 2–5 · Phòng B205',
          registered: 45,
          capacity: 60,
        ),
      ],
    ),
    CourseInfo(
      code: 'OOPR230101',
      name: 'Lập trình hướng đối tượng',
      credits: 3,
      inMajor: false,
      isCompleted: true,
      sampleGrade: 9.0,
    ),
  ];

  @override
  Future<List<CourseInfo>> lookup({
    required String query,
    required CourseLookupFilter filter,
  }) async {
    // Độ trễ hiển thị phục vụ kiểm thử UI loading, KHÔNG mô phỏng API thật.
    await Future<void>.delayed(const Duration(milliseconds: 160));
    final normalizedQuery = _normalize(query.trim());
    return _sampleCourses.where((course) {
      final matchesText = normalizedQuery.isEmpty ||
          _normalize(course.name).contains(normalizedQuery) ||
          _normalize(course.code).contains(normalizedQuery);
      final matchesFilter = switch (filter) {
        CourseLookupFilter.all => true,
        CourseLookupFilter.majorOnly => course.inMajor,
        CourseLookupFilter.threeCredits => course.credits == 3,
      };
      return matchesText && matchesFilter;
    }).toList(growable: false);
  }
}

/// Tìm kiếm không dấu đơn giản cho dữ liệu tiếng Việt trong bản mẫu.
String _normalize(String value) {
  const marks = [
    'àáạảãâầấậẩẫăằắặẳẵ',
    'èéẹẻẽêềếệểễ',
    'ìíịỉĩ',
    'òóọỏõôồốộổỗơờớợởỡ',
    'ùúụủũưừứựửữ',
    'ỳýỵỷỹ',
    'đ',
  ];
  const bases = ['a', 'e', 'i', 'o', 'u', 'y', 'd'];
  var result = value.toLowerCase();
  for (var i = 0; i < marks.length; i++) {
    for (final mark in marks[i].split('')) {
      result = result.replaceAll(mark, bases[i]);
    }
  }
  return result;
}
