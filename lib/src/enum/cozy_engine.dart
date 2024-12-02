part of cozy_data;

/// A type of storage engine supported by Cozy persistence library.
///
/// The available storage engines are:
/// * [sqlite] - Default SQLite engine implementation for Flutter/Dart
/// * [sqlite3] - SQLite3 implementation with additional features and performance
/// * [memory] - In-memory storage engine for temporary data and testing
///
/// Example usage:
/// ```dart
/// // Initialize storage with SQLite engine
/// final storage = CozyData.initialize(engine: CozyEngine.sqlite);
///
/// // Use in-memory storage for testing
/// final testStorage = CozyData.initialize(engine: CozyEngine.memory);
///
/// // Use SQLite3 for advanced features
/// final advancedStorage = CozyData.initialize(engine: CozyEngine.sqlite3);
/// ```
///
/// The engine type affects:
/// - Storage persistence
/// - Query performance
/// - Available features
/// - Platform compatibility
///
/// Choose the appropriate engine based on your application needs:
/// - Use [sqlite] for general purpose storage
/// - Use [sqlite3] for advanced SQLite features
/// - Use [memory] for temporary storage or testing
/// {@category Enums}
enum CozyEngine {
  sqlite,
  sqlite3,
  memory,
}
