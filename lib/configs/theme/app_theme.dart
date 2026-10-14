import 'package:app_base/register.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData light() => CoreTheme.build(seed: AppColor.primaryColor, colorsExtension: const AppColors(), brightness: Brightness.light);

  static ThemeData dark() => CoreTheme.build(seed: AppColor.primaryColor, colorsExtension: const AppColors(), brightness: Brightness.dark);

  static ThemeData get lightTheme => light();
  static ThemeData get darkTheme => dark();
}
