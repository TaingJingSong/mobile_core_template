import 'package:app_base/register.dart';

import 'integrations.dart';

class BootstrapTask {
  const BootstrapTask(this.run, {this.name = 'task'});
  final FutureOr<void> Function() run;
  final String name;
}

/// Application composition, intentionally outside the reusable core.
Future<void> bootstrap({required Environment env, required List<SingleChildWidget> providers, required Widget app, List<BootstrapTask> tasks = const []}) async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await registerCore();
    FlavorConfig.setEnvironment(env);
    await registerApp();
    await initializeIntegrations();
    for (final task in tasks) {
      await task.run();
    }
    runApp(MultiProvider(providers: providers, child: app));
  } catch (error, stack) {
    // Keep a visible screen even when error reporting itself fails.
    runApp(const StartupFailureApp());
    FlutterError.reportError(FlutterErrorDetails(exception: error, stack: stack, library: 'application startup'));
  }
}

class StartupFailureApp extends StatelessWidget {
  const StartupFailureApp({super.key});

  @override
  Widget build(BuildContext context) => const MaterialApp(
    home: Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text('Unable to start the app. Please close it and try again.', textAlign: TextAlign.center),
        ),
      ),
    ),
  );
}
