/// A utility class for logging messages with different levels of severity.
///
/// This class provides a wrapper around the [Logger] package with customized output
/// and formatting. It includes methods for logging at different levels: error, info,
/// debug, verbose, warning, wtf (what a terrible failure), fatal, and trace.
///
/// The logger is configured with:
/// * Custom console output through [DeveloperConsoleOutput]
/// * Pretty printing with timestamps and emojis
/// * A default tag prefix "cozy_data" for all log messages
///
/// Example usage:
/// ```dart
/// // Error logging
/// AppLog.e("Failed to load user data");
///
/// // Info logging
/// AppLog.i("User successfully logged in");
///
/// // Debug logging
/// AppLog.d("Current user state: $userState");
///
/// // Verbose logging
/// AppLog.v("Entering authentication flow");
///
/// // Warning logging
/// AppLog.w("API rate limit approaching");
///
/// // WTF (What a Terrible Failure) logging
/// AppLog.wtf("Critical system failure");
///
/// // Fatal error logging
/// AppLog.f("Unrecoverable error occurred");
///
/// // Trace logging
/// AppLog.t("Method execution trace");
/// ```
///
/// The [DeveloperConsoleOutput] class is a custom implementation of [LogOutput]
/// that formats log messages for the dart developer console.
///
/// Key Features:
/// * Consistent log formatting
/// * Multiple log levels for different severity
/// * Timestamp inclusion in logs
/// * Emoji support for better visibility
/// * Method stack trace for error tracking
/// * Console-friendly output formatting
///
/// Note: This logger is configured to show:
/// * 0 method calls for normal logs
/// * 8 method calls for error logs
/// * Line length of 120 characters
/// * Colored output (when supported)
/// * Timestamps
/// * Emojis for better visual distinction
library;

import 'package:logger/logger.dart';
import 'dart:developer';

class DeveloperConsoleOutput extends LogOutput {
  @override
  void output(OutputEvent event) {
    final StringBuffer buffer = StringBuffer();
    event.lines.forEach(buffer.writeln);
    log(buffer.toString());
  }
}

class AppLog {
  static const String _DEFAULT_TAG_PREFIX = "cozy_data";
  static final _logger = Logger(
    output: MultiOutput([
      DeveloperConsoleOutput(),
    ]),
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
  );

  static e(String msg) {
    _logger.e("$_DEFAULT_TAG_PREFIX: $msg");
  }

  /// Log a message at level [Level.info].
  static i(String msg) {
    _logger.i("$_DEFAULT_TAG_PREFIX: $msg");
  }

  /// Log a message at level [Level.debug].
  static d(String msg) {
    _logger.d("$_DEFAULT_TAG_PREFIX: $msg");
  }

  /// Log a message at level [Level.verbose].
  static v(String msg) {
    _logger.v("$_DEFAULT_TAG_PREFIX: $msg");
  }

  /// Log a message at level [Level.warning].
  static w(String msg) {
    _logger.w("$_DEFAULT_TAG_PREFIX: $msg");
  }

  /// Log a message at level [Level.wtf].
  static wtf(String msg) {
    _logger.wtf("$_DEFAULT_TAG_PREFIX: $msg");
  }

  /// Log a message at level [Level.fatal].
  static f(String msg) {
    _logger.f("$_DEFAULT_TAG_PREFIX: $msg");
  }

  /// Log a message at level [Level.trace].
  static t(String msg) {
    _logger.t("$_DEFAULT_TAG_PREFIX: $msg");
  }
}
