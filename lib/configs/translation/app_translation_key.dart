import 'package:app_base/register.dart';

export '../../core/translation/core_translation_key.dart' show CoreTranslationKey;

/// App-specific translation keys extending [CoreTranslationKey].
abstract class TranslationKey extends CoreTranslationKey {
  const TranslationKey();

  // App-specific keys:
  static const appName = 'app_name';
  static const welcome = 'welcome';
  static const login = 'login';
  static const logout = 'logout';
  static const username = 'username';
  static const password = 'password';
  static const profile = 'profile';
  static const settings = 'settings';
}
