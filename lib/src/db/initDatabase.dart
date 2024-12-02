part of cozy_data;

/// A utility class for initializing and managing database connections.
///
/// This class provides functionality to initialize different types of SQLite databases
/// with support for both regular SQLite and SQLite3 engines.
///
/// Example usage:
/// ```dart
/// final db = await InitDatabase.getDb(
///   mappers: [UserMapper(), PostMapper()],
///   engine: CozyEngine.sqlite,
///   path: 'path/to/db'
/// );
/// ```
///
/// [getDb] Parameters:
/// * [mappers] - List of class mappers that define the database schema and object mapping
/// * [engine] - Database engine type (sqlite, sqlite3, or memory). Defaults to sqlite
/// * [shouldDropTableIfExistsButNoInit] - Whether to drop existing tables if they exist but aren't initialized
/// * [showLogs] - Enable/disable database operation logging. Defaults to false
/// * [path] - Base path where the database file will be created
///
/// Returns a [Future<Db>] that resolves to either:
/// - [Sqlite3DB] instance for sqlite3 or memory engine
/// - [Sqlite] instance for regular sqlite engine
///
/// The database file will be created as:
/// - 'cozy_sqlite3.db' for sqlite3 engine
/// - 'cozy_sqlite.db' for sqlite engine
/// - In-memory database for memory engine
class InitDatabase {
  static Future<Db> getDb(
      {required List<ClassMapperBase> mappers,
      CozyEngine engine = CozyEngine.sqlite,
      bool shouldDropTableIfExistsButNoInit = false,
      bool showLogs = false,
      required String path}) async {
    try {
      if (engine == CozyEngine.sqlite3 || engine == CozyEngine.memory) {
        final db = engine == CozyEngine.sqlite3
            ? sqlite3.sqlite3.open('$path/cozy_sqlite3.db')
            : sqlite3.sqlite3.openInMemory();
        return Sqlite3DB(
            db: db,
            mappers: mappers,
            showLogs: showLogs,
            shouldDropTableIfExistsButNoInit: shouldDropTableIfExistsButNoInit);
      } else {
        final db =
            await sqflite.openDatabase('$path/cozy_sqlite.db', version: 1);
        return Sqlite(
            db: db,
            mappers: mappers,
            showLogs: showLogs,
            shouldDropTableIfExistsButNoInit: shouldDropTableIfExistsButNoInit);
      }
    } catch (e) {
      throw Exception('Error initializing database: $e');
    }
  }
}
