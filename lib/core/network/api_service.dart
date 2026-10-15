import 'dart:async';
import 'package:dio/dio.dart' show Headers;

/// Which failures should trigger the error UI.
enum ErrorDisplayCondition { always, unauthorizedOnly, never }

/// Contract for the app's HTTP client.
abstract interface class BaseApiService {
  Future<CustomResponse<dynamic>> getResponse(
    String url, {
    bool enabledRetry = false,
    bool isDebug = false,
    Map<String, dynamic>? query,
    String? customUrl,
    bool isShowMsg = true,
    bool customValidate = false,
    ErrorDisplayCondition? errorDisplayCondition,
  });

  Future<StreamResponse> getStreamResponse(
    String url, {
    bool enabledRetry = false,
    bool isDebug = false,
    Map<String, dynamic>? query,
    String? customUrl,
    bool isShowMsg = true,
    bool customValidate = false,
    ErrorDisplayCondition? errorDisplayCondition,
  });

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
  });

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
  });

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
  });
}

class StreamResponse {
  const StreamResponse({required this.statusCode, required this.stream, required this.headers});

  final int statusCode;
  final Stream<List<int>> stream;
  final Headers headers;

  int? get contentLength => int.tryParse(headers.value(Headers.contentLengthHeader) ?? '');

  String? get fileName {
    final disposition = headers.value('content-disposition');
    if (disposition == null || disposition.isEmpty) return null;

    final utf8Match = RegExp(r'''filename\*=UTF-8''([^;]+)''', caseSensitive: false).firstMatch(disposition);
    if (utf8Match != null) {
      return Uri.decodeComponent(utf8Match.group(1)!.trim());
    }

    return RegExp(r'''filename="?([^";]+)"?''', caseSensitive: false).firstMatch(disposition)?.group(1)?.trim();
  }
}

class CustomResponse<T> {
  final int statusCode;
  final T data;

  CustomResponse({required this.statusCode, required this.data});

  CustomResponse<T> copyWith({int? statusCode, T? data}) => CustomResponse<T>(statusCode: statusCode ?? this.statusCode, data: data ?? this.data);

  factory CustomResponse.fromJson(Map<String, dynamic> json) => CustomResponse<T>(statusCode: (json["statusCode"] as num?)?.toInt() ?? 0, data: json["data"] as T);

  Map<String, dynamic> toJson() => {"statusCode": statusCode, "data": data};
}
