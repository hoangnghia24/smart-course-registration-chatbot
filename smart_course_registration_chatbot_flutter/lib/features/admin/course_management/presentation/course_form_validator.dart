/// Kiểm tra dữ liệu nhập cơ bản trên giao diện Admin F06.
/// Backend vẫn là nguồn kiểm tra nghiệp vụ và phân quyền cuối cùng.
class CourseFormValidator {
  const CourseFormValidator._();

  static String? code(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập mã môn học';
    }
    return null;
  }

  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập tên môn học';
    }
    return null;
  }

  static String? credits(String? value) {
    final parsed = int.tryParse((value ?? '').trim());
    if (parsed == null) {
      return 'Số tín chỉ phải là số nguyên';
    }
    if (parsed < 1 || parsed > 12) {
      return 'Số tín chỉ phải từ 1 đến 12';
    }
    return null;
  }
}
