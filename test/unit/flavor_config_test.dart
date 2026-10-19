import 'package:app_base/configs/app_configs/flavor/flavor_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('offline startup needs no API credentials', () {
    for (final env in Environment.values) {
      expect(valuesFor(env).name, env.name);
      FlavorConfig.validateApiUrl('', production: env == Environment.prod);
    }
  });

  test('rejects placeholders, credentials, and insecure production URLs', () {
    for (final value in ['not a URL', 'https://api.example.com', 'http://api.acme.com', 'https://user:pass@api.acme.com', 'https://api.acme.com?token=secret']) {
      expect(() => FlavorConfig.validateApiUrl(value, production: true), throwsArgumentError);
    }
    FlavorConfig.validateApiUrl('https://api.acme.com', production: true);
    FlavorConfig.validateApiUrl('http://localhost:8000', production: false);
  });
}
