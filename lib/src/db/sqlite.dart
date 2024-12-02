part of cozy_data;

/// A SQLite database implementation of the [Db] interface.
///
/// This class provides methods to interact with SQLite database for CRUD operations
/// and table management. It follows the Singleton pattern to ensure only one
/// database instance exists throughout the application.
///
/// ## Features:
/// * Automatic table creation and schema management
/// * CRUD operations (Create, Read, Update, Delete)
/// * Table existence checking and dropping
/// * Column management and auto-addition
/// * Transaction support
/// * Query logging (optional)
///
/// ## Example usage:
/// ```dart
/// // Initialize database
/// final db = await openDatabase('my_db.db');
///
/// // Create Sqlite instance with mappers
/// final sqlite = Sqlite(
///   db: db,
///   mappers: [UserMapper(), ProductMapper()],
///   shouldDropTableIfExistsButNoInit: true,
///   showLogs: true
/// );
///
/// // Save data
/// await sqlite.save<User>(data: {
///   'id': 'user_1',
///   'name': 'John Doe',
///   'email': 'john@example.com'
/// });
///
/// // Query data
/// final results = await sqlite.rawQuery<User>(
///   Query('SELECT * FROM User WHERE name = ?', ['John Doe'])
/// );
///
/// // Update data
/// await sqlite.update<User>(
///   where: 'id',
///   whereArgs: ['user_1'],
///   data: {'name': 'Jane Doe'}
/// );
///
/// // Delete data
/// await sqlite.delete<User>(where: 'id', whereArgs: ['user_1']);
/// ```
///
/// The class maintains a singleton instance through [_instance] to prevent multiple
/// database connections.
///
/// [mappers] is a list of [ClassMapperBase] instances for object-relational mapping.
/// [shouldDropTableIfExistsButNoInit] determines if tables not in mappers should be dropped.
/// [_showLogs] controls debug logging output.

/// Function Documentation:

/// [getTables]
/// Retrieves all table names from the database.
/// Returns a list of table names as strings.

/// [dropTableIfNotExistsInMappers]
/// Removes tables that exist in the database but are not defined in mappers.
/// Useful for cleaning up deprecated tables.

/// [isTableExists]
/// Checks if a specific table exists in the database.
/// Returns true if table exists, false otherwise.

/// [createTables]
/// Creates a new table with specified structure if it doesn't exist.
/// Automatically adds a primary key column defined by [Utils.persistentModelID].

/// [checkIfAllColumnsExistOrAdd]
/// Ensures all required columns exist in the table.
/// Adds missing columns automatically without data loss.

/// [save]
/// Inserts new data into the specified table.
/// Creates table if it doesn't exist and ensures proper column structure.
/// Throws exception if duplicate primary key is detected.

/// [delete]
/// Removes records matching the specified condition.
/// Operates within a transaction for data integrity.

/// [update]
/// Modifies existing records matching the specified condition.
/// Operates within a transaction for data integrity.

/// [deleteAll]
/// Removes all records from the specified table.
/// Use with caution as this operation cannot be undone.

/// [dropTable]
/// Completely removes the specified table from the database.
/// Use with caution as this operation cannot be undone.

/// [rawQuery]
/// Executes a custom SQL query with optional arguments.
/// Returns empty list if table doesn't exist.
/// Operates within a transaction for data integrity.
class Sqlite implements Db {
  static Sqlite? _instance;
  final sqflite.Database _db;
  final List<ClassMapperBase> mappers;
  final bool shouldDropTableIfExistsButNoInit;
  bool _culumnExist = false;
  bool _showLogs = false;
  bool _tableInitialized = false;
  final _lock = Lock();

  Sqlite._(
      {required sqflite.Database db,
      required this.mappers,
      required this.shouldDropTableIfExistsButNoInit,
      bool showLogs = false})
      : _db = db,
        _showLogs = showLogs {
    if (shouldDropTableIfExistsButNoInit) {
      dropTableIfNotExistsInMappers();
    }
    checkIfTableNotExistsButExistInMappers();
  }

  factory Sqlite(
      {required sqflite.Database db,
      required List<ClassMapperBase> mappers,
      required bool shouldDropTableIfExistsButNoInit,
      bool showLogs = false}) {
    _instance ??= Sqlite._(
        db: db,
        mappers: mappers,
        shouldDropTableIfExistsButNoInit: shouldDropTableIfExistsButNoInit,
        showLogs: showLogs);
    return _instance!;
  }

  // get all tables
  Future<List<String>> getTables() async {
    final tables = await _db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' ORDER BY name");
    return tables.map((e) => e['name'] as String).toList();
  }

  /// drop table if exists but not exist in mappers
  Future<void> dropTableIfNotExistsInMappers() async {
    final tables = await getTables();
    for (var table in tables) {
      if (!mappers.any((element) => element.id == table)) {
        await _db.execute('DROP TABLE IF EXISTS $table');
        Utils.log(
            msg: 'Table $table dropped because it does not exist in mappers',
            showLogs: _showLogs);
      }
    }
  }

  Future<void> checkIfTableNotExistsButExistInMappers() async {
    await _lock.synchronized(() async {
      final tables = await getTables();
      for (var mapper in mappers) {
        if (!tables.contains(mapper.id)) {
          Map<String, Object?> data = {};
          for (var field in mapper.fields.entries) {
            data[field.value.name] = null;
          }
          await createTables(table: mapper.id, data: data);
          Utils.log(
              msg: '🥳 Table ${mapper.id} created 🥳', showLogs: _showLogs);
        }
      }
      _tableInitialized = true;
    });
  }

  // Check if table exists
  Future<bool> isTableExists(String tableName) async {
    try {
      var result = await _db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name=?",
        [tableName],
      );
      return result.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // Create tables
  Future<void> createTables(
      {required String table, required Map<String, Object?> data}) async {
    String createTable = 'CREATE TABLE IF NOT EXISTS $table (';
    createTable += '${Utils.persistentModelID} TEXT PRIMARY KEY,';
    for (var field in data.entries) {
      String name = field.key;
      if (name == Utils.persistentModelID) {
        continue;
      }
      createTable += '$name TEXT,';
    }
    createTable = createTable.substring(0, createTable.length - 1);
    createTable += ')';
    await _db.execute(createTable);
  }

  Future<void> checkIfAllColumnsExistOrAdd(
      {required String table, required Map<String, Object?> data}) async {
    if (_culumnExist) return;
    final columns = await _db.rawQuery('PRAGMA table_info($table)');
    final columnNames = columns.map((e) => e['name']).toList();
    for (var field in data.entries) {
      String name = field.key;
      if (name == Utils.persistentModelID) {
        continue;
      }
      if (!columnNames.contains(name)) {
        await _db.execute('ALTER TABLE $table ADD COLUMN $name TEXT');
      }
    }
    _culumnExist = true;
    return;
  }

  @override
  Future<void> save<T>({required Map<String, Object?> data}) async {
    if (!_tableInitialized) {
      await checkIfTableNotExistsButExistInMappers();
    }
    bool isTableExist = await isTableExists(T.toString());
    if (!isTableExist) {
      await createTables(table: T.toString(), data: data);
    }
    await checkIfAllColumnsExistOrAdd(table: T.toString(), data: data);

    try {
      return _db.transaction((txn) async {
        await txn.insert(T.toString(), data);
        Utils.log(
            msg: 'Data saved in table ${T.toString()}', showLogs: _showLogs);
        onChangeDB.add(T.toString());
      });
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
  }

  @override
  Future<void> delete<T>(
      {required String where, required List<Object?> whereArgs}) async {
    if (!_tableInitialized) {
      await checkIfTableNotExistsButExistInMappers();
    }
    await _db.transaction((txn) async {
      await txn.delete(T.toString(), where: '$where = ?', whereArgs: whereArgs);
      Utils.log(
          msg: 'Data deleted from table ${T.toString()}', showLogs: _showLogs);
      onChangeDB.add(T.toString());
    });
  }

  @override
  Future<void> update<T>(
      {required String where,
      required List<Object?> whereArgs,
      required Map<String, Object?> data}) async {
    if (!_tableInitialized) {
      await checkIfTableNotExistsButExistInMappers();
    }
    await _db.transaction((txn) async {
      await txn.update(T.toString(), data,
          where: '$where = ?', whereArgs: whereArgs);
      Utils.log(
          msg: 'Data updated in table ${T.toString()}', showLogs: _showLogs);
      onChangeDB.add(T.toString());
    });
  }

  @override
  Future<void> deleteAll<T>() async {
    if (!_tableInitialized) {
      await checkIfTableNotExistsButExistInMappers();
    }
    await _db.delete(T.toString());
    Utils.log(
        msg: 'All data deleted from table ${T.toString()}',
        showLogs: _showLogs);
    onChangeDB.add(T.toString());
  }

  @override
  Future<void> dropTable<T>({String? tableName}) async {
    if (!_tableInitialized) {
      await checkIfTableNotExistsButExistInMappers();
    }
    final table = tableName ?? T.toString();
    await _db.execute('DROP TABLE IF EXISTS $table');
    Utils.log(msg: 'Table ${T.toString()} dropped', showLogs: _showLogs);
    onChangeDB.add(T.toString());
  }

  @override
  Future<List<Map<String, dynamic>>> rawQuery<T>(Query query) async {
    if (!_tableInitialized) {
      await checkIfTableNotExistsButExistInMappers();
    }
    final tableExist = await isTableExists(T.toString());

    if (!tableExist) {
      Utils.log(
          msg:
              'Table ${T.toString()} does not exist in database. Please initialize in CozyData.initialize(mappers: [YourMapper()])',
          showLogs: true,
          isError: true);
      return [];
    }
    return await _db.transaction((txn) async {
      Utils.log(
        msg:
            'Query: ${query.sql} ${query.arguments.isEmpty ? "" : "Args: ${query.arguments}"}',
        showLogs: _showLogs,
      );
      return await txn.rawQuery(query.sql, query.arguments);
    });
  }
}
