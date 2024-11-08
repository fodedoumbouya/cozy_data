// ignore_for_file: invalid_use_of_protected_member, use_string_in_part_of_directives

part of cozy_data;

/// A listener for data queries, observing changes in an Isar collection
/// and notifying listeners when data updates.
///
/// {@template data_query_listener}
/// This class provides a reactive data query listener for an Isar collection,
/// fetching data initially and setting up a stream to observe any changes.
/// Use this for real-time updates in your UI components.
///
/// The [DataQueryListener] requires a reference to an [Isar] instance
/// and allows optional parameters to specify query filters and limits.
/// Use the [controller] to attach custom behaviors or additional controls.
///
/// The listener fetches data based on filter and sort conditions provided
/// at initialization and listens for changes in the collection using the
/// Isar watch function.
/// {@endtemplate}
class DataQueryListener<T> with ChangeNotifier {
  final Isar _isar;
  final int? _limit;
  final int? _offset;
  final List<SortProperty>? _sortByProperties;
  final List<DistinctProperty>? _distinctByProperties;
  final ObjectFilter? _objectFilter;
  final Filter? _filterCondition;
  List<T> _items = [];
  StreamSubscription? _subscription;

  late IsarQuery<T> _queryBuilder;
  late final DataQueryController<T> controller;

  /// Provides a read-only list of the queried items.
  List<T> get items => _items;

  /// Constructs a [DataQueryListener] with optional query parameters.
  ///
  /// {@macro data_query_listener}
  ///
  /// The [isar] parameter is required to access the Isar collection.
  /// Optional parameters include:
  /// - [filterCondition]: Filter criteria for the query.
  /// - [limit] and [offset]: Pagination controls.
  /// - [sortByProperties]: Sorting order for the results.
  /// - [distinctByProperties]: Distinct property constraints.
  /// - [objectFilter]: Object-specific filter constraints.
  ///
  /// A [controller] can be passed in to customize query behaviors;
  /// if not provided, a default controller is created.
  DataQueryListener({
    required Isar isar,
    // required bool isIdIntType,
    Filter? filterCondition,
    int? limit,
    int? offset,
    List<SortProperty>? sortByProperties,
    List<DistinctProperty>? distinctByProperties,
    ObjectFilter? objectFilter,
    DataQueryController<T>? controller,
  })  : _isar = isar,
        // _isIdIntType = isIdIntType,
        _limit = limit,
        _offset = offset,
        _distinctByProperties = distinctByProperties,
        _sortByProperties = sortByProperties,
        _objectFilter = objectFilter,
        _filterCondition = filterCondition {
    this.controller = controller ?? DataQueryController<T>();
    this.controller._attach(this);
    _initializeStream();
  }

  /// Fetches data and refreshes the [items] list.
  ///
  /// This method executes the query defined in [_queryBuilder], retrieves
  /// the results with any specified [limit] and [offset], and updates the
  /// [items] list with fresh data. Notifies listeners after updating.
  Future<void> _refreshData() async {
    _items = _queryBuilder.findAll(limit: _limit, offset: _offset);
    notifyListeners();
  }

  /// Sets up the query stream and begins observing for changes.
  ///
  /// This method fetches initial data, then starts listening to the
  /// collection for any changes. On receiving change notifications,
  /// it refreshes the data automatically, triggering UI updates.
  ///
  /// Throws an [Exception] if the schema for [T] is not registered.
  Future<void> _initializeStream() async {
    try {
      final isIdIntType = await Utils.getIdIsInit<T>();

      IsarCollection<dynamic, T> collection;
      if (isIdIntType) {
        collection = _isar.collection<int, T>();
      } else {
        collection = _isar.collection<String, T>();
      }
      // Initial fetch
      _queryBuilder = (await _fetch()).build();

      // Initial data load
      await _refreshData();

      // Set up a listener for collection changes
      _subscription = collection.watchLazy().listen((_) async {
        await _refreshData();
      });
    } catch (e) {
      if (e is IsarError &&
          e.message == "Missing ${T.runtimeType}Schema in Isar.open") {
        throw Exception(
            'Schema for ${T.toString()} not found. Did you forget to add it to DartDataContainer.initialize(schemas: [])?');
      } else {
        rethrow;
      }
    }
  }

  /// Creates a query builder with the specified filter and sort conditions.
  ///
  /// Uses the provided parameters such as [sortByProperties], [distinctByProperties],
  /// [filterCondition], and [objectFilter] to define the query builder.
  Future<QueryBuilder<T, T, QAfterFilterCondition>> _fetch() async {
    IsarCollection<dynamic, T> collection;

    final isIdIntType = await Utils.getIdIsInit<T>();
    if (isIdIntType) {
      collection = _isar.collection<int, T>();
    } else {
      collection = _isar.collection<String, T>();
    }
    return QueryBuilder.apply<T, T, QAfterFilterCondition>(collection.where(),
        (query) {
      query = query.copyWith(
          sortByProperties: _sortByProperties,
          distinctByProperties: _distinctByProperties);
      if (_filterCondition != null) {
        return query.addFilterCondition(_filterCondition);
      } else if (_objectFilter != null) {
        return query.addFilterCondition(_objectFilter);
      } else {
        return query;
      }
    });
  }

  /// Disposes of the query listener and cancels the active subscription.
  ///
  /// This method should be called when the listener is no longer needed
  /// to prevent memory leaks from the active stream subscription.
  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
