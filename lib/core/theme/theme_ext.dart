import 'package:flutter/material.dart';

/// ════════════════════════════════════════════════════════════
/// APP COLORS EXTENSION
/// ════════════════════════════════════════════════════════════
/// Contract every app must implement so core widgets can read
/// brand colors from Theme.of(context).
///
/// The app creates a subclass in `configs/theme/app_theme_ext.dart`
/// with its own fields and registers it in the ThemeData.
abstract class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  const AppColorsExtension();

  Color get primary;
  Color get onPrimary;
  Color get secondary;
  Color get surface;
  Color get background;
  Color get error;
  Color get success;
  Color get warning;
}

/// Convenience accessor. Use inside core widgets:
/// ```dart
/// final colors = context.appColors;
/// Container(color: colors.primary, ...)
/// ```
extension AppColorsX on BuildContext {
  AppColorsExtension get appColors => Theme.of(this).extension<AppColorsExtension>()!;
}
