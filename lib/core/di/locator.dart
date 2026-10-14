import 'package:get_it/get_it.dart';

/// Global service locator.
/// Imported by register_core, register_app, and feature modules.
final GetIt locator = GetIt.instance;

/// Convenience accessor — same as `locator.call<T>()`.
T locate<T extends Object>() => locator<T>();

/// Reset the locator. Only used in tests.
Future<void> resetLocator() async {
  await locator.reset();
}
