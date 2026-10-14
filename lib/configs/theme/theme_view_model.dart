import 'package:app_base/register.dart';

class ThemeViewModel extends CoreViewModel {
  ThemeViewModel(this._repo);
  final ThemeRepository _repo;

  ThemeMode _theme = ThemeMode.light;
  ThemeMode get theme => _theme;

  bool get isDarkMode => _theme == ThemeMode.dark;

  Future<bool> loadTheme() async {
    final isDark = await _repo.isDarkMode();
    _theme = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
    return isDark;
  }

  Future<void> toggleTheme(ThemeMode theme) async {
    _theme = theme;
    notifyListeners();
    await _repo.setDarkMode(theme == ThemeMode.dark);
  }
}
