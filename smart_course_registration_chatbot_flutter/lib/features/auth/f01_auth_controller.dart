import 'package:flutter/foundation.dart';
import 'package:smart_course_registration_chatbot_client/smart_course_registration_chatbot_client.dart';

import 'data/f01_auth_gateway.dart';

/// Trạng thái F01 không phụ thuộc Widget, dễ unit test.
class F01AuthController extends ChangeNotifier {
  F01AuthController(this._gateway);

  final F01AuthGateway _gateway;
  F01User? _user;
  bool _isLoading = true;
  bool _isBusy = false;
  String? _error;

  F01User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isBusy => _isBusy;
  String? get error => _error;

  Future<void> restoreSession() async {
    _isLoading = true;
    notifyListeners();
    try {
      _user = await _gateway.getCurrentUser();
      _error = null;
    } catch (_) {
      // Khởi động khi chưa đăng nhập là trạng thái bình thường.
      _user = null;
      _error = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Trả null nếu thành công; ngược lại trả thông báo để hiển thị ngay trên UI.
  Future<String?> signIn({required String email, required String password}) async {
    if (_isBusy) return null;
    _isBusy = true;
    _error = null;
    notifyListeners();
    try {
      final current = await _gateway.signIn(email, password);
      _user = current;
      return null;
    } on F01AccountInactiveException {
      _error = 'Tài khoản chưa được kích hoạt hoặc đã bị khóa.';
      return _error;
    } on AppException catch (e) {
      _error = switch (e.code) {
        'ACCOUNT_INACTIVE' => 'Tài khoản đã bị khóa hoặc chưa kích hoạt.',
        'ACCOUNT_NOT_PROVISIONED' =>
          'Tài khoản chưa được nhà trường cấp quyền truy cập.',
        'AUTH_REQUIRED' => 'Phiên đã hết hạn, vui lòng đăng nhập lại.',
        'FORBIDDEN' => 'Tài khoản không có quyền truy cập.',
        _ => 'Đăng nhập thất bại. Vui lòng thử lại.',
      };
      return _error;
    } catch (_) {
      _error = 'Không thể đăng nhập. Kiểm tra email, mật khẩu và kết nối máy chủ.';
      return _error;
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    if (_isBusy) return;
    _isBusy = true;
    notifyListeners();
    try {
      await _gateway.signOut();
      _user = null;
      _error = null;
    } catch (_) {
      _error = 'Đăng xuất chưa thành công. Vui lòng thử lại.';
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }
}
