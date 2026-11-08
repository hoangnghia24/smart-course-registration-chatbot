import 'package:flutter/material.dart';

/// Bộ màu/thành phần dùng trong F06, đối chiếu 3 SVG Admin do nhóm cung cấp.
/// KHÔNG định nghĩa header riêng: mọi màn F06 dùng SharedAppHeader.academic.
abstract final class F06Ui {
  static const navy = Color(0xFF0D47A1);
  static const background = Color(0xFFF5F7FA);
  static const ink = Color(0xFF27354A);
  static const secondary = Color(0xFF7084A2);
  static const outline = Color(0xFFD6E3F8);
  static const paleBlue = Color(0xFFE8F0FF);
  static const green = Color(0xFF008E60);
  static const paleGreen = Color(0xFFE0F6EB);
  static const amber = Color(0xFFAD7200);
  static const paleAmber = Color(0xFFFFF0D8);
}

class F06StatusPill extends StatelessWidget {
  const F06StatusPill({super.key, required this.active});
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
      decoration: BoxDecoration(
        color: active ? F06Ui.paleGreen : F06Ui.paleAmber,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Text(
        active ? 'Đang hoạt động' : 'Tạm ẩn',
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 12,
          color: active ? F06Ui.green : F06Ui.amber,
        ),
      ),
    );
  }
}

class F06Panel extends StatelessWidget {
  const F06Panel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });
  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15),
      side: const BorderSide(color: F06Ui.outline),
    ),
    clipBehavior: Clip.antiAlias,
    child: Padding(
      padding: padding,
      child: child,
    ),
  );
}

class F06SectionHeading extends StatelessWidget {
  const F06SectionHeading({super.key, required this.title, this.subtitle});
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: F06Ui.ink,
        ),
      ),
      if (subtitle != null) ...[
        const SizedBox(height: 3),
        Text(
          subtitle!,
          style: const TextStyle(fontSize: 13, color: F06Ui.secondary),
        ),
      ],
    ],
  );
}

class F06ReadonlyNote extends StatelessWidget {
  const F06ReadonlyNote({
    super.key,
    required this.title,
    required this.description,
  });
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: F06Ui.paleBlue.withValues(alpha: 0.65),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: F06Ui.navy,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: const TextStyle(color: F06Ui.secondary, fontSize: 12),
        ),
      ],
    ),
  );
}
