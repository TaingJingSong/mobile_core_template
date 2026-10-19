import 'package:app_base/register.dart';
import 'package:flutter/foundation.dart';

class LoggerBindingImpl implements LoggerBinding {
  @override
  void log({required String name, required String message, LogLevel level = LogLevel.info, Object? error, StackTrace? stackTrace}) {
    if (!kDebugMode) return;
    debugPrint('[$name][${level.name.toUpperCase()}] $message');
    if (error != null) {
      debugPrint('Error: $error');
    }
    if (stackTrace != null) {
      debugPrint('StackTrace: $stackTrace');
    }
  }
}
