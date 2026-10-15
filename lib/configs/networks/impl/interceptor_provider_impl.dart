import 'package:app_base/register.dart';
import 'package:dio/dio.dart';

class InterceptorProviderImpl implements InterceptorProvider {
  @override
  List<Interceptor> build(Dio dio) => [];
}
