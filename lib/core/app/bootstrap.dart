import 'package:app_base/register.dart';

/// ════════════════════════════════════════════════════════════
/// BOOTSTRAP TASK
/// ════════════════════════════════════════════════════════════
/// A single startup task. Run in order after DI registration.
class BootstrapTask {
  const BootstrapTask(this.run, {this.name = 'task'});
  final FutureOr<void> Function() run;
  final String name;
}

/// ════════════════════════════════════════════════════════════
/// BOOTSTRAP
/// ════════════════════════════════════════════════════════════
/// Shared startup for every flavor. Called from main_*.dart.
///
/// Responsibilities (in order):
///   1. Bind Flutter
///   2. Register core DI
///   3. Set flavor
///   4. Register app DI
///   5. Run flavor-specific tasks
///   6. Launch the app
Future<void> bootstrap({
  required Environment env,
  required List<SingleChildWidget> providers,
  required Widget app,
  List<BootstrapTask> tasks = const [],
}) async {
  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      // 1. DI — core infrastructure first
      await registerCore();

      // 2. Set flavor
      FlavorConfig.setEnvironment(env);

      // 3. DI — app level registrations
      await registerApp();

      // 4. Flavor tasks (Firebase, biometrics, HttpOverrides, etc.)
      for (final task in tasks) {
        await task.run();
      }

      // Debug sanity check: log tasks that were executed
      assert(() {
        final names = tasks.map((t) => t.name).toList();
        debugPrint('🚀 Bootstrap completed for ${env.name} with tasks: $names');
        return true;
      }());

      // 5. Launch app
      runApp(MultiProvider(providers: providers, child: app));
    },
    (error, stackTrace) {
      // Try to hide any active loader if it was already registered.
      try {
        locator<LoaderBinding>().hide();
      } catch (_) {
        // DI may have failed before registration; ignore.
      }
      debugPrint('logging Error: $error');
      debugPrint('logging StackTrace: $stackTrace');
    },
  );
}
