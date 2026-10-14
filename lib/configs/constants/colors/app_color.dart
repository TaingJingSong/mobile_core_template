import 'package:flutter/material.dart';

abstract class AppColor {
  const AppColor();

  static const Color primaryColor = Color(0xFF156EA2);
  static const Color secondaryColor = Color(0xFFD99C26);
  static const Color backgroundColor = Color(0xFFFFFFFF);
  static const Color scaffoldBackground = Color(0xFFF9FEFE);
  static const Color surfaceColor = Color(0xFFFFFFFF);

  static const Color textPrimary = Color(0xFF262626);
  static const Color textSecondary = Color(0xFF6D6D6D);
  static const Color textPlaceholder = Color(0xFF616161);

  static const Color success = Color(0xFF24C759);
  static const Color error = Color(0xFFFF3B30);
  static const Color warning = Color(0xFFFF9500);
  static const Color info = Color(0xFF007AFF);

  static const Color divider = Color(0xFFE7E7E7);
  static const Color border = Color(0xFFD1D1D1);
  static const Color disabled = Colors.grey;
}
