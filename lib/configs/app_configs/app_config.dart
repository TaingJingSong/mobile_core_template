/// ### App Config — Edit Per Project
/// 
/// This is the first file you touch when starting a new app.
/// Keep it dumb: constants only, no logic, no imports.
class AppConfig {
  AppConfig._();

  // Identity
  static const String appName = 'My App';
  static const String packageName = 'com.example.myapp';
  static const String version = '1.0.0';
  static const String buildNumber = '1';

  // API
  static const String baseUrl = 'https://api.example.com';
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  // Locale
  static const String defaultLocale = 'en';
  static const List<String> supportedLocales = ['en', 'km'];
  static const String fallbackLocale = 'en';

  // Storage keys
  static const String keyAccessToken = 'access_token';
  static const String keyRefreshToken = 'refresh_token';
  static const String keyLocale = 'locale';
  static const String keyThemeMode = 'theme_mode';

  // Feature flags
  static const bool enableAnalytics = true;
  static const bool enableCrashlytics = true;
  static const bool enableChatbot = false;
  static const bool enableBiometric = true;
  static const bool enableDeepLink = true;

  // Pagination
  static const int defaultPageSize = 20;

  // Debug
  static const bool logNetwork = true;
  static const bool logNavigation = true;
}