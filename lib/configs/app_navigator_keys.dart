import 'package:app_base/register.dart';

/// App's navigator keys. One key per shell branch.
class AppNavigatorKeys extends NavigatorKeys {
  AppNavigatorKeys._();
  static final AppNavigatorKeys instance = AppNavigatorKeys._();

  final homeNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'home');
  final requestNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'request');
  final payrollNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'payroll');
  final settingNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'setting');

  @override
  List<GlobalKey<NavigatorState>> get branchKeys => [homeNavigatorKey, requestNavigatorKey, payrollNavigatorKey, settingNavigatorKey];
}
