import 'package:app_base/register.dart';
import 'main_app.dart';

void main() async {
  FlavorConfig.setEnvironment(Environment.prod);
  await bootstrap();
  runApp(const MyApp());
}
