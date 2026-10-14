import 'package:app_base/register.dart';

class LoggerBindingImpl implements LoggerBinding {
  @override
  void log({required String name, required String message, LogLevel level = LogLevel.info, Object? error, StackTrace? stackTrace}) {
    debugPrint('[$name][${level.name.toUpperCase()}] $message');
    if (error != null) {
      debugPrint('Error: $error');
    }
    if (stackTrace != null) {
      debugPrint('StackTrace: $stackTrace');
    }
  }
}
