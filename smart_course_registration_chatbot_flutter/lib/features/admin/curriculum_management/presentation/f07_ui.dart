import 'package:flutter/material.dart';
import '../domain/managed_curriculum.dart';

abstract final class F07Ui {
  static const primary = Color(0xFF0D47A1);
  static const background = Color(0xFFF5F7FA);
  static const ink = Color(0xFF27354A);
  static const muted = Color(0xFF7183A0);
  static const outline = Color(0xFFD6E3F8);
  static const paleBlue = Color(0xFFE7EFFD);
  static const green = Color(0xFF0A8A5B);
  static const paleGreen = Color(0xFFE1F6EA);
}

class F07Panel extends StatelessWidget {
  const F07Panel({super.key, required this.child, this.padding = const EdgeInsets.all(16)});
  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) => Container(
    padding: padding,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: F07Ui.outline),
    ),
    child: Material(type: MaterialType.transparency, child: child),
  );
}

class F07VersionPill extends StatelessWidget {
  const F07VersionPill({super.key, required this.status});
  final F07VersionStatus status;

  @override
  Widget build(BuildContext context) {
    final isPublished = status == F07VersionStatus.published;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: isPublished ? F07Ui.paleGreen : F07Ui.paleBlue,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Text(status.label, style: TextStyle(
        color: isPublished ? F07Ui.green : F07Ui.primary,
        fontWeight: FontWeight.w700, fontSize: 12,
      )),
    );
  }
}

class F07SectionTitle extends StatelessWidget {
  const F07SectionTitle({super.key, required this.title, this.trailing});
  final String title;
  final String? trailing;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(child: Text(title, style: const TextStyle(
        fontSize: 20, fontWeight: FontWeight.w800, color: F07Ui.ink,
      ))),
      if (trailing != null) Text(trailing!, style: const TextStyle(color: F07Ui.muted)),
    ],
  );
}
