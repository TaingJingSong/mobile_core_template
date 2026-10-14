import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:retry/retry.dart';
import 'package:app_base/register.dart';

class NetworkApiService implements BaseApiService {
  NetworkApiService({required this.httpConfig, required this.headerProvider, required this.interceptorProvider, required this.logger, required this.loader}) {
    _dio = Dio(BaseOptions(connectTimeout: httpConfig.connectTimeout, receiveTimeout: httpConfig.receiveTimeout, sendTimeout: httpConfig.sendTimeout));
    _dio.interceptors.addAll(interceptorProvider.build(_dio));
    _retryOptions = RetryOptions(maxAttempts: httpConfig.maxRetries, delayFactor: httpConfig.retryDelay);
  }

  final HttpConfig httpConfig;
  final HeaderProvider headerProvider;
  final InterceptorProvider interceptorProvider;
  final LoggerBinding logger;
  final LoaderBinding loader;

  late final Dio _dio;
  late final RetryOptions _retryOptions;

  String get _baseUrl => httpConfig.baseUrl;
  String get _baseCustomUrl => httpConfig.customBaseUrl;

  bool _retryIf(Object e) {
    if (e is DioException) {
      return e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.receiveTimeout || e.type == DioExceptionType.sendTimeout || e.type == DioExceptionType.connectionError;
    }
    return false;
  }

  String _resolveUrl(String url, String? customUrl) => customUrl == null ? '$_baseCustomUrl/$url' : '$_baseUrl/$customUrl';

  Future<Map<String, dynamic>> _headers({bool isFormData = false}) => headerProvider.build(isFormData: isFormData);

  @override
  Future<CustomResponse> getResponse(String url, {bool enabledRetry = false, bool isDebug = false, Map<String, dynamic>? query, String? customUrl, bool isShowMsg = true, bool customValidate = false, ErrorDisplayCondition? errorDisplayCondition}) async {
    final requestUrl = _resolveUrl(url, customUrl);
    if (isDebug) {
      logger.log(name: 'NetworkApiService', message: 'GET $requestUrl');
    }

    Future<Response> request() async => _dio.get(
      requestUrl,
      options: Options(headers: await _headers(), extra: {'customValidate': customValidate, 'isShowMsg': isShowMsg, 'showErrorWhen': errorDisplayCondition}, validateStatus: (_) => true),
      queryParameters: query,
    );

    final response = enabledRetry ? await _retryOptions.retry(request, retryIf: _retryIf) : await request();

    return _returnResponse(response, isDebug);
  }

  @override
  Future<StreamResponse> getStreamResponse(String url, {bool enabledRetry = false, bool isDebug = false, Map<String, dynamic>? query, String? customUrl, bool isShowMsg = true, bool customValidate = false, ErrorDisplayCondition? errorDisplayCondition}) async {
    final requestUrl = _resolveUrl(url, customUrl);
    if (isDebug && kDebugMode) {
      logger.log(name: 'NetworkApiService', message: 'STREAM GET $requestUrl');
    }

    Future<Response<ResponseBody>> request() async => _dio.get<ResponseBody>(
      requestUrl,
      options: Options(headers: await _headers(), responseType: ResponseType.stream, extra: {'customValidate': customValidate, 'isShowMsg': isShowMsg, 'showErrorWhen': errorDisplayCondition}, validateStatus: (_) => true),
      queryParameters: query,
    );

    final response = enabledRetry ? await _retryOptions.retry(request, retryIf: _retryIf) : await request();

    final body = response.data;
    if (body == null) {
      throw StateError('The download response did not contain a stream.');
    }

    return StreamResponse(statusCode: response.statusCode ?? 0, stream: body.stream, headers: response.headers);
  }

  @override
  Future<CustomResponse> postResponse(String url, dynamic jsonBody, {bool enabledRetry = false, bool isDebug = false, dynamic query, String? customUrl, bool isShowMsg = true, bool customValidate = false, ErrorDisplayCondition? errorDisplayCondition}) async {
    final requestUrl = _resolveUrl(url, customUrl);
    if (isDebug) {
      logger.log(name: 'NetworkApiService', message: 'POST $requestUrl');
    }

    final response = await _dio.post(
      requestUrl,
      data: jsonBody,
      options: Options(
        headers: await _headers(isFormData: jsonBody is FormData),
        extra: {'customValidate': customValidate, 'isShowMsg': isShowMsg, 'showErrorWhen': errorDisplayCondition},
        validateStatus: (_) => true,
      ),
      queryParameters: query,
    );

    return _returnResponse(response, isDebug);
  }

  @override
  Future<CustomResponse> putResponse(String url, dynamic jsonBody, {bool enabledRetry = false, bool isDebug = false, dynamic query, String? customUrl, bool isShowMsg = true, bool customValidate = false, ErrorDisplayCondition? errorDisplayCondition}) async {
    final requestUrl = _resolveUrl(url, customUrl);
    if (isDebug) {
      logger.log(name: 'NetworkApiService', message: 'PUT $requestUrl');
    }

    final response = await _dio.put(
      requestUrl,
      data: jsonBody,
      options: Options(
        headers: await _headers(isFormData: jsonBody is FormData),
        extra: {'customValidate': customValidate, 'isShowMsg': isShowMsg, 'showErrorWhen': errorDisplayCondition},
        validateStatus: (_) => true,
      ),
      queryParameters: query,
    );

    return _returnResponse(response, isDebug);
  }

  @override
  Future<CustomResponse> deleteResponse(String url, dynamic jsonBody, {bool enabledRetry = false, bool isDebug = false, dynamic query, String? customUrl, bool isShowMsg = true, bool customValidate = false, ErrorDisplayCondition? errorDisplayCondition}) async {
    final requestUrl = _resolveUrl(url, customUrl);
    if (isDebug) {
      logger.log(name: 'NetworkApiService', message: 'DELETE $requestUrl');
    }

    final response = await _dio.delete(
      requestUrl,
      data: jsonBody,
      options: Options(
        headers: await _headers(isFormData: jsonBody is FormData),
        extra: {'customValidate': customValidate, 'isShowMsg': isShowMsg, 'showErrorWhen': errorDisplayCondition},
        validateStatus: (_) => true,
      ),
      queryParameters: query,
    );

    return _returnResponse(response, isDebug);
  }

  CustomResponse _returnResponse(Response<dynamic> response, bool isDebug) {
    if (isDebug && kDebugMode) {
      logger.log(name: 'NetworkApiService', message: 'Response ${response.statusCode}');
    }

    loader.hide();

    return CustomResponse(data: response.data, statusCode: response.statusCode ?? 400);
  }
}
