import 'package:flutter/widgets.dart';

import '../base/logger_binding.dart';

/// ════════════════════════════════════════════════════════════
/// NAVIGATION LOGGER
/// ════════════════════════════════════════════════════════════
/// Drop into any GoRouter's `observers` list to log pushes,
/// pops, replaces, and removes. Uses [LoggerBinding] so it
/// works without app-level imports.
class NavigationLogger extends NavigatorObserver {
  NavigationLogger(this.logger);
  final LoggerBinding logger;

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
    logger.log(name: 'Navigation', message: '$icon $action: ${from ?? '[Root]'} ➔ ${to ?? '[None]'}');
  }
}
