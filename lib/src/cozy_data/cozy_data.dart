part of cozy_data;

/// The `CozyReference` class holds a reference to a `ClassMapperBase` and a `CozyQueryListener`.
/// It is used to cache query listeners for efficient reuse.

/// {@category Models}
class _CozyReference {
  final ClassMapperBase mapper;
  final CozyQueryListener<dynamic> listner;

  _CozyReference({required this.mapper, required this.listner});
}

/// The `CozyData` class is a singleton that manages database operations and caching.
/// It provides methods to initialize the database, query data, save data, delete data,
/// update data, and fetch data by ID.
///
/// Example usage:
/// ```dart
/// await CozyData.initialize(mappers: [MyModelMapper()]);
/// final queryListener = CozyData.queryListener<MyModel>();
/// final data = await CozyData.save(myModelInstance);
/// await CozyData.delete(myModelInstance);
/// await CozyData.update(myModelInstance);
/// final fetchedData = await CozyData.fetch<MyModel>();
/// final dataById = await CozyData.fetcById<MyModel>(1);
/// await CozyData.dropTable<MyModel>();
/// await CozyData.dropAllTables();
/// CozyData.cleanAndCloseDb();
/// ```
class CozyData {
  static final CozyData _instance = CozyData._();
  factory CozyData() => _instance;
  CozyData._();

  static final _queryCache = <String, _CozyReference>{};
  static final _mapperCache = <String, ClassMapperBase>{};
  static bool _isInitialized = false;
  static Completer<void>? _initializer;
  static Db? _db;
  static CozyEngine _engine = CozyEngine.sqlite;
  static bool _shouldDropTableIfExistsButNoInit = false;
  static bool _showLogs = false;
  static String? _path;

  static List<ClassMapperBase> _mappers = [];

  /// Initializes the CozyData instance with the provided mappers and settings.
  /// This method must be called before performing any database operations.
  ///
  /// Example usage:
  /// ```dart
  /// await CozyData.initialize(mappers: [MyModelMapper()]);
  /// ```
  /// Parameters:
  /// * [mappers] - A list of `ClassMapperBase` instances for the models to be used
  /// * [engine] - The database engine to use (defaults to `CozyEngine.sqlite3`)
  /// * [shouldDropTableIfExistsButNoInit] - A flag to drop tables if they exist but are not initialized (defaults to `false`)
  /// * [showLogs] - A flag to enable logging (defaults to `false`)
  /// * [persistentModelID] - The field name to use as the primary key (defaults to 'persistentModelID')
  /// * [path] - The path to the database file (defaults to the application documents directory)
  static Future<void> initialize(
      {required List<ClassMapperBase> mappers,
      CozyEngine engine = CozyEngine.sqlite3,
      bool shouldDropTableIfExistsButNoInit = false,
      bool showLogs = false,
      String? persistentModelID,
      String? path}) async {
    if (_isInitialized) return;
    _mappers = mappers;

    if (_initializer != null) {
      await _initializer!.future;
      return;
    }
    _initializer = Completer<void>();
    try {
      _showLogs = showLogs;
      _engine = engine;
      _shouldDropTableIfExistsButNoInit = shouldDropTableIfExistsButNoInit;
      final p = path ?? (await getApplicationDocumentsDirectory()).path;
      _path = p;
      if (persistentModelID != null) {
        Utils.persistentModelID = persistentModelID;
      }

      _db = await InitDatabase.getDb(
        mappers: mappers,
        engine: engine,
        path: p,
        showLogs: showLogs,
        shouldDropTableIfExistsButNoInit: shouldDropTableIfExistsButNoInit,
      );
      for (var mapper in mappers) {
        _mapperCache[mapper.id] = mapper;
      }
      Utils.log(
        msg: 'cozy_data initialized with tables: ${_mapperCache.keys}',
        showLogs: showLogs,
      );

      _isInitialized = true;
      _initializer!.complete();
    } catch (e) {
      _initializer!.completeError(e);
      _initializer = null;
      throw Exception('Failed to initialize cozy_data: $e');
    }
  }

  /// Ensures that the CozyData instance is initialized.
  /// If not initialized, it calls the initialize method.
  static void _ensureInitialized<T>() async {
    if (!_isInitialized) {
      await initialize(
          mappers: _mappers,
          engine: _engine,
          shouldDropTableIfExistsButNoInit: _shouldDropTableIfExistsButNoInit,
          showLogs: _showLogs,
          path: _path);
    }
  }

  /// Returns a query listener for the specified model type.
  /// If the query listener is already cached, it returns the cached listener.
  /// If the listener is disposed, it removes it from the cache and creates a new one.
  ///
  /// Example usage:
  /// ```dart
  /// final queryListener = CozyData.queryListener<MyModel>();
  /// ```
  static CozyQueryListener<T> queryListener<T>({
    int? limit,
    int? offset,
    CozyQueryController<T>? controller,
  }) {
    if (T == dynamic) {
      throw Exception(
          'Cannot query without model Data Type. Please provide a concrete model type.\nExample: CozyData.queryListener<ModelData>()');
    }
    _ensureInitialized<T>();

    final queryKey = '${T.toString()}};${limit ?? 0};${offset ?? 0}';

    /// Check if the query listener is already cached
    /// if it is, return it
    /// if it is not, create a new one and cache it
    /// if it is disposed, remove it from the cache
    if (_queryCache.containsKey(queryKey)) {
      final queryL = _queryCache[queryKey]!.listner as CozyQueryListener<T>;
      if (queryL._isDisposed) {
        _queryCache.remove(queryKey);
      } else {
        return queryL;
      }
    }

    final mapper = _mapperCache[T.toString()];
    if (mapper == null) {
      final msg =
          "Mapper not found for type: $T, Please initialize the class in CozyData.initialize(mappers: [ModelMapper()])";
      Utils.log(showLogs: true, msg: msg, isError: true);
      throw Exception(msg);
    }

    return _queryCache
        .putIfAbsent(
            queryKey,
            () => _CozyReference(
                  mapper: mapper,
                  listner: CozyQueryListener<T>(
                    db: _db!,
                    controller: controller,
                    limit: limit,
                    offset: offset,
                    mapper: mapper,
                  ),
                ))
        .listner as CozyQueryListener<T>;
  }

  /// Saves the provided data to the database.
  ///
  /// Example usage:
  /// ```dart
  /// final savedData = await CozyData.save<MyModel>(myModelInstance);
  /// ```
  static Future<T> save<T>(T data) async {
    final (encodeJson, _) = await _checker<T>(data);
    final flattenedJson = flattenJson(encodeJson);
    await _db!.save<T>(data: flattenedJson);
    return data;
  }

  /// Checks the provided data and returns its JSON representation and primary key value.
  /// Throws an exception if the mapper is not found or if the data type does not match.

  static Future<(Map<String, dynamic>, String)> _checker<T>(T data) async {
    _ensureInitialized<T>();
    final mapper = _mapperCache[T.toString()];
    if (mapper == null) {
      throw Exception(
          'Mapper not found for type: $T, Please initialize in CozyData.initialize(mappers: [ModelMapper()])');
    }

    if ((data as dynamic).runtimeType.toString() != T.toString()) {
      throw Exception('Data type mismatch: ${data.runtimeType} is not $T');
    }
    final encodeJson =
        jsonDecode(mapper.encodeJson<T>(data)) as Map<String, dynamic>;
    if (!(encodeJson).containsKey(Utils.persistentModelID)) {
      throw Exception(
          'Data does not have a ${Utils.persistentModelID} field defined and it is set as primary key');
    }
    String idValue = encodeJson[Utils.persistentModelID].toString();

    return (encodeJson, idValue);
  }

  /// Deletes the provided data from the database.
  ///
  /// Example usage:
  /// ```dart
  /// await CozyData.delete<MyModel>(myModelInstance);
  /// ```
  static Future<void> delete<T>(T data) async {
    final (_, idValue) = await _checker<T>(data);

    await _db!.delete<T>(where: Utils.persistentModelID, whereArgs: [idValue]);
  }

  /// Updates the provided data in the database.
  ///
  /// Example usage:
  /// ```dart
  /// await CozyData.update<MyModel>(myModelInstance);
  /// ```
  static Future<void> update<T>(T data) async {
    final (encodeJson, pKValue) = await _checker<T>(data);
    final flattenedJson = flattenJson(encodeJson);
    await _db!.update<T>(
        where: Utils.persistentModelID,
        whereArgs: [pKValue],
        data: flattenedJson);
  }

  /// Fetches data from the database based on the provided query builder and limits.
  ///
  /// Example usage:
  /// ```dart
  /// final fetchedData = await CozyData.fetch<MyModel>(limit: 10, offset: 0);
  /// ```
  static Future<List<T>> fetch<T>(
      {CozyQueryBuilder? customBuilder, int? limit, int? offset}) async {
    if (T == dynamic) {
      throw Exception(
          'Cannot query without model Data Type. Please provide a concrete model type.\nExample: CozyData.queryListener<ModelData>()');
    }
    _ensureInitialized<T>();
    final mapper = _mapperCache[T.toString()];
    if (mapper == null) {
      final msg =
          "Mapper not found for type: $T, Please initialize the class in CozyData.initialize(mappers: [ModelMapper()])";
      Utils.log(showLogs: true, msg: msg, isError: true);
      throw Exception(msg);
    }
    final query = customBuilder?.build() ??
        _QueryBuilder(
          table: T.toString(),
          limit: limit,
          offset: offset,
        ).build();

    final List<Map<String, dynamic>> maps = await _db!.rawQuery<T>(query);

    final items = maps.map(
      (e) {
        return mapper.decodeMap<T>(unflattenJson(e));
      },
    ).toList();
    return items;
  }

  /// Fetches data by ID from the database.
  ///
  /// Example usage:
  /// ```dart
  /// final dataById = await CozyData.fetcById<MyModel>(1);
  /// ```
  static Future<T?> fetcById<T>({required dynamic id}) async {
    if (T == dynamic) {
      throw Exception(
          'Cannot query without model Data Type. Please provide a concrete model type.\nExample: CozyData.queryListener<ModelData>()');
    }
    _ensureInitialized<T>();
    final mapper = _mapperCache[T.toString()];
    if (mapper == null) {
      final msg =
          "Mapper not found for type: $T, Please initialize the class in CozyData.initialize(mappers: [ModelMapper()])";
      Utils.log(showLogs: true, msg: msg, isError: true);
      throw Exception(msg);
    }
    final query = _QueryBuilder(
      table: T.toString(),
      whereGroups: [
        PredicateGroup(
          predicates: [Predicate.equals(Utils.persistentModelID, id)],
        ),
      ],
    ).build();

    final List<Map<String, dynamic>> maps = await _db!.rawQuery<T>(query);

    final items = maps.map(
      (e) {
        return mapper.decodeMap<T>(unflattenJson(e));
      },
    ).toList();
    T? data;
    if (items.isNotEmpty) {
      data = items.first;
    } else {
      Utils.log(showLogs: _showLogs, msg: 'No data found for id: $id');
    }

    return data;
  }

  /// Drops the table for the provided model type.
  ///
  /// Example usage:
  /// ```dart
  /// await CozyData.dropTable<MyModel>();
  /// ```
  static Future<void> dropTable<T>() async {
    _ensureInitialized<T>();
    final mapper = _mapperCache[T.toString()];
    if (mapper == null) {
      final msg =
          "Mapper not found for type: $T, Please initialize the class in CozyData .initialize(mappers: [ModelMapper()])";
      Utils.log(showLogs: true, msg: msg, isError: true);
      throw Exception(msg);
    }
    await _db!.dropTable<T>();
    _mapperCache.remove(T.toString());
    _queryCache.remove(T.toString());
    return;
  }

  /// Drops all tables in the database.
  /// This method should be used with caution as it will delete all data in the database.
  /// Example usage:
  /// ```dart
  /// await CozyData.dropAllTables();
  /// ```
  static Future<void> dropAllTables() async {
    for (var mapper in _mapperCache.values) {
      await _db!.dropTable(tableName: mapper.id);
    }
    _mapperCache.clear();
    _queryCache.clear();
  }

  /// Closes the database connection and clears the cache.
  /// This method should be called when the database is no longer needed.
  /// It is useful for cleaning up resources and preventing memory leaks.
  /// Example usage:
  /// ```dart
  /// CozyData.cleanAndCloseDb();
  /// ```
  static void cleanAndCloseDb() {
    _db = null;
    _queryCache.clear();
    _mapperCache.clear();
    _isInitialized = false;
  }
}
