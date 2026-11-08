/// Domain model Flutter cho danh mục môn học (F06).
/// Không phụ thuộc lớp CourseDto được sinh bởi Serverpod.
class AdminCourse {
  final int? id;
  final String code;
  final String name;
  final int credits;
  final String? description;
  final bool isActive;

  const AdminCourse({
    this.id,
    required this.code,
    required this.name,
    required this.credits,
    this.description,
    this.isActive = true,
  });
}
