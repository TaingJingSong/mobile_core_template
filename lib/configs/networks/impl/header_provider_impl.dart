import 'package:app_base/register.dart';

class HeaderProviderImpl implements HeaderProvider {
  @override
  Future<Map<String, dynamic>> build({bool isFormData = false}) async {
    // In actual implementation, fetch token from SecureStorage
    return {
      'Charset': 'utf-8',
      'Accept': 'application/json',
      if (!isFormData) 'Content-Type': 'application/json',
      'Accept-Language': AppConfig.defaultLocale,
      'X-Client-Source': 'mobile',
    };
  }
}
