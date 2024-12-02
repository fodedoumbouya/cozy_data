part of cozy_data;

/// A database interface for persistent data operations.
///
/// This abstract class defines the core database operations for storing and
/// manipulating data. It provides a consistent API for different database
/// implementations.
///
/// The [onChangeDB] stream controller broadcasts database change events to listeners.
/// Subscribers can react to database modifications in real-time.
///
/// Example usage:
/// ```dart
/// class MyDatabase implements Db {
///   // Implementation details
/// }
///
/// final db = MyDatabase();
/// db.save<User>(data: {'name': 'John'});
/// ```
/// {@template db_operations}
/// Key operations:
/// * [save] - Persists data to storage
/// * [delete] - Removes records matching criteria
/// * [update] - Modifies existing records
/// * [deleteAll] - Clears all records of a type
/// * [dropTable] - Removes the entire table
/// * [rawQuery] - Executes custom queries
/// {@endtemplate}
///
/// Generic type [T] represents the model/entity type being operated on.
/// This enables type-safe database operations while maintaining flexibility.
final onChangeDB = StreamController<String>.broadcast();

abstract class Db {
  Future<void> save<T>({required Map<String, Object?> data});
  Future<void> delete<T>(
      {required String where, required List<Object?> whereArgs});
  Future<void> update<T>(
      {required String where,
      required List<Object?> whereArgs,
      required Map<String, Object?> data});
  Future<void> deleteAll<T>();
  Future<void> dropTable<T>({String? tableName});
  Future<List<Map<String, dynamic>>> rawQuery<T>(Query query);
}
