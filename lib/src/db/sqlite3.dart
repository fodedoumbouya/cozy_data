part of cozy_data;

/// A SQLite database implementation of the [Db] interface.
///
/// This class provides SQLite database operations using the sqlite3 package.
/// It follows the Singleton pattern to ensure only one database instance exists.
///
/// Example usage:
/// ```dart
/// // Initialize database
/// final db = Sqlite3DB(
///   mappers: [UserMapper(), PostMapper()],
///   shouldDropTableIfExistsButNoInit: true,
///   db: sqlite3.open('my_db.db'),
///   showLogs: true
/// );
///
/// // Save data
/// await db.save<User>(data: {'id': '1', 'name': 'John'});
///
/// // Query data
/// final users = await db.rawQuery<User>(
///   Query('SELECT * FROM User WHERE name = ?', ['John'])
/// );
///
/// // Update data
/// await db.update<User>(
///   where: 'id',
///   whereArgs: ['1'],
///   data: {'name': 'John Doe'}
/// );
///
/// // Delete data
/// await db.delete<User>(where: 'id', whereArgs: ['1']);
/// ```
class Sqlite3DB implements Db {
  /// Singleton instance of the database
  /// Private database instance
  /// List of class mappers for object-relational mapping
  /// Flag to determine if tables should be dropped if they exist but aren't initialized
  /// Flag to track if columns exist
  /// Flag to enable/disable logging

  /// Private constructor that initializes the database instance
  /// Creates tables and sets up initial configuration
  /// [mappers] - List of class mappers for object-relational mapping
  /// [db] - SQLite database instance
  /// [shouldDropTableIfExistsButNoInit] - Flag to control table dropping
  /// [showLogs] - Enable/disable logging

  /// Factory constructor that ensures singleton pattern
  /// Returns existing instance or creates new one if none exists
  /// Parameters same as private constructor

  /// Returns a list of all tables in the database
  /// @return List<String> containing table names

  /// Drops tables that exist in database but not in mappers
  /// Used for cleanup when shouldDropTableIfExistsButNoInit is true

  /// Checks if a table exists in the database
  /// @param tableName Name of table to check
  /// @return bool indicating if table exists

  /// Creates a new table in the database
  /// @param table Name of table to create
  /// @param data Map of column names and their data types

  /// Checks if all columns exist in a table and adds missing ones
  /// @param table Name of table to check
  /// @param data Map containing column definitions

  /// Saves data to specified table
  /// Handles JSON encoding for List and Map values
  /// Throws exception if unique constraint violated
  /// @param data Map of column names and values to save

  /// Deletes records matching where clause
  /// @param where Column name for WHERE clause
  /// @param whereArgs Values to match in WHERE clause

  /// Updates records matching where clause
  /// @param where Column name for WHERE clause
  /// @param whereArgs Values to match in WHERE clause
  /// @param data Map of column names and new values

  /// Deletes all records from specified table
  /// Notifies listeners of change

  /// Drops specified table from database
  /// Notifies listeners of change

  /// Executes raw SQL query and returns results
  /// @param query Query object containing SQL and arguments
  /// @return List of maps containing query results

  static Sqlite3DB? _instance;
  final sqlite3.Database _db;
  final List<ClassMapperBase> mappers;
  final bool shouldDropTableIfExistsButNoInit;
  bool _columnExist = false;
  bool _showLogs = false;
  bool _tableInitialized = false;
  final _lock = Lock();

  Sqlite3DB._({
    required this.mappers,
    required sqlite3.Database db,
    required this.shouldDropTableIfExistsButNoInit,
    bool showLogs = false,
  })  : _db = db,
        _showLogs = showLogs {
    if (shouldDropTableIfExistsButNoInit) {
      _dropTableIfNotExistsInMappers();
    }
    checkIfTableNotExistsButExistInMappers();
  }

  factory Sqlite3DB({
    required List<ClassMapperBase> mappers,
    required bool shouldDropTableIfExistsButNoInit,
    required sqlite3.Database db,
    bool showLogs = false,
  }) {
    _instance ??= Sqlite3DB._(
      db: db,
      mappers: mappers,
      shouldDropTableIfExistsButNoInit: shouldDropTableIfExistsButNoInit,
      showLogs: showLogs,
    );
    return _instance!;
  }

  List<String> getTables() {
    final stmt = _db.prepare(
        "SELECT name FROM sqlite_master WHERE type='table' ORDER BY name");
    final results = stmt.select();
    stmt.dispose();
    return results.map((row) => row['name'] as String).toList();
  }

  Future<void> checkIfTableNotExistsButExistInMappers() async {
    await _lock.synchronized(() async {
      final tables = getTables();
      for (var mapper in mappers) {
        if (!tables.contains(mapper.id)) {
          Map<String, Object?> data = {};
          for (var field in mapper.fields.entries) {
            data[field.value.name] = null;
          }
          createTable(table: mapper.id, data: data);
          Utils.log(
              msg: '🥳 Table ${mapper.id} created 🥳', showLogs: _showLogs);
        }
      }
      _tableInitialized = true;
    });
  }

  void _dropTableIfNotExistsInMappers() {
    final tables = getTables();
    for (var table in tables) {
      if (!mappers.any((element) => element.id == table)) {
        _db.execute('DROP TABLE IF EXISTS $table');
        Utils.log(
            msg: 'Table $table dropped because it does not exist in mappers',
            showLogs: _showLogs);
      }
    }
  }

  bool isTableExists(String tableName) {
    try {
      final stmt = _db.prepare(
          "SELECT name FROM sqlite_master WHERE type='table' AND name = ?");
      final result = stmt.select([tableName]);
      stmt.dispose();
      return result.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  void createTable({
    required String table,
    required Map<String, Object?> data,
  }) {
    String createTable = 'CREATE TABLE IF NOT EXISTS $table (';
    createTable += '${Utils.persistentModelID} TEXT PRIMARY KEY,';
    for (var field in data.entries) {
      String name = field.key;
      if (name == Utils.persistentModelID) continue;
      createTable += '$name TEXT,';
    }
    createTable = createTable.substring(0, createTable.length - 1);
    createTable += ')';

    _db.execute(createTable);
  }

  void checkIfAllColumnsExistOrAdd({
    required String table,
    required Map<String, Object?> data,
  }) {
    if (_columnExist) return;

    final stmt = _db.prepare('PRAGMA table_info($table)');
    final columns = stmt.select();
    stmt.dispose();

    final columnNames = columns.map((row) => row['name'] as String).toList();

    for (var field in data.entries) {
      String name = field.key;
      if (name == Utils.persistentModelID) continue;
      if (!columnNames.contains(name)) {
        _db.execute('ALTER TABLE $table ADD COLUMN $name TEXT');
      }
    }
    _columnExist = true;
  }

  @override
  Future<void> save<T>({required Map<String, Object?> data}) async {
    if (!_tableInitialized) {
      await checkIfTableNotExistsButExistInMappers();
    }
    final table = T.toString();
    if (!isTableExists(table)) {
      createTable(table: table, data: data);
    }
    checkIfAllColumnsExistOrAdd(table: table, data: data);

    final fields = data.keys.join(', ');
    final values = List.filled(data.length, '?').join(', ');

    try {
      final stmt = _db.prepare('INSERT INTO $table ($fields) VALUES ($values)');
      final sanitizedValues = data.values
          .map((value) => value is List
              ? jsonEncode(value)
              : value is Map
                  ? jsonEncode(value)
                  : value)
          .toList();
      stmt.execute(sanitizedValues);
      stmt.dispose();
      onChangeDB.add(table);
    } catch (e) {
      if (e.toString().contains('UNIQUE constraint failed')) {
        Utils.log(
            msg:
                'Data already exists in table ${T.toString()} with primary key ${Utils.persistentModelID} = ${data[Utils.persistentModelID]}',
            showLogs: _showLogs,
            isError: true);
        throw Exception(
            'Data already exists in table ${T.toString()} with primary key ${Utils.persistentModelID} = ${data[Utils.persistentModelID]}');
      } else {
        rethrow;
      }
    }
    Utils.log(msg: 'Saved data to $table', showLogs: _showLogs);
  }

  @override
  Future<void> delete<T>(
      {required String where, required List<Object?> whereArgs}) async {
    if (!_tableInitialized) {
      await checkIfTableNotExistsButExistInMappers();
    }
    final table = T.toString();
    final stmt = _db.prepare('DELETE FROM $table WHERE $where = ?');
    stmt.execute(whereArgs);
    stmt.dispose();
    Utils.log(msg: 'Deleted data from $table', showLogs: _showLogs);
    onChangeDB.add(table);
  }

  @override
  Future<void> update<T>(
      {required String where,
      required List<Object?> whereArgs,
      required Map<String, Object?> data}) async {
    if (!_tableInitialized) {
      await checkIfTableNotExistsButExistInMappers();
    }
    final table = T.toString();
    final setClause = data.keys.map((key) => '$key = ?').join(', ');

    final stmt = _db.prepare('UPDATE $table SET $setClause WHERE $where = ?');
    stmt.execute([...data.values, ...whereArgs]);
    stmt.dispose();
    Utils.log(msg: 'Updated data in $table', showLogs: _showLogs);
    onChangeDB.add(table);
  }

  @override
  Future<void> deleteAll<T>() async {
    if (!_tableInitialized) {
      await checkIfTableNotExistsButExistInMappers();
    }
    final table = T.toString();
    _db.execute('DELETE FROM $table');
    Utils.log(msg: 'Deleted all data from $table', showLogs: _showLogs);
    onChangeDB.add(table);
  }

  @override
  Future<void> dropTable<T>({String? tableName}) async {
    if (!_tableInitialized) {
      await checkIfTableNotExistsButExistInMappers();
    }
    final table = tableName ?? T.toString();
    _db.execute('DROP TABLE IF EXISTS $table');
    Utils.log(msg: 'Dropped table $table', showLogs: _showLogs);
    onChangeDB.add(table);
  }

  @override
  Future<List<Map<String, dynamic>>> rawQuery<T>(Query query) async {
    if (!_tableInitialized) {
      await checkIfTableNotExistsButExistInMappers();
    }
    if (!isTableExists(T.toString())) {
      Utils.log(
          msg:
              'Table ${T.toString()} does not exist in database. Please initialize in CozyData.initialize(mappers: [YourMapper()])',
          showLogs: true,
          isError: true);
      return [];
    }

    final stmt = _db.prepare(query.sql);
    final results = stmt.select(query.arguments);
    stmt.dispose();
    Utils.log(
        msg:
            'Query: ${query.sql} ${query.arguments.isEmpty ? "" : "Args: ${query.arguments}"}',
        showLogs: _showLogs);
    return results.map((row) => Map<String, dynamic>.from(row)).toList();
  }
}
