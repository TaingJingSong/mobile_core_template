import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import '../network/network_info.dart';

mixin NetworkAwareMixin on ChangeNotifier {
  NetworkInfo? _networkInfo;
  StreamSubscription<InternetStatus>? _networkSub;
  bool _isOffline = false;
  bool _networkDisposed = false;

  bool get isOffline => _isOffline;

  Future<void> setupNetwork({required NetworkInfo networkInfo, bool autoReloadOnReconnect = false}) async {
    _networkInfo = networkInfo;

    final connected = await _networkInfo!.isConnected;
    if (_networkDisposed) return;

    _setOffline(!connected);

    _networkSub = _networkInfo!.onStatusChange.listen((status) async {
      if (status == InternetStatus.disconnected) {
        _setOffline(true);
      }

      if (status == InternetStatus.connected && _isOffline) {
        _setOffline(false);

        if (autoReloadOnReconnect) {
          await onReload();
        }
      }
    });
  }

  void _setOffline(bool value) {
    if (_isOffline == value) return;
    _isOffline = value;
    notifyListeners();
  }

  /// Override to reload after reconnection.
  Future<void> onReload() async {}

  @mustCallSuper
  void onNetworkDispose() {
    _networkDisposed = true;
    _networkSub?.cancel();
    _networkSub = null;
  }
}
