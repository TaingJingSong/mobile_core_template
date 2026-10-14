import 'package:flutter/material.dart';

/// Base class for the app's navigator keys. Subclass in the app
/// and add a key per shell branch. Always exactly one [root].
///
/// Example (in the app):
/// ```dart
/// class AppNavigatorKeys extends NavigatorKeys {
///   AppNavigatorKeys() : super();
///
///   final homeNavigatorKey = GlobalKey<NavigatorState>();
///   final requestNavigatorKey = GlobalKey<NavigatorState>();
///   final payrollNavigatorKey = GlobalKey<NavigatorState>();
///   final settingNavigatorKey = GlobalKey<NavigatorState>();
/// }
/// ```
abstract class NavigatorKeys {
  /// The root navigator used by GoRouter.
  final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

  /// Shell branch keys, in display order.
  /// Subclasses return their own keys here.
  List<GlobalKey<NavigatorState>> get branchKeys => const [];
}
