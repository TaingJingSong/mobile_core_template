import 'package:dio/dio.dart';

import 'exceptions.dart';
import 'failure.dart';

class ErrorHandler {
  static Failure map(Object error) {
    if (error is Failure) return error;

    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return const TimeoutFailure();
        case DioExceptionType.connectionError:
          return const NetworkFailure();
        case DioExceptionType.badResponse:
          final code = error.response?.statusCode ?? 0;
          if (code == 401) return const UnauthorizedFailure();
          if (code >= 500) {
            return ServerFailure('Server error ($code)', statusCode: code);
          }
          final data = error.response?.data;
          String msg = 'Request failed';
          if (data is Map && data['message'] != null) {
            msg = data['message'].toString();
          }
          return ServerFailure(msg, statusCode: code);
        default:
          return const UnknownFailure();
      }
    }

    if (error is AppException) {
      return ServerFailure(error.message);
    }

    return UnknownFailure(error.toString());
  }
}
