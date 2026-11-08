import 'package:smart_course_registration_chatbot_client/smart_course_registration_chatbot_client.dart';

/// F06: map mã lỗi máy chủ sang thông báo tiếng Việt.
/// Không suy luận trạng thái từ văn bản exception.toString().
String courseErrorMessage(Object error) {
  if (error is AppException) {
    switch (error.code) {
      case 'AUTH_REQUIRED':
        return 'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.';
      case 'ACCOUNT_INACTIVE':
      case 'ACCOUNT_NOT_PROVISIONED':
      case 'FORBIDDEN':
        return 'Tài khoản không có quyền thực hiện thao tác này.';
      case 'COURSE_CODE_EXISTS':
        return 'Mã môn học đã tồn tại. Vui lòng chọn mã khác.';
      case 'INVALID_CREDITS':
        return 'Số tín chỉ không hợp lệ.';
      case 'INVALID_COURSE_CODE':
      case 'INVALID_COURSE_NAME':
        return 'Mã hoặc tên môn học không hợp lệ.';
      case 'ID_REQUIRED':
      case 'INVALID_ID':
      case 'INVALID_COURSE_ID':
      case 'NOT_FOUND':
        return 'Không tìm thấy môn học. Hãy tải lại danh sách.';
      case 'INVALID_PAGINATION':
        return 'Trang dữ liệu không hợp lệ.';
      case 'INVALID_SEARCH_QUERY':
        return 'Nội dung tìm kiếm không hợp lệ.';
      default:
        return error.message.isNotEmpty
            ? error.message
            : 'Không thể thực hiện yêu cầu. Vui lòng thử lại.';
    }
  }
  return 'Không thể kết nối hoặc xử lý dữ liệu. Vui lòng thử lại.';
}
