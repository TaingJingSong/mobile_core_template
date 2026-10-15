import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../data/singletons/fcm_token_singleton.dart';
import '../../routes/app_router.dart';

/// Top-level background message handler required by Firebase Messaging.
/// Must be annotated with [pragma('vm:entry-point')] so it isn't tree-shaken.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
  } catch (_) {
    // If Firebase is already initialized or options are pre-configured.
  }
  debugPrint('[Notification] Handled background message: ${message.messageId}');
}

/// Service managing Push Notifications (FCM) and Local Notifications.
class NotificationService {
  NotificationService._();

  static final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  static const String androidChannelId = 'high_importance_channel';
  static const String androidChannelName = 'High Importance Notifications';
  static const String androidChannelDescription = 'This channel is used for important push notifications.';

  /// Optional callback invoked when the user taps any notification (FCM or local).
  static void Function(Map<String, dynamic> data)? onNotificationTapped;

  /// Optional callback invoked when FCM token is refreshed.
  static void Function(String token)? onTokenRefreshed;

  /// Returns the singleton [FirebaseMessaging] instance.
  static FirebaseMessaging get messaging => FirebaseMessaging.instance;

  /// Returns the singleton [FlutterLocalNotificationsPlugin] instance.
  static FlutterLocalNotificationsPlugin get localNotifications => _localNotifications;

  /// Initialize Firebase Messaging, Local Notifications, permissions, and handlers.
  static Future<void> initialize() async {
    try {
      // 1. Initialize local notifications
      await _initializeLocalNotifications();

      // 2. Request FCM permissions & configure presentation
      await _initializeFirebaseMessaging();

      // 3. Register message listeners
      _setupMessageHandlers();

      // 4. Register token refresh listener
      _setupTokenRefresh();

      // 5. Check if app was opened from a terminated state via a notification tap
      final initialMessage = await messaging.getInitialMessage();
      if (initialMessage != null) {
        debugPrint('[Notification] App launched from terminated state via message: ${initialMessage.messageId}');
        _handleNotificationData(initialMessage.data);
      }

      debugPrint('[Notification] Initialized successfully');
    } catch (e, stack) {
      debugPrint('[Notification] Initialization failed: $e\n$stack');
    }
  }

  /// Initialize the local notifications plugin and Android notification channel.
  static Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: false, // Managed by FirebaseMessaging.requestPermission()
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initializationSettings = InitializationSettings(android: androidSettings, iOS: darwinSettings);

    await _localNotifications.initialize(settings: initializationSettings, onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse);

    if (!kIsWeb && Platform.isAndroid) {
      const channel = AndroidNotificationChannel(androidChannelId, androidChannelName, description: androidChannelDescription, importance: Importance.high);

      await _localNotifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);
    }
  }

  /// Request permissions and capture initial FCM & APNs tokens.
  static Future<void> _initializeFirebaseMessaging() async {
    final settings = await messaging.requestPermission(alert: true, announcement: false, badge: true, carPlay: false, criticalAlert: false, provisional: false, sound: true);

    debugPrint('[Notification] Permission status: ${settings.authorizationStatus}');

    // Allow iOS to show alert banners in the foreground natively
    if (!kIsWeb && Platform.isIOS) {
      await messaging.setForegroundNotificationPresentationOptions(alert: true, badge: true, sound: true);

      try {
        final apnsToken = await messaging.getAPNSToken();
        FCMTokenSingleton.instance.apnsToken = apnsToken;
        debugPrint('[Notification] APNs Token: $apnsToken');
      } catch (e) {
        debugPrint('[Notification] Failed to get APNs token: $e');
      }
    }

    try {
      final fcmToken = await messaging.getToken();
      FCMTokenSingleton.instance.fcmToken = fcmToken;
      debugPrint('[Notification] FCM Token: $fcmToken');
    } catch (e) {
      debugPrint('[Notification] Failed to retrieve FCM token: $e');
    }
  }

  /// Register foreground, background, and tap event listeners.
  static void _setupMessageHandlers() {
    // Top-level background message handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Foreground message handler
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('[Notification] Received foreground message: ${message.messageId}');
      _showForegroundNotification(message);
    });

    // Background notification tap handler (app in background)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('[Notification] Message clicked from background: ${message.messageId}');
      _handleNotificationData(message.data);
    });
  }

  /// Show a system tray notification when the app is in foreground.
  static Future<void> _showForegroundNotification(RemoteMessage message) async {
    // On iOS, foreground banners are already displayed natively via setForegroundNotificationPresentationOptions
    if (!kIsWeb && Platform.isIOS) return;

    final title = message.notification?.title ?? (message.data['title'] as String?);
    final body = message.notification?.body ?? (message.data['body'] as String?);

    if (title == null && body == null) return;

    final notificationId = int.tryParse(message.data['id']?.toString() ?? '') ?? message.messageId.hashCode;

    const androidDetails = AndroidNotificationDetails(
      androidChannelId,
      androidChannelName,
      channelDescription: androidChannelDescription,
      icon: '@mipmap/ic_launcher',
      importance: Importance.high,
      priority: Priority.high,
    );

    const details = NotificationDetails(android: androidDetails, iOS: DarwinNotificationDetails());

    await _localNotifications.show(id: notificationId, title: title, body: body, notificationDetails: details, payload: jsonEncode(message.data));
  }

  /// Handles taps on local notifications.
  static void _onDidReceiveNotificationResponse(NotificationResponse response) {
    if (response.payload != null && response.payload!.isNotEmpty) {
      try {
        final data = jsonDecode(response.payload!) as Map<String, dynamic>;
        _handleNotificationData(data);
      } catch (e) {
        debugPrint('[Notification] Failed to parse local notification payload: $e');
      }
    }
  }

  /// Dispatch notification data to custom callbacks or default router.
  static void _handleNotificationData(Map<String, dynamic> data) {
    debugPrint('[Notification] Handling payload: $data');
    if (onNotificationTapped != null) {
      onNotificationTapped!(data);
      return;
    }

    final route = data['route'] as String?;
    if (route != null && route.isNotEmpty) {
      AppRouter.navigatorKey.currentState?.pushNamed(route, arguments: data['arguments'] ?? data);
    }
  }

  /// Listen for FCM token refreshes and notify subscribers.
  static void _setupTokenRefresh() {
    messaging.onTokenRefresh.listen((String token) async {
      debugPrint('[Notification] FCM token refreshed: $token');
      FCMTokenSingleton.instance.fcmToken = token;

      if (!kIsWeb && Platform.isIOS) {
        final apnsToken = await messaging.getAPNSToken();
        FCMTokenSingleton.instance.apnsToken = apnsToken;
      }

      onTokenRefreshed?.call(token);
    });
  }

  /// Subscribe device to a topic.
  static Future<void> subscribeToTopic(String topic) async {
    await messaging.subscribeToTopic(topic);
    debugPrint('[Notification] Subscribed to topic: $topic');
  }

  /// Unsubscribe device from a topic.
  static Future<void> unsubscribeFromTopic(String topic) async {
    await messaging.unsubscribeFromTopic(topic);
    debugPrint('[Notification] Unsubscribed from topic: $topic');
  }
}
