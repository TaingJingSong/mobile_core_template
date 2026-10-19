import 'flavor_values.dart';

enum Environment { dev, qas, pre, prod }

FlavorValues valuesFor(Environment env) => FlavorValues(name: env.name, url: const String.fromEnvironment('API_BASE_URL'));

class FlavorConfig {
  FlavorConfig._();

  static Environment _env = Environment.dev;
  static FlavorValues _values = valuesFor(Environment.dev);

  static void setEnvironment(Environment env) {
    _env = env;
    _values = valuesFor(env);
    validateApiUrl(_values.url, production: env == Environment.prod);
  }

  // An empty URL allows the starter to run offline. Configuring an API is explicit.
  static void validateApiUrl(String value, {required bool production}) {
    if (value.isEmpty) return;
    final uri = Uri.tryParse(value);
    if (uri == null ||
        !uri.hasAuthority ||
        uri.host.isEmpty ||
        uri.userInfo.isNotEmpty ||
        uri.hasQuery ||
        uri.hasFragment ||
        !['https', 'http'].contains(uri.scheme) ||
        (production && uri.scheme != 'https') ||
        uri.host == 'example.com' ||
        uri.host.endsWith('.example.com') ||
        uri.host.endsWith('.invalid')) {
      throw ArgumentError('API_BASE_URL must be a real HTTP(S) API URL (HTTPS in production).');
    }
  }

  static Environment get environment => _env;
  static FlavorValues get values => _values;
  static String get flavorType => _values.name;
  static String get urlByType => _values.url;
  static String get getFlavorType => flavorType;
  static String get getUrlFlavorByType => urlByType;
}
