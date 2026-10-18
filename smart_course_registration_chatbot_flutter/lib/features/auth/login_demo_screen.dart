import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/dashboard_widgets.dart';
import '../../data/mock/mock_auth.dart';

class LoginDemoScreen extends StatefulWidget {
  const LoginDemoScreen({super.key, required this.authController});

  final DemoAuthController authController;

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

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _authError = null);

    if (!(_formKey.currentState?.validate() ?? false)) return;

    final result = widget.authController.signIn(
      username: _usernameController.text,
      password: _passwordController.text,
    );

    if (!result.success) {
      setState(() => _authError = result.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.only(bottom: 24),
          child: _LoginCanvas(
            formKey: _formKey,
            usernameController: _usernameController,
            passwordController: _passwordController,
            rememberLogin: _rememberLogin,
            obscurePassword: _obscurePassword,
            authError: _authError,
            onRememberChanged: (value) {
              setState(() => _rememberLogin = value ?? false);
            },
            onTogglePassword: () {
              setState(() => _obscurePassword = !_obscurePassword);
            },
            onForgotPassword: () => showPreviewMessage(
              context,
              'Quên mật khẩu sẽ được triển khai sau; demo không gửi email thật.',
            ),
            onSubmit: _submit,
          ),
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
  final ValueChanged<bool?> onRememberChanged;
  final VoidCallback onTogglePassword;
  final VoidCallback onForgotPassword;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _LoginHero(),
        Transform.translate(
          offset: const Offset(0, -48),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _LoginCard(
              formKey: formKey,
              usernameController: usernameController,
              passwordController: passwordController,
              rememberLogin: rememberLogin,
              obscurePassword: obscurePassword,
              authError: authError,
              onRememberChanged: onRememberChanged,
              onTogglePassword: onTogglePassword,
              onForgotPassword: onForgotPassword,
              onSubmit: onSubmit,
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
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
      child: const _LoginVectorIcon(
        kind: _LoginIconKind.graduation,
        color: AppColors.primary,
        size: 25,
      ),
    );
  }
}

enum _LoginIconKind { graduation, mail, lock, eye, eyeOff, arrow }

/// Login-only vector icons avoid a hard dependency on the browser's loaded
/// MaterialIcons font. The dashboards continue using the shared Material icon
/// configuration from the app theme.
class _LoginVectorIcon extends StatelessWidget {
  const _LoginVectorIcon({
    required this.kind,
    required this.color,
    required this.size,
  });

  final _LoginIconKind kind;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _LoginVectorPainter(kind: kind, color: color),
    );
  }
}

class _LoginVectorPainter extends CustomPainter {
  const _LoginVectorPainter({required this.kind, required this.color});

  final _LoginIconKind kind;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.5, size.width * 0.085)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final width = size.width;
    final height = size.height;

    switch (kind) {
      case _LoginIconKind.graduation:
        final cap = Path()
          ..moveTo(width * .08, height * .38)
          ..lineTo(width * .5, height * .14)
          ..lineTo(width * .92, height * .38)
          ..lineTo(width * .5, height * .62)
          ..close();
        canvas.drawPath(cap, stroke);
        canvas.drawLine(
          Offset(width * .25, height * .5),
          Offset(width * .25, height * .76),
          stroke,
        );
        canvas.drawArc(
          Rect.fromLTWH(width * .25, height * .5, width * .5, height * .34),
          0,
          math.pi,
          false,
          stroke,
        );
        canvas.drawLine(
          Offset(width * .9, height * .38),
          Offset(width * .9, height * .73),
          stroke,
        );
        canvas.drawCircle(
          Offset(width * .9, height * .81),
          math.max(1, width * .045),
          Paint()..color = color,
        );
      case _LoginIconKind.mail:
        final rect = RRect.fromRectAndRadius(
          Rect.fromLTWH(width * .08, height * .18, width * .84, height * .64),
          Radius.circular(width * .08),
        );
        canvas.drawRRect(rect, stroke);
        canvas.drawLine(
          Offset(width * .12, height * .25),
          Offset(width * .5, height * .54),
          stroke,
        );
        canvas.drawLine(
          Offset(width * .88, height * .25),
          Offset(width * .5, height * .54),
          stroke,
        );
      case _LoginIconKind.lock:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(width * .18, height * .42, width * .64, height * .46),
            Radius.circular(width * .08),
          ),
          stroke,
        );
        canvas.drawArc(
          Rect.fromLTWH(width * .3, height * .08, width * .4, height * .58),
          math.pi,
          math.pi,
          false,
          stroke,
        );
      case _LoginIconKind.eye:
      case _LoginIconKind.eyeOff:
        final eye = Path()
          ..moveTo(width * .08, height * .5)
          ..quadraticBezierTo(
            width * .5,
            height * .04,
            width * .92,
            height * .5,
          )
          ..quadraticBezierTo(
            width * .5,
            height * .96,
            width * .08,
            height * .5,
          );
        canvas.drawPath(eye, stroke);
        canvas.drawCircle(
          Offset(width * .5, height * .5),
          width * .13,
          stroke,
        );
        if (kind == _LoginIconKind.eyeOff) {
          canvas.drawLine(
            Offset(width * .12, height * .12),
            Offset(width * .88, height * .88),
            stroke,
          );
        }
      case _LoginIconKind.arrow:
        canvas.drawLine(
          Offset(width * .12, height * .5),
          Offset(width * .86, height * .5),
          stroke,
        );
        canvas.drawLine(
          Offset(width * .58, height * .2),
          Offset(width * .88, height * .5),
          stroke,
        );
        canvas.drawLine(
          Offset(width * .58, height * .8),
          Offset(width * .88, height * .5),
          stroke,
        );
    }
  }

  @override
  bool shouldRepaint(covariant _LoginVectorPainter oldDelegate) {
    return oldDelegate.kind != kind || oldDelegate.color != color;
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
              _FieldLabel(label: 'Email hoặc mã người dùng'),
              const SizedBox(height: 6),
              TextFormField(
                key: const ValueKey('login-username'),
                controller: usernameController,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  hintText: 'Nhập email hoặc mã sinh viên',
                  prefixIcon: Padding(
                    padding: EdgeInsets.all(14),
                    child: _LoginVectorIcon(
                      kind: _LoginIconKind.mail,
                      color: AppColors.mutedText,
                      size: 20,
                    ),
                  ),
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
                  prefixIcon: const Padding(
                    padding: EdgeInsets.all(14),
                    child: _LoginVectorIcon(
                      kind: _LoginIconKind.lock,
                      color: AppColors.mutedText,
                      size: 20,
                    ),
                  ),
                  suffixIcon: IconButton(
                    key: const ValueKey('login-toggle-password'),
                    tooltip: obscurePassword ? 'Hiện mật khẩu' : 'Ẩn mật khẩu',
                    onPressed: onTogglePassword,
                    icon: _LoginVectorIcon(
                      kind: obscurePassword
                          ? _LoginIconKind.eyeOff
                          : _LoginIconKind.eye,
                      color: AppColors.mutedText,
                      size: 21,
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
                      style: TextStyle(
                        color: AppColors.mutedText,
                        fontSize: 11,
                      ),
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
                  onPressed: onSubmit,
                  icon: const _LoginVectorIcon(
                    kind: _LoginIconKind.arrow,
                    color: Colors.white,
                    size: 19,
                  ),
                  label: const Text('Đăng nhập'),
                ),
              ),
              const SizedBox(height: 11),
              const Center(
                child: Text(
                  'DEMO-ONLY • sv001 / gv001 / admin001 • demo123',
                  textAlign: TextAlign.center,
                  style: TextStyle(
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
