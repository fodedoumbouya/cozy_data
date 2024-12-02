part of cozy_data;

/// A utility class for generating unique identifiers in a Cozy application.
///
/// This class provides static fields for generating both string and integer-based
/// unique identifiers that can be used for persistent data models.
///
/// Example usage:
/// ```dart
/// // Get a UUID string identifier
/// String modelId = CozyId.cozyPersistentModelIDString();
/// "123e4567-e89b-12d3-a456-426614174000" (example UUID)
///
/// // Get a timestamp-based integer identifier
/// int timeId = CozyId.cozyPersistentModelIDInt();
/// 1634567890123 (current timestamp in milliseconds)
/// ```
///
/// The class offers two types of IDs:
/// * [cozyPersistentModelIDString]: A UUID v4 string that provides a globally unique identifier
/// * [cozyPersistentModelIDInt]: A timestamp-based integer for time-sensitive unique identification
///
/// Note: The integer ID is based on system time and should be used with caution
/// when absolute uniqueness is required across different devices or time zones.
class CozyId {
  static final CozyId _instance = CozyId._();
  factory CozyId() => _instance;
  CozyId._();

  /// Generates a UUID v4 string identifier for a persistent model.
  static String cozyPersistentModelIDString() => const Uuid().v4();

  /// Generates a timestamp-based integer identifier for a persistent model.
  static int cozyPersistentModelIDInt() =>
      DateTime.now().millisecondsSinceEpoch;
}
