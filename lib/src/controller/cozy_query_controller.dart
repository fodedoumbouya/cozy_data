part of cozy_data;

/// The `CozyQueryController` class manages query operations for a `CozyQueryListener`.
/// It allows adding where conditions, joins, order by fields, and custom queries to the listener.
///
/// Example usage:
/// ```dart
/// final controller = CozyQueryController<MyModel>();
/// await controller.addWhere([PredicateGroup(predicates: [Predicate.equals('field', 'value')])]);
/// await controller.addJoin([Join(table: 'other_table', condition: 'other_table.id = my_table.other_id')]);
/// await controller.orderBy([OrderBy(field: 'created_at', direction: OrderDirection.desc)]);
/// await controller.addCustomQuery(CozyQueryBuilder<MyModel>());
/// await controller.reset();
/// ```
class CozyQueryController<T> {
  CozyQueryListener<T>? _listener;
  List<PredicateGroup> _whereGroups = [];
  List<Join> _joins = [];
  List<OrderBy> _orderByFields = [];

  /// Attaches the controller to a `CozyQueryListener`.
  /// This method is called internally when the controller is set on the listener.
  void _attach(CozyQueryListener<T> listener) {
    _listener = listener;
  }

  /// Adds where conditions to the query and refreshes the data.
  ///
  /// Example usage:
  /// ```dart
  /// await controller.addWhere([PredicateGroup(predicates: [Predicate.equals('field', 'value')])]);
  /// ```
  /// shouldCleanAfterQuery: If true, the where conditions will be cleared after the query is executed.
  /// This is useful for one-time queries where the where conditions are not needed after the query.
  Future<void> addWhere(List<PredicateGroup> groups,
      {bool shouldCleanAfterQuery = false}) async {
    _whereGroups = groups;
    await _listener?._refreshData();
    if (shouldCleanAfterQuery) {
      _whereGroups.clear();
    }
  }

  /// Adds joins to the query and refreshes the data.
  ///
  /// Example usage:
  /// ```dart
  /// await controller.addJoin([Join(table: 'other_table', condition: 'other_table.id = my_table.other_id')]);
  /// ```
  /// shouldCleanAfterQuery: If true, the where conditions will be cleared after the query is executed.
  /// This is useful for one-time queries where the joins are not needed after the query.
  Future<void> addJoin(List<Join> joins,
      {bool shouldCleanAfterQuery = false}) async {
    _joins = joins;
    await _listener?._refreshData();
    if (shouldCleanAfterQuery) {
      _joins.clear();
    }
  }

  /// Adds order by fields to the query and refreshes the data.
  ///
  /// Example usage:
  /// ```dart
  /// await controller.orderBy([OrderBy(field: 'created_at', direction: OrderDirection.desc)]);
  /// ```
  /// shouldCleanAfterQuery: If true, the where conditions will be cleared after the query is executed.
  /// This is useful for one-time queries where the order by fields are not needed after the query.
  Future<void> orderBy(List<OrderBy> orderByFields,
      {bool shouldCleanAfterQuery = false}) async {
    _orderByFields = orderByFields;
    await _listener?._refreshData();
    if (shouldCleanAfterQuery) {
      _orderByFields.clear();
    }
  }

  /// Adds a custom query to the listener and refreshes the data.
  ///
  /// Example usage:
  /// ```dart
  ///   final cozyBuilder = CozyQueryBuilder<User>()
  ///   .select(['id', 'name', 'email'])
  ///   .join(Join(
  ///     table: 'userRoles',
  ///     condition: 'users.id = userRoles.user_id',
  ///     type: JoinType.left
  ///   ))
  ///   .where(PredicateGroup(
  ///     predicates: [
  ///      Predicate.greaterThan('age', 18),
  ///     Predicate.equals('status', 'active')
  ///     ]
  ///   ))
  ///   .orderBy(OrderBy('name', OrderDirection.asc))
  ///   .setLimit(10)
  ///   .setOffset(0);
  /// await controller.addCustomQuery(cozyBuilder);
  /// ```
  Future<void> addCustomQuery(CozyQueryBuilder<T> query) async {
    if (T == dynamic) {
      throw Exception(
          'Cannot query without model Data Type. Please provide a concrete model type.\nExample: CozyData.query<ModelData>()');
    }
    await _listener?._refreshData(customQuery: query.build());
  }

  /// Resets all query conditions and refreshes the data.
  ///
  /// Example usage:
  /// ```dart
  /// await controller.reset();
  /// ```
  Future<void> reset() async {
    _joins.clear();
    _whereGroups.clear();
    _orderByFields.clear();
    await _listener?._refreshData();
  }
}
