import 'package:app_base/register.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('startup failure screen is usable without providers or services', (tester) async {
    await tester.pumpWidget(const StartupFailureApp());
    expect(find.text('Unable to start the app. Please close it and try again.'), findsOneWidget);
  });

  testWidgets('a failed startup task reports the error and shows the fallback', (tester) async {
    await locator.reset();
    addTearDown(() => locator.reset());
    final original = FlutterError.onError;
    FlutterErrorDetails? reported;
    FlutterError.onError = (details) => reported = details;
    try {
      await bootstrap(env: Environment.dev, providers: const [], app: const SizedBox.shrink(), tasks: [BootstrapTask(() => throw StateError('startup failed'))]);
      await tester.pumpAndSettle();
      expect(reported?.exception, isA<StateError>());
      expect(find.byType(StartupFailureApp), findsOneWidget);
    } finally {
      FlutterError.onError = original;
    }
  });
}
