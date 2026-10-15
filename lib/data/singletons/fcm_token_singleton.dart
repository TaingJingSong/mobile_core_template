import 'package:flutter/foundation.dart';

/// Singleton holding active push notification tokens (FCM & APNs).
/// Listeners can subscribe to token updates (e.g., to sync with backend).
class FCMTokenSingleton extends ChangeNotifier {
  static final FCMTokenSingleton instance = FCMTokenSingleton._();
  FCMTokenSingleton._();

  String? _fcmToken;
  String? get fcmToken => _fcmToken;
  set fcmToken(String? value) {
    if (_fcmToken != value) {
      _fcmToken = value;
      notifyListeners();
    }
  }

  String? _apnsToken;
  String? get apnsToken => _apnsToken;
  set apnsToken(String? value) {
    if (_apnsToken != value) {
      _apnsToken = value;
      notifyListeners();
    }
  }

  /// Reset tokens upon user logout.
  void clear() {
    _fcmToken = null;
    _apnsToken = null;
    notifyListeners();
  }
}

/// Convenience alias to match legacy and project shorthand syntax.
typedef FCMTokenStn = FCMTokenSingleton;
