import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:app_base/register.dart';

class NetworkInfoImpl implements NetworkInfo {
  final InternetConnection _internetConnection = InternetConnection();

  @override
  Future<bool> get isConnected => _internetConnection.hasInternetAccess;

  @override
  Stream<InternetStatus> get onStatusChange => _internetConnection.onStatusChange;
}
