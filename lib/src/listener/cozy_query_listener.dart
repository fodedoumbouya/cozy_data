part of cozy_data;

/// A listener class that manages database queries and updates for a specific type [T].
///
/// This class implements the ChangeNotifier mixin to notify listeners when data changes.
/// It provides functionality to query a database, listen for changes, and maintain a list
/// of items of type [T].
///
/// The class maintains:
/// - A database connection
/// - Optional pagination parameters (limit and offset)
/// - A list of items of type [T]
/// - A subscription to database changes
/// - A query controller for building custom queries
///
/// Features:
/// - Automatic data refresh when database changes are detected
/// - Custom query building through [CozyQueryController]
/// - Pagination support
/// - Automatic resource cleanup on disposal
///
/// Important properties:
/// - [items]: The current list of items from the database
/// - [controller]: The query controller for building custom queries
///
/// Constructor parameters:
/// - [db]: The database instance to query from
/// - [limit]: Optional limit for query results
/// - [offset]: Optional offset for query results
/// - [controller]: Optional custom query controller
/// - [mapper]: Class mapper for converting database records to objects
///
/// @nodoc

/// Private method to initialize the database change stream and set up initial data.
/// Handles:
/// - Initial data load
/// - Stream subscription setup
/// - Change detection and refresh
/// @nodoc
/* _initializeStream() documentation */

/// Private method to refresh the data from the database.
/// Handles:
/// - Executing the current query
/// - Converting database records to objects
/// - Notifying listeners of changes
/// - Error propagation
/// @param customQuery Optional custom query to execute instead of the built query
/// @nodoc
/* _refreshData() documentation */

/// Cleanup method that:
/// - Cancels the database change subscription
/// - Marks the listener as disposed
/// - Calls the parent dispose method
/// Ensures proper resource cleanup when the listener is no longer needed.
/// @nodoc
/* dispose() documentation */

class CozyQueryListener<T> with ChangeNotifier {
  final Db _db;
  final int? _limit;
  final int? _offset;
  final ClassMapperBase _mapper;

  List<T> _items = [];
  bool _isDisposed = false;
  StreamSubscription<String>? _subscription;

  late final CozyQueryController<T> controller;

  List<T> get items => _items;

  CozyQueryListener({
    required Db db,
    int? limit,
    int? offset,
    CozyQueryController<T>? controller,
    required ClassMapperBase mapper,
  })  : _db = db,
        _limit = limit,
        _offset = offset,
        _mapper = mapper {
    this.controller = controller ?? CozyQueryController<T>();
    this.controller._attach(this);
    _initializeStream();
  }

  /// Private method to initialize the database change stream and set up initial data.
  Future<void> _initializeStream() async {
    await _refreshData();
    await _subscription?.cancel();
    _subscription = onChangeDB.stream.listen((event) {
      if (_isDisposed) {
        _subscription?.cancel();
        return;
      }
      if (event == T.toString()) {
        _refreshData();
      }
    });
  }

  /// Private method to refresh the data from the database.
  Future<void> _refreshData({Query? customQuery}) async {
    try {
      final query = customQuery ?? _buildQuery();
      final List<Map<String, dynamic>> maps = await _db.rawQuery<T>(query);
      _items = maps.map(
        (e) {
          return _mapper.decodeMap<T>(unflattenJson(e));
        },
      ).toList();
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  /// Private method to build the query based on the current controller state.
  Query _buildQuery() {
    final builder = _QueryBuilder(
      table: T.toString(),
      joins: controller._joins,
      whereGroups: controller._whereGroups,
      orderByFields: controller._orderByFields,
      limit: _limit,
      offset: _offset,
    );

    return builder.build();
  }

  /// Cleanup method that:
  /// - Cancels the database change subscription
  /// - Marks the listener as disposed
  /// - Calls the parent dispose method
  /// Ensures proper resource cleanup when the listener is no longer needed.
  /// @nodoc
  @override
  void dispose() {
    _subscription?.cancel();
    _isDisposed = true;
    super.dispose();
  }
}
