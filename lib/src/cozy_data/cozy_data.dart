// ignore_for_file: invalid_use_of_protected_member, use_string_in_part_of_directives

part of cozy_data;

/// Manages and provides access to a shared Isar database instance.
///
/// {@template flutter_data_container}
/// This singleton class handles initializing an Isar database instance,
/// managing query listeners, and performing CRUD operations.
/// You must initialize the container with a list of [schemas] before
/// using any other methods. To initialize, call [initialize] once in
/// your application startup code.
///
/// The [directory] parameter is optional and specifies the path where
/// the database file will be stored. If not specified, the default
/// application documents directory will be used.
///
/// Use the [inspector] option to enable the Isar Inspector in debug mode
/// for live database inspection.
///
/// Use the static methods to interact with the database, such as:
/// - [save] to insert or update data.
/// - [fetch] to retrieve data with optional filtering and sorting.
/// - [update] to modify existing records.
/// - [delete] and [deleteAll] to remove records.
/// {@endtemplate}
class CozyData {
  static Isar? _isar;
  static final _queryCache = <String, DataQueryListener<dynamic>>{};
  static bool _isInitialized = false;
  static Completer<void>? _initializer;
  static bool _idTypeInt = false;
  static const bool _isIdInitialized = false;

  static List<IsarGeneratedSchema> schema = [];

  // Private constructor to prevent instantiation
  CozyData._();

  /// Initializes the Isar instance with the specified configurations.
  ///
  /// {@template initialize}
  /// Call this method only once to set up the Isar instance with the
  /// required [schemas]. Optionally, you may configure a [directory]
  /// path, [engine] type, database [maxSizeMiB], and an [encryptionKey].
  ///
  /// The [compactOnLaunch] option allows for database compaction if the
  /// conditions specified are met upon launch. This is recommended for
  /// optimized performance.
  ///
  /// Enabling [inspector] allows live debugging in development mode using
  /// the Isar Inspector. Use the [name] parameter to name the database
  /// instance if opening multiple instances.
  /// {@endtemplate}
  static Future<void> initialize({
    required List<IsarGeneratedSchema> schemas,
    String? directory,
    IsarEngine engine = IsarEngine.isar,
    int? maxSizeMiB,
    String? encryptionKey,
    CompactCondition? compactOnLaunch,
    bool inspector = false,
    String name = Isar.defaultName,
  }) async {
    if (_isInitialized) return;
    schema = schemas;

    if (_initializer != null) {
      await _initializer!.future;
      return;
    }

    _initializer = Completer<void>();

    try {
      final dir = await getApplicationDocumentsDirectory();
      _isar = Isar.open(
        schemas: schemas,
        directory: dir.path,
        engine: IsarEngine.sqlite,
        compactOnLaunch: compactOnLaunch,
        encryptionKey: encryptionKey,
        maxSizeMiB: maxSizeMiB,
        inspector: inspector,
        name: name,
      );
      _isInitialized = true;
      await Utils.idsTypeIsInt(isar: _isar!);
      _initializer!.complete();
    } catch (e) {
      _initializer!.completeError(e);
      _initializer = null;
      throw Exception('Failed to initialize CozyData: $e');
    }
  }

  /// Ensures the Isar instance is initialized before performing any operations.
  static Future<void> _ensureInitialized<T>() async {
    if (!_isInitialized) {
      await initialize(schemas: schema);
    }
    if (!_isIdInitialized) {
      _idTypeInt = await Utils.getIdIsInit<T>();
    }
  }

  /// Retrieves a [DataQueryListener] for querying data.
  ///
  /// {@template query_listener}
  /// Use this method to obtain a listener for querying the database
  /// with various filtering, sorting, and distinct options. The [T] type
  /// parameter must match the model type being queried.
  ///
  /// An [Exception] will be thrown if no model type is provided.
  ///
  /// * [sortByProperties] is a list of [SortProperty] objects that define the sorting order.
  /// example: [SortProperty(property: 0, sort: Sort.desc)]
  /// property is the index of the property in the model class used for sorting.
  /// if you have a model class like this:
  /// class Person {
  ///  final String name;
  /// final int age;
  /// }
  /// and you want to sort by name, you would use [SortProperty(property: 0, sort: Sort.desc)]
  /// if you want to sort by age, you would use [SortProperty(property: 1, sort: Sort.desc)]
  ///
  /// * [distinctByProperties] is a list of [DistinctProperty] objects that define the distinct properties.
  /// example: [DistinctProperty(property: 0)]
  /// property is the index of the property in the model class used for distinct values.
  /// same example as above, if you want to get distinct values by name, you would use [DistinctProperty(property: 0)]
  ///
  /// * [objectFilters] is a list of [ObjectFilter] objects that define the filter conditions based on an embedded object.
  /// example: [ObjectFilter(property: 0, filter: Filter.equals('name', 'John'))]
  /// property is the index of the property in the model class used for filtering.
  /// filter is the filter condition to apply to the property.
  ///
  /// * [filterCondition] is a [Filter] object that defines the filter condition for the query.
  /// example: EqualCondition(property: 0, value: "Fode"),
  /// posibilities are:{
  /// EqualCondition, GreaterCondition, GreaterOrEqualCondition, LessCondition, LessOrEqualCondition,
  /// BetweenCondition, StartsWithCondition, EndsWithCondition, ContainsCondition, MatchesCondition,
  /// IsNullCondition, AndGroup, OrGroup, ObjectFilter
  /// }
  ///
  /// {@endtemplate}
  static DataQueryListener<T> queryListener<T>({
    int? limit,
    int? offset,
    DataQueryController<T>? controller,
  }) {
    if (T == dynamic) {
      throw Exception(
          'Cannot query without model Data Type. Please provide a concrete model type.\nExample: CozyData.query<ModelData>()');
    }
    _ensureInitialized<T>();

    final queryKey = '${T.toString()}};${limit ?? 0};${offset ?? 0}';
    return _queryCache.putIfAbsent(
      queryKey,
      () => DataQueryListener<T>(
        isar: _isar!,
        controller: controller,
        limit: limit,
        offset: offset,
      ),
    ) as DataQueryListener<T>;
  }

  /// Saves a model [T] to the database, either inserting or updating.
  static Future<T> save<T>(T model) async {
    await _ensureInitialized<T>();

    await _isar!.write((isar) async {
      if (_idTypeInt) {
        isar.collection<int, T>().put(model);
      } else {
        isar.collection<String, T>().put(model);
      }
    });
    return model;
  }

  /// Fetches a list of models [T] from the database with optional query options.
  static Future<List<T>> fetch<T>({
    int? limit,
    int? offset,
    Filter? filterCondition,
    List<SortProperty>? sortByProperties,
    List<DistinctProperty>? distinctByProperties,
    ObjectFilter? objectFilter,
  }) async {
    await _ensureInitialized<T>();

    IsarCollection<dynamic, T> collection;
    if (_idTypeInt) {
      collection = _isar!.collection<int, T>();
    } else {
      collection = _isar!.collection<String, T>();
    }

    final q = QueryBuilder.apply<T, T, QAfterFilterCondition>(
        collection.where(), (query) {
      query = query.copyWith(
          sortByProperties: sortByProperties,
          distinctByProperties: distinctByProperties);
      if (filterCondition != null) {
        return query.addFilterCondition(filterCondition);
      } else if (objectFilter != null) {
        return query.addFilterCondition(objectFilter);
      } else {
        return query;
      }
    });
    return q.findAll();
  }

  /// Updates a model [T] in the database, re-saving it.
  static Future<T> update<T>(T model) async {
    return await save(model);
  }

  /// Deletes a specific model [T] by its unique identifier.
  static Future<void> delete<T>(dynamic id) async {
    if (T == dynamic) {
      throw Exception(
          'Cannot delete without model Data Type. Please provide a concrete model type.Example: CozyData.delete<ModelData>(id)');
    }

    await _ensureInitialized<T>();

    if (_idTypeInt && id is! int) {
      throw Exception(
          'Id type of ${T.toString()} must be ${_idTypeInt ? 'int' : 'string'}');
    }

    await _isar!.write((isar) async {
      if (_idTypeInt) {
        isar.collection<int, T>().delete(id);
      } else {
        isar.collection<String, T>().delete(id);
      }
    });
  }

  /// Deletes all models [T] of the specified type from the database.
  static Future<void> deleteAll<T>() async {
    if (T == dynamic) {
      throw Exception(
          'Cannot delete without model Data Type. Please provide a concrete model type.Example: CozyData.deleteAll<ModelData>()');
    }
    await _ensureInitialized<T>();

    await _isar!.write((isar) async {
      if (_idTypeInt) {
        isar.collection<int, T>().clear();
      } else {
        isar.collection<String, T>().clear();
      }
    });
  }
}
