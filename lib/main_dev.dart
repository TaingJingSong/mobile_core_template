import 'package:app_base/register.dart';
import 'main_app.dart';

void main() async {
  FlavorConfig.setEnvironment(Environment.dev);
  await bootstrap();
  runApp(const MyApp());
}
