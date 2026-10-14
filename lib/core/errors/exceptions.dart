class AppException implements Exception {
  const AppException(this.message);
  final String message;
  @override
  String toString() => '$runtimeType: $message';
}

class ServerException extends AppException {
  const ServerException(super.message, {this.statusCode});
  final int? statusCode;
}

class CacheException extends AppException {
  const CacheException(super.message);
}

class ParseException extends AppException {
  const ParseException(super.message);
}
