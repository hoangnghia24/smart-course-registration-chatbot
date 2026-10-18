import 'package:flutter/material.dart';

abstract final class AppColors {
  static const primary = Color(0xFF0D47A1);
  static const background = Color(0xFFF5F7FA);
  static const text = Color(0xFF243143);
  static const mutedText = Color(0xFF68788D);
  static const border = Color(0xFFEDF1F5);
  static const blueSoft = Color(0xFFE6F0FF);
  static const green = Color(0xFF138F66);
  static const greenSoft = Color(0xFFE3F8EC);
  static const purple = Color(0xFF7450C4);
  static const purpleSoft = Color(0xFFF0EBFF);
  static const amber = Color(0xFFB57817);
  static const amberSoft = Color(0xFFFFF0D7);
}

ThemeData buildAppTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    brightness: Brightness.light,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme.copyWith(
      primary: AppColors.primary,
      surface: AppColors.background,
    ),
    scaffoldBackgroundColor: AppColors.background,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
    ),
    cardTheme: const CardThemeData(
      color: Colors.white,
      elevation: 0,
      margin: EdgeInsets.zero,
    ),
    navigationBarTheme: NavigationBarThemeData(
      height: 68,
      backgroundColor: Colors.white,
      indicatorColor: AppColors.blueSoft,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final color = states.contains(WidgetState.selected)
            ? AppColors.primary
            : AppColors.mutedText;
        return TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: states.contains(WidgetState.selected)
              ? FontWeight.w700
              : FontWeight.w500,
        );
      }),
    ),
  );
}
