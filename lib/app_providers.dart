import 'package:app_base/register.dart';

/// ════════════════════════════════════════════════════════════
/// APP PROVIDERS
/// ════════════════════════════════════════════════════════════
/// App-global state that must live for the whole app lifetime.
/// View models DO NOT belong here — create them per-screen with
/// CoreView so they get disposed when the screen closes.
///
/// Rule: if a widget could rebuild with a fresh instance without
/// losing anything important, it doesn't belong here.
List<SingleChildWidget> appProviders = [
  // App-global user session state surviving navigation:
  ChangeNotifierProvider<UserSingleton>.value(value: UserSingleton.instance),

  // App-global theme state surviving navigation:
  ChangeNotifierProvider<ThemeViewModel>(create: (_) => ThemeViewModel(locator<ThemeRepository>())),
];
