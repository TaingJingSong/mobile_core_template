import 'package:flutter/material.dart';

/// ════════════════════════════════════════════════════════════
/// CORE THEME
/// ════════════════════════════════════════════════════════════
/// Builds a theme from a seed color. The app passes its own
/// extension (AppColors) so core widgets get brand colors.
class CoreTheme {
  const CoreTheme._();

  static ThemeData build({required Color seed, required ThemeExtension<dynamic> colorsExtension, Brightness brightness = Brightness.light}) {
    final scheme = ColorScheme.fromSeed(seedColor: seed, brightness: brightness);

    return ThemeData(useMaterial3: true, colorScheme: scheme, scaffoldBackgroundColor: scheme.surface, fontFamily: 'Roboto', extensions: [colorsExtension]);
  }
}
