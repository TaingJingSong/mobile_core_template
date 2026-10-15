import 'dart:io';

import 'package:app_base/register.dart';
import 'main_app.dart';

Future<void> main() async {
  await bootstrap(
    env: Environment.dev,
    providers: appProviders,
    app: const MyApp(),
    tasks: [
      BootstrapTask(() async => FirebaseService.initializeFirebase(), name: 'firebase'),
      BootstrapTask(() async {
        HttpOverrides.global = _DevHttpOverrides();
      }, name: 'http_overrides'),
    ],
  );
}

class _DevHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final client = super.createHttpClient(context);
    client.connectionTimeout = const Duration(seconds: 5);
    return client;
  }
}
