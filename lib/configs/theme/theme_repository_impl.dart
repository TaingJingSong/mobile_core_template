import 'package:app_base/register.dart';

class ThemeRepositoryImpl implements ThemeRepository {
  bool _isDark = false;

  @override
  Future<bool> isDarkMode() async {
    return _isDark;
  }

  @override
  Future<void> setDarkMode(bool value) async {
    _isDark = value;
  }
}
