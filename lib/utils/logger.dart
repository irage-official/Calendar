import 'dart:developer' as developer;

class AppLogger {
  static const String _tag = 'IranianHeritageCalendar';

  /// Log info message
  static void info(String message, {String? tag}) {
    developer.log(
      message,
      name: tag ?? _tag,
      level: 800, // Info level
    );
  }

  /// Log error message
  static void error(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    developer.log(
      message,
      name: tag ?? _tag,
      level: 1000, // Error level
      error: error,
      stackTrace: stackTrace,
    );
  }
}
