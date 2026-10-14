/// ════════════════════════════════════════════════════════════
/// CORE TRANSLATION KEYS
/// ════════════════════════════════════════════════════════════
/// Strings every app needs. App-specific strings live in the
/// app's TranslationKey (configs/translation/).
abstract class CoreTranslationKey {
  const CoreTranslationKey();

  // Actions
  static const ok = 'ok';
  static const cancel = 'cancel';
  static const confirm = 'confirm';
  static const save = 'save';
  static const delete = 'delete';
  static const edit = 'edit';
  static const close = 'close';
  static const retry = 'retry';
  static const submit = 'submit';
  static const apply = 'apply';
  static const search = 'search';
  static const clear = 'clear';

  // States
  static const loading = 'loading';
  static const noData = 'no_data';
  static const noInternet = 'no_internet';
  static const somethingWentWrong = 'something_went_wrong';
  static const sessionExpired = 'session_expired';
  static const tryAgain = 'try_again';

  // Validation
  static const required = 'required';
  static const invalidEmail = 'invalid_email';
  static const invalidPhone = 'invalid_phone';
  static const minLength = 'min_length';
  static const maxLength = 'max_length';

  // Common labels
  static const yes = 'yes';
  static const no = 'no';
  static const done = 'done';
  static const next = 'next';
  static const back = 'back';
  static const skip = 'skip';
  static const seeMore = 'see_more';
  static const showMore = 'show_more';
  static const showLess = 'show_less';
  static const viewAll = 'view_all';
  static const all = 'all';
}
