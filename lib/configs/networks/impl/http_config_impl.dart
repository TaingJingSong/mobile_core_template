import 'package:app_base/register.dart';

class HttpConfigImpl extends HttpConfig {
  HttpConfigImpl() : super(baseUrl: _baseUrl(), customBaseUrl: '${_baseUrl()}/custom');

  static String _baseUrl() {
    final url = FlavorConfig.urlByType;
    if (url.isEmpty) {
      throw StateError('Configure --dart-define=API_BASE_URL before using networking.');
    }
    return url;
  }
}
