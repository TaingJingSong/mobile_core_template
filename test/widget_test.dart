import 'package:app_base/main_app.dart';
import 'package:app_base/register.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(() async {
    await registerCore();
    await registerApp();
  });

  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(MultiProvider(providers: appProviders, child: const MyApp()));
    await tester.pumpAndSettle();

    expect(find.text('Home View'), findsOneWidget);
  });
}
