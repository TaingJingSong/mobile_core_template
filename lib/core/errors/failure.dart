sealed class Failure {
  const Failure(this.message);
  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection']);
}

class TimeoutFailure extends Failure {
  const TimeoutFailure([super.message = 'Request timed out']);
}

class ServerFailure extends Failure {
  const ServerFailure(super.message, {this.statusCode});
  final int? statusCode;
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([super.message = 'Session expired']);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message, {this.fieldErrors = const {}});
  final Map<String, String> fieldErrors;
}

class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'Something went wrong']);
}
