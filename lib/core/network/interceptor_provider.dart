import 'package:dio/dio.dart';

/// Provides the Dio interceptors for the app.
/// Core never sees the concrete interceptor classes.
abstract interface class InterceptorProvider {
  List<Interceptor> build(Dio dio);
}
