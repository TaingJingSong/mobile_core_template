import 'package:app_base/register.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:retry/retry.dart';

/// Concrete HTTP client implementation using Dio.
/// App-level — core only sees [BaseApiService].
class NetworkApiService implements BaseApiService {
  NetworkApiService({required this.httpConfig, required this.headerProvider, required this.interceptorProvider, required this.logger, required this.loader, Dio? dio})
    : _dio = dio ?? Dio(),
      _baseUrl = httpConfig.baseUrl,
      _baseCustomUrl = httpConfig.customBaseUrl {
    _initDio();
  }

  final HttpConfig httpConfig;
  final HeaderProvider headerProvider;
  final InterceptorProvider interceptorProvider;
  final LoggerBinding logger;
  final LoaderBinding loader;

  final Dio _dio;
  final String _baseUrl;
  final String _baseCustomUrl;

  late final RetryOptions _retryOptions = RetryOptions(maxAttempts: httpConfig.maxRetries, delayFactor: httpConfig.retryDelay);

  void _initDio() {
    _dio.options = BaseOptions(baseUrl: _baseUrl, connectTimeout: httpConfig.connectTimeout, receiveTimeout: httpConfig.receiveTimeout, sendTimeout: httpConfig.sendTimeout);

    // Apply interceptors from the app's provider.
    _dio.interceptors.addAll(interceptorProvider.build(_dio));
  }

  String _resolveUrl(String url, String? customUrl) => customUrl == null ? '$_baseCustomUrl/$url' : '$_baseUrl/$customUrl';

  Future<Map<String, dynamic>> _headers({bool isFormData = false}) => headerProvider.build(isFormData: isFormData);

  @override
  Future<CustomResponse<dynamic>> getResponse(
    String url, {
    bool enabledRetry = false,
    bool isDebug = false,
    Map<String, dynamic>? query,
    String? customUrl,
    bool isShowMsg = true,
    bool customValidate = false,
    ErrorDisplayCondition? errorDisplayCondition,
  }) async {
    final requestUrl = _resolveUrl(url, customUrl);
    if (isDebug) {
      logger.log(name: 'NetworkApiService', message: 'GET $requestUrl');
    }

    Future<Response<dynamic>> request() async => _dio.get<dynamic>(
      requestUrl,
      options: Options(headers: await _headers(), extra: {'customValidate': customValidate, 'isShowMsg': isShowMsg, 'showErrorWhen': errorDisplayCondition}, validateStatus: (_) => true),
      queryParameters: query,
    );

    final response = enabledRetry ? await _retryOptions.retry(request, retryIf: _retryIf) : await request();

    return _returnResponse(response, isDebug);
  }

  @override
  Future<StreamResponse> getStreamResponse(
    String url, {
    bool enabledRetry = false,
    bool isDebug = false,
    Map<String, dynamic>? query,
    String? customUrl,
    bool isShowMsg = true,
    bool customValidate = false,
    ErrorDisplayCondition? errorDisplayCondition,
  }) async {
    final requestUrl = _resolveUrl(url, customUrl);
    if (isDebug) {
      logger.log(name: 'NetworkApiService', message: 'GET STREAM $requestUrl');
    }

    Future<Response<ResponseBody>> request() async => _dio.get<ResponseBody>(
      requestUrl,
      options: Options(
        headers: await _headers(),
        responseType: ResponseType.stream,
        extra: {'customValidate': customValidate, 'isShowMsg': isShowMsg, 'showErrorWhen': errorDisplayCondition},
        validateStatus: (_) => true,
      ),
      queryParameters: query,
    );

    final response = enabledRetry ? await _retryOptions.retry(request, retryIf: _retryIf) : await request();

    final body = response.data;
    if (body == null) {
      throw const ServerException('Empty stream response');
    }

    return StreamResponse(statusCode: response.statusCode ?? 0, stream: body.stream, headers: response.headers);
  }

  @override
  Future<CustomResponse<dynamic>> postResponse(
    String url,
    dynamic jsonBody, {
    bool enabledRetry = false,
    bool isDebug = false,
    Map<String, dynamic>? query,
    String? customUrl,
    bool isShowMsg = true,
    bool customValidate = false,
    ErrorDisplayCondition? errorDisplayCondition,
  }) async {
    final requestUrl = _resolveUrl(url, customUrl);
    if (isDebug) {
      logger.log(name: 'NetworkApiService', message: 'POST $requestUrl');
    }

    final response = await _dio.post<dynamic>(
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
  Future<CustomResponse<dynamic>> putResponse(
    String url,
    dynamic jsonBody, {
    bool enabledRetry = false,
    bool isDebug = false,
    Map<String, dynamic>? query,
    String? customUrl,
    bool isShowMsg = true,
    bool customValidate = false,
    ErrorDisplayCondition? errorDisplayCondition,
  }) async {
    final requestUrl = _resolveUrl(url, customUrl);
    if (isDebug) {
      logger.log(name: 'NetworkApiService', message: 'PUT $requestUrl');
    }

    final response = await _dio.put<dynamic>(
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
  Future<CustomResponse<dynamic>> deleteResponse(
    String url,
    dynamic jsonBody, {
    bool enabledRetry = false,
    bool isDebug = false,
    Map<String, dynamic>? query,
    String? customUrl,
    bool isShowMsg = true,
    bool customValidate = false,
    ErrorDisplayCondition? errorDisplayCondition,
  }) async {
    final requestUrl = _resolveUrl(url, customUrl);
    if (isDebug) {
      logger.log(name: 'NetworkApiService', message: 'DELETE $requestUrl');
    }

    final response = await _dio.delete<dynamic>(
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

  CustomResponse<dynamic> _returnResponse(Response<dynamic> response, bool isDebug) {
    if (isDebug && kDebugMode) {
      logger.log(name: 'NetworkApiService', message: 'Response ${response.statusCode}');
    }

    loader.hide();

    return CustomResponse<dynamic>(data: response.data, statusCode: response.statusCode ?? 400);
  }

  bool _retryIf(Exception e) => e is DioException && (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.receiveTimeout);
}
