import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../data/singletons/fcm_token_singleton.dart';
import '../app_configs/flavor/flavor_config.dart';
import 'crashlytics_service.dart';
import 'notification_service.dart';

/// Facade for Firebase services including Core, Crashlytics, and Messaging.
class FirebaseService {
  FirebaseService._();

  static bool _initialized = false;
  static bool get isInitialized => _initialized;

  /// Optional hook to provide custom [FirebaseOptions] per flavor (e.g., from flutterfire configure).
  static FirebaseOptions? Function()? optionsProvider;

  /// Returns the underlying [FirebaseMessaging] instance.
  static FirebaseMessaging get messaging => NotificationService.messaging;

  /// Returns the underlying [FirebaseCrashlytics] instance.
  static FirebaseCrashlytics get crashlytics => CrashlyticsService.instance;

  /// Returns the [FlutterLocalNotificationsPlugin] instance.
  static FlutterLocalNotificationsPlugin get localNotifications => NotificationService.localNotifications;

  /// Current FCM token stored in [FCMTokenSingleton].
  static String? get fcmToken => FCMTokenSingleton.instance.fcmToken;

  /// Current APNs token stored in [FCMTokenSingleton].
  static String? get apnsToken => FCMTokenSingleton.instance.apnsToken;

  /// Backwards-compatible alias for initializing Firebase per flavor.
  static Future<void> initializeFirebase({FirebaseOptions? options, bool enableCrashlytics = true, bool enableNotifications = true}) async {
    await initialize(options: options, enableCrashlytics: enableCrashlytics, enableNotifications: enableNotifications);
  }

  /// Initialize Firebase Core, Crashlytics, and Push Notifications.
  ///
  /// If [options] is not supplied, it falls back to [optionsProvider]?.call() or
  /// native platform configuration (google-services.json / GoogleService-Info.plist).
  static Future<void> initialize({FirebaseOptions? options, bool enableCrashlytics = true, bool enableNotifications = true}) async {
    final flavor = FlavorConfig.getFlavorType;
    debugPrint('[Firebase] Initializing for flavor "$flavor"...');

    try {
      final resolvedOptions = options ?? optionsProvider?.call();

      if (resolvedOptions != null) {
        await Firebase.initializeApp(options: resolvedOptions);
      } else {
        // Uses native google-services.json (Android) or GoogleService-Info.plist (iOS)
        await Firebase.initializeApp();
      }

      _initialized = true;
      debugPrint('[Firebase] Core initialized successfully');

      // Initialize Crashlytics
      if (enableCrashlytics) {
        await CrashlyticsService.initialize();
      }

      // Initialize FCM & Local Notifications
      if (enableNotifications) {
        await NotificationService.initialize();
      }

      debugPrint('[Firebase] All services initialized successfully for flavor "$flavor"');
    } catch (e, stack) {
      debugPrint(
        '⚠️ [Firebase] Initialization failed: $e\n'
        'Ensure google-services.json (Android) and GoogleService-Info.plist (iOS) are properly placed.\n$stack',
      );
    }
  }

  /// Subscribe to an FCM topic.
  static Future<void> subscribeToTopic(String topic) => NotificationService.subscribeToTopic(topic);

  /// Unsubscribe from an FCM topic.
  static Future<void> unsubscribeFromTopic(String topic) => NotificationService.unsubscribeFromTopic(topic);
}
