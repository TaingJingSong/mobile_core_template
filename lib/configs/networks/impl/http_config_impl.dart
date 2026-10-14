import 'package:app_base/register.dart';

class HttpConfigImpl extends HttpConfig {
  const HttpConfigImpl() : super(baseUrl: AppConfig.baseUrl, customBaseUrl: '${AppConfig.baseUrl}/custom');
}
