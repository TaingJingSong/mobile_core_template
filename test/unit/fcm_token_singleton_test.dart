import 'package:app_base/register.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FCMTokenSingleton', () {
    tearDown(() {
      FCMTokenSingleton.instance.clear();
    });

    test('initial values should be null', () {
      expect(FCMTokenSingleton.instance.fcmToken, isNull);
      expect(FCMTokenSingleton.instance.apnsToken, isNull);
    });

    test('should update fcmToken and notify listeners', () {
      var notified = false;
      FCMTokenSingleton.instance.addListener(() {
        notified = true;
      });

      FCMTokenSingleton.instance.fcmToken = 'sample_fcm_token';
      expect(FCMTokenSingleton.instance.fcmToken, 'sample_fcm_token');
      expect(notified, isTrue);
    });

    test('should update apnsToken and notify listeners', () {
      var notified = false;
      FCMTokenSingleton.instance.addListener(() {
        notified = true;
      });

      FCMTokenSingleton.instance.apnsToken = 'sample_apns_token';
      expect(FCMTokenSingleton.instance.apnsToken, 'sample_apns_token');
      expect(notified, isTrue);
    });

    test('FCMTokenStn alias refers to the same singleton instance', () {
      FCMTokenStn.instance.fcmToken = 'alias_token';
      expect(FCMTokenSingleton.instance.fcmToken, 'alias_token');
    });

    test('clear should reset tokens and notify listeners', () {
      FCMTokenSingleton.instance.fcmToken = 'token_to_clear';
      var notified = false;
      FCMTokenSingleton.instance.addListener(() {
        notified = true;
      });

      FCMTokenSingleton.instance.clear();
      expect(FCMTokenSingleton.instance.fcmToken, isNull);
      expect(FCMTokenSingleton.instance.apnsToken, isNull);
      expect(notified, isTrue);
    });
  });
}
