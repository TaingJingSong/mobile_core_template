import 'package:app_base/register.dart';
import 'main_app.dart';

Future<void> main() async {
  await bootstrap(
    env: Environment.prod,
    providers: appProviders,
    app: const MyApp(),
    tasks: [BootstrapTask(() async => FirebaseService.initializeFirebase(), name: 'firebase')],
  );
}
