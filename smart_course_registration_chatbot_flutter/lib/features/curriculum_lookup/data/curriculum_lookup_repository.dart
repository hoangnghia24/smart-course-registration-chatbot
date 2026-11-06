/// F04: dữ liệu CHỈ gồm các trường mà API chương trình đào tạo hiện có.
/// Tiến độ học tập, GPA, trạng thái Đã đạt/Đang học thuộc F23; không tự suy diễn.
class CurriculumDetails {
  const CurriculumDetails({
    required this.code,
    required this.name,
    required this.majorCode,
    required this.versionCode,
    required this.effectiveYear,
    required this.versionStatus,
    required this.items,
  });

  final String code;
  final String name;
  final String majorCode;
  final String versionCode;
  final int effectiveYear;
  final String versionStatus;
  final List<CurriculumCourse> items;
}

class CurriculumCourse {
  const CurriculumCourse({
    required this.code,
    required this.name,
    required this.credits,
    required this.semester,
    required this.isRequired,
    this.description,
    this.groupCode,
    this.groupName,
    this.groupOrder,
    this.itemOrder,
  });

  final String code;
  final String name;
  final int credits;
  final int semester;
  final bool isRequired;
  final String? description;

  /// Nhóm kiến thức được gán theo PHIÊN BẢN CTĐT, không phải thuộc tính cố định của môn.
  /// Có thể null nếu backend chưa phân nhóm dữ liệu cho học phần này.
  final String? groupCode;
  final String? groupName;
  final int? groupOrder;
  final int? itemOrder;
}

abstract class CurriculumLookupRepository {
  /// Kết quả null khi chưa gán CTĐT hoặc quan hệ Student–CTĐT chưa đầy đủ.
  Future<CurriculumDetails?> getMyCurriculum();
}
