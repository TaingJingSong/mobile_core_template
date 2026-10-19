import 'package:app_base/register.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('network setup preserves the default TLS client', () {
    final dio = Dio();
    final adapter = dio.httpClientAdapter as IOHttpClientAdapter;
    NetworkApiService(
      httpConfig: const HttpConfig(baseUrl: 'https://api.acme.com', customBaseUrl: 'https://api.acme.com/custom'),
      headerProvider: HeaderProviderImpl(),
      interceptorProvider: InterceptorProviderImpl(),
      logger: LoggerBindingImpl(),
      loader: GlobalOverlayLoaderBinding(),
      dio: dio,
    );
    expect(adapter.createHttpClient, isNull);
    dio.close();
  });
}
