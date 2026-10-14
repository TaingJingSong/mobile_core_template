enum Environment { dev, qas, pre, prod }

/// Configuration per build flavor / environment.
class FlavorConfig {
  FlavorConfig._();

  static Environment _environment = Environment.dev;

  static void setEnvironment(Environment env) {
    _environment = env;
  }

  static Environment get environment => _environment;
  static String get name => _environment.name;

  static bool get isDev => _environment == Environment.dev;
  static bool get isProd => _environment == Environment.prod;

  static String get baseUrl {
    switch (_environment) {
      case Environment.dev:
        return 'https://dev-api.example.com';
      case Environment.qas:
        return 'https://qas-api.example.com';
      case Environment.pre:
        return 'https://pre-api.example.com';
      case Environment.prod:
        return 'https://api.example.com';
    }
  }
}
