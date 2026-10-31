import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/dashboard_widgets.dart';
import '../../data/mock/mock_auth.dart';

class LoginDemoScreen extends StatefulWidget {
  const LoginDemoScreen({
    super.key,
    this.authController,
    this.onServerSignIn,
  }) : assert(authController != null || onServerSignIn != null);

  /// Giữ lại chế độ demo để không làm hỏng widget tests Tuần 5.
  final DemoAuthController? authController;

  /// F01: form Figma giữ nguyên, chỉ thay nơi thực hiện đăng nhập.
  /// Trả null nếu thành công hoặc một thông báo lỗi để hiển thị.
  final Future<String?> Function(String email, String password)? onServerSignIn;

  @override
  State<LoginDemoScreen> createState() => _LoginDemoScreenState();
}

class _LoginDemoScreenState extends State<LoginDemoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _rememberLogin = false;
  bool _obscurePassword = true;
  String? _authError;
  bool _submitting = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting) return;
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _authError = null);

    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (widget.onServerSignIn != null) {
      setState(() => _submitting = true);
      try {
        final issue = await widget.onServerSignIn!(
          _usernameController.text.trim(),
          _passwordController.text,
        );
        if (mounted) setState(() => _authError = issue);
      } catch (_) {
        if (mounted) {
          setState(() => _authError = 'Không thể kết nối máy chủ.');
        }
      } finally {
        if (mounted) setState(() => _submitting = false);
      }
      return;
    }

    final result = widget.authController!.signIn(
      username: _usernameController.text,
      password: _passwordController.text,
    );
    if (!result.success) setState(() => _authError = result.message);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: SizedBox(
                width: double.infinity,
                height: 844,
                child: _LoginCanvas(
                  formKey: _formKey,
                  usernameController: _usernameController,
                  passwordController: _passwordController,
                  rememberLogin: _rememberLogin,
                  obscurePassword: _obscurePassword,
                  authError: _authError,
                  isServerMode: widget.onServerSignIn != null,
                  isBusy: _submitting,
                  onRememberChanged: (value) {
                    setState(() => _rememberLogin = value ?? false);
                  },
                  onTogglePassword: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                  onForgotPassword: () => showPreviewMessage(
                    context,
                    widget.onServerSignIn != null
                        ? 'Chưa có xác nhận API đặt lại mật khẩu. Vui lòng liên hệ quản trị viên.'
                        : 'Quên mật khẩu sẽ được triển khai sau; demo không gửi email thật.',
                  ),
                  onSubmit: _submit,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _LoginCanvas extends StatelessWidget {
  const _LoginCanvas({
    required this.formKey,
    required this.usernameController,
    required this.passwordController,
    required this.rememberLogin,
    required this.obscurePassword,
    required this.authError,
    required this.isServerMode,
    required this.isBusy,
    required this.onRememberChanged,
    required this.onTogglePassword,
    required this.onForgotPassword,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final bool rememberLogin;
  final bool obscurePassword;
  final String? authError;
  final bool isServerMode;
  final bool isBusy;
  final ValueChanged<bool?> onRememberChanged;
  final VoidCallback onTogglePassword;
  final VoidCallback onForgotPassword;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        const _LoginHero(),
        Positioned(
          top: 230,
          left: 20,
          right: 20,
          child: _LoginCard(
            formKey: formKey,
            usernameController: usernameController,
            passwordController: passwordController,
            rememberLogin: rememberLogin,
            obscurePassword: obscurePassword,
            authError: authError,
            isServerMode: isServerMode,
            isBusy: isBusy,
            onRememberChanged: onRememberChanged,
            onTogglePassword: onTogglePassword,
            onForgotPassword: onForgotPassword,
            onSubmit: onSubmit,
          ),
        ),
        const Positioned(
          top: 790,
          left: 20,
          right: 20,
          child: _LoginFooter(),
        ),
      ],
    );
  }
}

class _LoginHero extends StatelessWidget {
  const _LoginHero();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 278,
      width: double.infinity,
      child: DecoratedBox(
        decoration: const BoxDecoration(color: AppColors.primary),
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            Positioned(
              top: -75,
              right: -55,
              child: _DecorativeCircle(size: 190, opacity: 0.08),
            ),
            Positioned(
              top: 118,
              left: -78,
              child: _DecorativeCircle(size: 150, opacity: 0.07),
            ),
            Positioned(
              top: 22,
              right: 35,
              child: _DecorativeCircle(size: 70, opacity: 0.06),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const _AcademicLogo(),
                      const SizedBox(width: 10),
                      Text(
                        'HỆ THỐNG',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.84),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.3,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 31),
                  const Text(
                    'ĐĂNG KÝ HỌC PHẦN\nTHÔNG MINH',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      height: 1.13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 11),
                  Text(
                    'Học tập chủ động · Lựa chọn dễ dàng',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.76),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DecorativeCircle extends StatelessWidget {
  const _DecorativeCircle({required this.size, required this.opacity});

  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withValues(alpha: opacity),
          width: 2,
        ),
      ),
    );
  }
}

class _AcademicLogo extends StatelessWidget {
  const _AcademicLogo();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 43,
      height: 43,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.school_rounded,
        color: AppColors.primary,
        size: 25,
      ),
    );
  }
}

class _LoginCard extends StatelessWidget {
  const _LoginCard({
    required this.formKey,
    required this.usernameController,
    required this.passwordController,
    required this.rememberLogin,
    required this.obscurePassword,
    required this.authError,
    required this.isServerMode,
    required this.isBusy,
    required this.onRememberChanged,
    required this.onTogglePassword,
    required this.onForgotPassword,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final bool rememberLogin;
  final bool obscurePassword;
  final String? authError;
  final bool isServerMode;
  final bool isBusy;
  final ValueChanged<bool?> onRememberChanged;
  final VoidCallback onTogglePassword;
  final VoidCallback onForgotPassword;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shadowColor: AppColors.primary.withValues(alpha: 0.15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Chào mừng trở lại!',
                style: TextStyle(
                  color: AppColors.text,
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'Đăng nhập để tiếp tục quản lý học phần.',
                style: TextStyle(color: AppColors.mutedText, fontSize: 12),
              ),
              const SizedBox(height: 17),
              _FieldLabel(label: isServerMode ? 'Email nhà trường' : 'Email hoặc mã người dùng'),
              const SizedBox(height: 6),
              TextFormField(
                key: const ValueKey('login-username'),
                controller: usernameController,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: isServerMode ? 'Nhập email nhà trường' : 'Nhập email hoặc mã sinh viên',
                  prefixIcon: Icon(Icons.mail_outline_rounded),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập tài khoản';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              _FieldLabel(label: 'Mật khẩu'),
              const SizedBox(height: 6),
              TextFormField(
                key: const ValueKey('login-password'),
                controller: passwordController,
                obscureText: obscurePassword,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => onSubmit(),
                decoration: InputDecoration(
                  hintText: 'Nhập mật khẩu',
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  suffixIcon: IconButton(
                    key: const ValueKey('login-toggle-password'),
                    tooltip: obscurePassword ? 'Hiện mật khẩu' : 'Ẩn mật khẩu',
                    onPressed: onTogglePassword,
                    icon: Icon(
                      obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập mật khẩu';
                  }
                  return null;
                },
              ),
              if (authError != null) ...[
                const SizedBox(height: 8),
                Text(
                  authError!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              const SizedBox(height: 7),
              Row(
                children: [
                  if (!isServerMode) ...[
                    Checkbox(
                      key: const ValueKey('login-remember'),
                      value: rememberLogin,
                      onChanged: onRememberChanged,
                      visualDensity: VisualDensity.compact,
                      activeColor: AppColors.primary,
                    ),
                    const Expanded(
                      child: Text(
                        'Ghi nhớ đăng nhập',
                        style: TextStyle(color: AppColors.mutedText, fontSize: 11),
                      ),
                    ),
                  ] else
                    const Expanded(
                      child: Text(
                        'Phiên đăng nhập do Serverpod quản lý',
                        style: TextStyle(color: AppColors.mutedText, fontSize: 10),
                      ),
                    ),
                  TextButton(
                    onPressed: onForgotPassword,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 36),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'Quên mật khẩu?',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 7),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton.icon(
                  key: const ValueKey('login-submit'),
                  onPressed: isBusy ? null : onSubmit,
                  icon: isBusy
                      ? const SizedBox(
                          width: 19,
                          height: 19,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.arrow_forward_rounded, size: 19),
                  label: Text(isBusy ? 'Đang đăng nhập...' : 'Đăng nhập'),
                ),
              ),
              const SizedBox(height: 11),
              Center(
                child: Text(
                  isServerMode
                      ? 'Dùng email và mật khẩu được nhà trường cấp'
                      : 'DEMO-ONLY • sv001 / gv001 / admin001 • demo123',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.mutedText,
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: AppColors.text,
        fontSize: 12,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _LoginFooter extends StatelessWidget {
  const _LoginFooter();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Đăng nhập an toàn · Bảo mật thông tin',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.mutedText, fontSize: 10),
        ),
        const SizedBox(height: 5),
        Text(
          '© 2026 Hệ thống đăng ký học phần thông minh',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.mutedText.withValues(alpha: 0.8),
            fontSize: 9,
          ),
        ),
      ],
    );
  }
}
