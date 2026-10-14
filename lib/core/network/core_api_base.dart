import 'package:app_base/register.dart';

/// Base class for grouped endpoints. Each concrete API defines a
/// prefix (`apiPrefix`) and whether it targets the custom base URL
/// (`isCustom`).
abstract class CoreAPIBase {
  CoreAPIBase(this.apiService);

  final BaseApiService apiService;

  /// Route prefix, e.g. `wb/attendance`.
  String get apiPrefix;

  /// When true, requests go to the custom base URL
  /// (e.g. the "talentedge" host).
  bool get isCustom;

  // Helpers so feature classes don't repeat the prefix.
  Future<CustomResponse> get(String path, {Map<String, dynamic>? query, bool enabledRetry = false, bool isDebug = false, bool isShowMsg = true}) =>
      apiService.getResponse('$apiPrefix/$path', query: query, enabledRetry: enabledRetry, isDebug: isDebug, isShowMsg: isShowMsg, customUrl: isCustom ? path : null);

  Future<CustomResponse> post(String path, dynamic body, {Map<String, dynamic>? query, bool enabledRetry = false, bool isDebug = false, bool isShowMsg = true}) =>
      apiService.postResponse('$apiPrefix/$path', body, query: query, enabledRetry: enabledRetry, isDebug: isDebug, isShowMsg: isShowMsg, customUrl: isCustom ? path : null);

  Future<CustomResponse> put(String path, dynamic body, {Map<String, dynamic>? query, bool enabledRetry = false, bool isDebug = false, bool isShowMsg = true}) =>
      apiService.putResponse('$apiPrefix/$path', body, query: query, enabledRetry: enabledRetry, isDebug: isDebug, isShowMsg: isShowMsg, customUrl: isCustom ? path : null);

  Future<CustomResponse> delete(String path, dynamic body, {Map<String, dynamic>? query, bool enabledRetry = false, bool isDebug = false, bool isShowMsg = true}) =>
      apiService.deleteResponse('$apiPrefix/$path', body, query: query, enabledRetry: enabledRetry, isDebug: isDebug, isShowMsg: isShowMsg, customUrl: isCustom ? path : null);

  Future<StreamResponse> getStream(String path, {Map<String, dynamic>? query, bool enabledRetry = false, bool isDebug = false, bool isShowMsg = true}) =>
      apiService.getStreamResponse('$apiPrefix/$path', query: query, enabledRetry: enabledRetry, isDebug: isDebug, isShowMsg: isShowMsg, customUrl: isCustom ? path : null);
}
