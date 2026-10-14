import 'package:flutter/material.dart';
import 'app_color.dart';

abstract class AppTheme {
  const AppTheme();

  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColor.scaffoldBackground,
        disabledColor: AppColor.disabled,
        colorScheme: const ColorScheme.light(
          primary: AppColor.primaryColor,
          secondary: AppColor.secondaryColor,
          surface: AppColor.surfaceColor,
          error: AppColor.error,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColor.surfaceColor,
          foregroundColor: AppColor.textPrimary,
          elevation: 0,
          centerTitle: true,
        ),
        dividerTheme: const DividerThemeData(
          color: AppColor.divider,
          thickness: 1,
        ),
      );

  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
        colorScheme: const ColorScheme.dark(
          primary: AppColor.primaryColor,
          secondary: AppColor.secondaryColor,
          surface: Color(0xFF1E1E1E),
          error: AppColor.error,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E1E1E),
          elevation: 0,
          centerTitle: true,
        ),
      );
}
