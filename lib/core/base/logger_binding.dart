enum LogLevel { debug, info, warn, error }

abstract interface class LoggerBinding {
  void log({
    required String name,
    required String message,
    LogLevel level = LogLevel.info,
    Object? error,
    StackTrace? stackTrace,
  });
}