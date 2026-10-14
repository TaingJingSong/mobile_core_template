import 'package:app_base/register.dart';

/// Central routing configuration.
/// Register feature screens here or extend with custom route generators.
class AppRouter {
  AppRouter._();

  static GlobalKey<NavigatorState> get navigatorKey => AppNavigatorKeys.instance.rootNavigatorKey;

  static NavigationLogger get observer => NavigationLogger(locator<LoggerBinding>());

  /// Map route names to widgets.
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.initial:
      case Routes.home:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const Scaffold(body: Center(child: Text('Home View'))),
        );
      default:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Not Found')),
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
