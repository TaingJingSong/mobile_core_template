import 'package:flutter/material.dart';

/// ════════════════════════════════════════════════════════════
/// CORE COLORS
/// ════════════════════════════════════════════════════════════
/// Semantic colors every app uses. App-specific brand colors
/// live in the app's own AppColor class (configs/theme/).
abstract class CoreColors {
  const CoreColors._();

  // Semantic
  static const Color error = Color(0xFFFF3B30);
  static const Color success = Color(0xFF24C759);
  static const Color warning = Color(0xFFFF9500);
  static const Color info = Color(0xFF007AFF);

  // Neutral
  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);
  static const Color grey = Color(0xFF888888);
  static const Color disabled = Color(0xFFB0B0B0);

  // Surfaces
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFF6F6F6);
  static const Color divider = Color(0xFFE0E0E0);
}
