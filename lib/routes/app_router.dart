import 'package:app_base/register.dart';

/// Navigation observer that logs route transitions using [LoggerBinding].
class AppNavigatorObserver extends NavigatorObserver {
  final LoggerBinding _logger;

  AppNavigatorObserver({LoggerBinding? logger})
      : _logger = logger ?? locator<LoggerBinding>();

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _log('PUSH', '➡️', previousRoute?.settings.name, route.settings.name);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _log('POP', '⬅️', route.settings.name, previousRoute?.settings.name);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    _log('REPLACE', '🔄', oldRoute?.settings.name, newRoute?.settings.name);
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _log('REMOVE', '❌', route.settings.name, previousRoute?.settings.name);
  }

  void _log(String action, String icon, String? from, String? to) {
    _logger.log(
      name: 'Navigation',
      message: '$icon $action: ${from ?? '[Root]'} ➔ ${to ?? '[None]'}',
    );
  }
}

/// Central routing configuration.
/// Register feature screens here or extend with custom route generators.
class AppRouter {
  AppRouter._();

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static final AppNavigatorObserver observer = AppNavigatorObserver();

  /// Map route names to widgets.
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.initial:
      case Routes.home:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const Scaffold(
            body: Center(child: Text('Home View')),
          ),
        );
      default:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Not Found')),
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
