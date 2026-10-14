import 'package:app_base/register.dart';
import 'flavor_values.dart';

enum Environment { dev, qas, pre, prod }

FlavorValues valuesFor(Environment env) {
  switch (env) {
    case Environment.dev:
      return const FlavorValues(name: 'dev', url: 'http://192.168.0.178:8000', firebaseRoot: 'Dev', distance: 100000000000);
    case Environment.qas:
      return const FlavorValues(name: 'qas', url: 'https://hris-uat-api.innotechsolution.tech', firebaseRoot: 'Qas', distance: 100000000000);
    case Environment.pre:
      return const FlavorValues(name: 'pre', url: 'http://192.168.0.229:8000', firebaseRoot: 'Pre', distance: 100000000000);
    case Environment.prod:
      return const FlavorValues(name: '', url: 'https://hrms-api.innotechsolution.tech', firebaseRoot: 'Production', distance: 100);
  }
}

class FlavorConfig {
  FlavorConfig._();

  static Environment _env = Environment.dev;
  static FlavorValues _values = valuesFor(Environment.dev);

  static void setEnvironment(Environment env) {
    _env = env;
    _values = valuesFor(env);
    try {
      locator<LoggerBinding>().log(name: 'FLAVOR', message: env.name);
    } catch (_) {
      debugPrint('[FLAVOR] ${env.name}');
    }
  }

  static Environment get environment => _env;
  static FlavorValues get values => _values;

  // Convenience accessors
  static String get flavorType => _values.name;
  static String get urlByType => _values.url;
  static String? get socketUrlByType => _values.socketUrl;
  static String get firebaseRootByType => _values.firebaseRoot;
  static int get distanceByType => _values.distance;

  // Aliases for compatibility
  static String get getFlavorType => flavorType;
  static String get getUrlFlavorByType => urlByType;
  static String? get getSocketUrlFlavorByType => socketUrlByType;
  static String get getFirebaseRootFlavorByType => firebaseRootByType;
  static int get getDistanceFlavorByType => distanceByType;
}
