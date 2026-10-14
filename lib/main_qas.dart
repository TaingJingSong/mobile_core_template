import 'package:app_base/register.dart';
import 'main_app.dart';

Future<void> main() async {
  await bootstrap(
    env: Environment.qas,
    providers: appProviders,
    app: const MyApp(),
    tasks: const [
      // Add QAS startup tasks here
    ],
  );
}
