part of cozy_data;

/// Utility class providing common functionality for persistent data operations
///
/// This class contains static utilities and constants used across the persistent
/// data framework. It provides:
/// * Standard identifier field name for persistent models
/// * Configurable logging functionality with error handling
class Utils {
  /// Default identifier field used for persistent model entities
  ///
  /// This constant defines the standard field name 'id' that should be used
  /// as the primary identifier in persistent data models
  static String persistentModelID = 'id';

  /// Logs messages with configurable visibility and error status
  ///
  /// Parameters:
  /// * [showLogs] - Boolean flag to control if logging is enabled
  /// * [msg] - The message content to be logged
  /// * [isError] - Optional flag to indicate if this is an error message
  ///   (defaults to false)
  ///
  /// Uses [AppLog] internally to handle the actual logging:
  /// * Error messages use AppLog.e()
  /// * Regular messages use AppLog.t()
  static void log(
      {required bool showLogs, required String msg, bool isError = false}) {
    if (!showLogs) {
      return;
    }
    if (isError) {
      AppLog.e(msg);
    } else {
      AppLog.t(msg);
    }
  }
}
