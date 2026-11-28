import 'package:flutter/widgets.dart';

import 'chatbot_repository_scope.dart';
import 'data/chatbot_repository.dart';
import 'presentation/chatbot_controller.dart';

/// Quản lý duy nhất một [ChatbotController] trong RAM theo từng phiên đăng nhập.
///
/// - Khi `sessionKey` là `null` (chưa đăng nhập hoặc vừa đăng xuất), controller
///   cũ bị `dispose()` ngay lập tức, toàn bộ tin nhắn và request chờ bị hủy.
/// - Khi `sessionKey` có giá trị (đang đăng nhập), một [ChatbotController] duy
///   nhất được giữ trong RAM xuyên suốt quá trình chuyển màn hình.
/// - Khi đăng xuất rồi đăng nhập lại (dù cùng hay khác tài khoản), một instance
///   [ChatbotController] mới hoàn toàn với hội thoại trống sẽ được khởi tạo.
class ChatbotSessionScope extends StatefulWidget {
  const ChatbotSessionScope({
    super.key,
    required this.sessionKey,
    this.repository,
    this.isSimulatedSource = false,
    required this.child,
  });

  /// Định danh phiên đăng nhập hiện tại (ví dụ `'real-12'` hoặc `'demo-sv001'`).
  /// Truyền `null` khi người dùng chưa đăng nhập hoặc đã đăng xuất.
  final String? sessionKey;

  /// Có thể truyền trực tiếp hoặc lấy từ [ChatbotRepositoryScope] bên trên.
  final ChatbotRepository? repository;

  /// Đánh dấu nguồn dữ liệu có phải là mô phỏng hay đã kết nối Backend thật.
  final bool isSimulatedSource;

  final Widget child;

  static ChatbotController? maybeControllerOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_ChatbotSessionInherited>()
        ?.controller;
  }

  static bool isSingleConversationSessionOf(BuildContext context) {
    return context
            .dependOnInheritedWidgetOfExactType<_ChatbotSessionInherited>()
            ?.controller !=
        null;
  }

  static bool? maybeIsSimulatedSourceOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_ChatbotSessionInherited>()
        ?.isSimulatedSource;
  }

  @override
  State<ChatbotSessionScope> createState() => _ChatbotSessionScopeState();
}

class _ChatbotSessionScopeState extends State<ChatbotSessionScope> {
  ChatbotController? _controller;
  ChatbotRepository? _resolvedRepository;
  String? _activeSessionKey;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncController();
  }

  @override
  void didUpdateWidget(covariant ChatbotSessionScope oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncController();
  }

  void _syncController() {
    final nextRepository =
        widget.repository ?? ChatbotRepositoryScope.maybeOf(context);
    final nextKey = widget.sessionKey?.trim();
    final hasValidSession =
        nextRepository != null && nextKey != null && nextKey.isNotEmpty;

    if (!hasValidSession) {
      _disposeController();
      _resolvedRepository = nextRepository;
      _activeSessionKey = null;
      return;
    }

    final shouldRecreate = _controller == null ||
        _activeSessionKey != nextKey ||
        !identical(_resolvedRepository, nextRepository);

    if (shouldRecreate) {
      _disposeController();
      _resolvedRepository = nextRepository;
      _activeSessionKey = nextKey;
      _controller = ChatbotController(repository: nextRepository);
    }
  }

  void _disposeController() {
    _controller?.dispose();
    _controller = null;
  }

  @override
  void dispose() {
    _disposeController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _ChatbotSessionInherited(
      controller: _controller,
      sessionKey: _activeSessionKey,
      isSimulatedSource: widget.isSimulatedSource,
      child: widget.child,
    );
  }
}

class _ChatbotSessionInherited extends InheritedWidget {
  const _ChatbotSessionInherited({
    required this.controller,
    required this.sessionKey,
    required this.isSimulatedSource,
    required super.child,
  });

  final ChatbotController? controller;
  final String? sessionKey;
  final bool isSimulatedSource;

  @override
  bool updateShouldNotify(_ChatbotSessionInherited oldWidget) {
    return !identical(controller, oldWidget.controller) ||
        sessionKey != oldWidget.sessionKey ||
        isSimulatedSource != oldWidget.isSimulatedSource;
  }
}
