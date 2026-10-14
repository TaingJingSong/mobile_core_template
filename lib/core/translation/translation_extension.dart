/// ════════════════════════════════════════════════════════════
/// TRANSLATION EXTENSION
/// ════════════════════════════════════════════════════════════
/// Translation extension on [String] for localized strings.
/// Supports both plain `.tr` and parameterized `.trParams()`.
typedef TranslationResolver = String Function(String key, {Map<String, String>? params});

class TranslationConfig {
  static TranslationResolver? resolver;
}

extension TranslationX on String {
  String get tr => trParams();

  String trParams({Map<String, String>? params}) {
    if (TranslationConfig.resolver != null) {
      return TranslationConfig.resolver!(this, params: params);
    }
    String result = this;
    if (params != null) {
      params.forEach((key, val) {
        result = result.replaceAll('{$key}', val);
      });
    }
    return result;
  }
}
