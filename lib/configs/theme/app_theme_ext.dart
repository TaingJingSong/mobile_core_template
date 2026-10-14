import 'package:app_base/register.dart';

class AppColors extends AppColorsExtension {
  const AppColors();

  @override
  Color get primary => AppColor.primaryColor;
  @override
  Color get onPrimary => AppColor.whiteColor;
  @override
  Color get secondary => AppColor.secondaryColor;
  @override
  Color get surface => AppColor.lightGrey;
  @override
  Color get background => AppColor.backgroundColor;
  @override
  Color get error => AppColor.error;
  @override
  Color get success => AppColor.sucess;
  @override
  Color get warning => AppColor.warningColor;

  @override
  AppColorsExtension copyWith({Color? primary, Color? onPrimary, Color? secondary, Color? surface, Color? background, Color? error, Color? success, Color? warning}) {
    return this;
  }

  @override
  AppColorsExtension lerp(AppColorsExtension? other, double t) {
    if (other is! AppColors) return this;
    return const AppColors();
  }
}
