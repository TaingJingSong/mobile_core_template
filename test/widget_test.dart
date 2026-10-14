import 'package:flutter_test/flutter_test.dart';
import 'package:app_base/register.dart';
import 'package:app_base/main_app.dart';

void main() {
  setUpAll(() async {
    await registerCore();
    await registerApp();
  });

  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Home View'), findsOneWidget);
  });
}
