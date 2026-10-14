/// ════════════════════════════════════════════════════════════
/// THEME REPOSITORY
/// ════════════════════════════════════════════════════════════
/// Storage contract for saving and retrieving dark mode preference.
abstract interface class ThemeRepository {
  Future<bool> isDarkMode();
  Future<void> setDarkMode(bool value);
}
