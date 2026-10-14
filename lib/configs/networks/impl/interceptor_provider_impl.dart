import 'package:dio/dio.dart';
import 'package:app_base/register.dart';

class InterceptorProviderImpl implements InterceptorProvider {
  @override
  List<Interceptor> build(Dio dio) => [];
}
