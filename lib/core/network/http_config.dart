/// Values the network impl needs to build the client.
/// The app provides this — core just reads it.
class HttpConfig {
  const HttpConfig({
    required this.baseUrl,
    required this.customBaseUrl,
    this.connectTimeout = const Duration(seconds: 30),
    this.receiveTimeout = const Duration(seconds: 30),
    this.sendTimeout = const Duration(seconds: 30),
    this.maxRetries = 3,
    this.retryDelay = const Duration(seconds: 2),
  });

  final String baseUrl;
  final String customBaseUrl;
  final Duration connectTimeout;
  final Duration receiveTimeout;
  final Duration sendTimeout;
  final int maxRetries;
  final Duration retryDelay;
}
