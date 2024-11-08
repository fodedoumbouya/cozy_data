// ignore_for_file: invalid_use_of_protected_member, use_string_in_part_of_directives

part of cozy_data;

/// A controller to manage and modify data queries for a [DataQueryListener].
///
/// {@template data_query_controller}
/// The [DataQueryController] provides an interface to interact with
/// a [DataQueryListener] instance, allowing control over the query builder
/// and refreshing data based on modified query conditions.
///
/// Use [applyQuery] to dynamically adjust the query with additional filters
/// or sort conditions, or call [refresh] to reload the data from the
/// underlying Isar collection. This class is generic and works with any data
/// model type `T`.
/// {@endtemplate}
class DataQueryController<T> {
  DataQueryListener<T>? _listener;

  /// Attaches a [DataQueryListener] to the controller.
  ///
  /// This private method is used internally by the [DataQueryListener]
  /// to associate itself with this controller, enabling control over
  /// its query and data refresh actions.
  void _attach(DataQueryListener<T> listener) {
    _listener = listener;
  }

  /// Provides access to the query builder from the attached listener.
  ///
  /// This allows external code to read the current query structure,
  /// useful for custom query manipulations or inspections.
  /// Throws an error if the controller is not attached to a listener.
  IsarQuery<T> get queryBuilder => _listener!._queryBuilder;

  /// Modifies the current query using [applyQuery] function.
  ///
  /// [applyQuery] is a function that receives the current query builder
  /// and returns a modified version of it. This allows dynamic
  /// reconfiguration of the query parameters, such as adding filters
  /// or adjusting sorting.
  ///
  /// After modifying the query, it triggers a data refresh to
  /// immediately reflect the updated results.
  ///
  /// Example:
  /// ```dart
  /// controller.applyQuery((queryBuilder) => queryBuilder.filter(...));
  ///                   or
  /// controller.applyQuery((queryBuilder) {
  ///   return queryBuilder.filter(..);
  /// });
  /// ```
  Future<void> applyFilterQueryPredicate(
      QueryBuilder<T, T, QAfterFilterCondition> Function(
              QueryBuilder<T, T, QAfterFilterCondition> queryBuilder)
          modifier) async {
    _listener!._queryBuilder = modifier(await _listener!._fetch()).build();
    await _refresh();
  }

  Future<void> applySortByQueryPredicate(
      QueryBuilder<T, T, QAfterSortBy> Function(
              QueryBuilder<T, T, QAfterFilterCondition> queryBuilder)
          modifier) async {
    _listener!._queryBuilder = modifier(await _listener!._fetch()).build();
    await _refresh();
  }

  Future<void> applyDistinctQueryPredicate(
      QueryBuilder<T, T, QAfterDistinct> Function(
              QueryBuilder<T, T, QAfterFilterCondition> queryBuilder)
          modifier) async {
    _listener!._queryBuilder = modifier(await _listener!._fetch()).build();
    await _refresh();
  }

  Future<void> applyPropertyQueryPredicate(
      QueryBuilder<T, T, QAfterProperty> Function(
              QueryBuilder<T, T, QAfterFilterCondition> queryBuilder)
          modifier) async {
    _listener!._queryBuilder = modifier(await _listener!._fetch()).build();
    await _refresh();
  }

  /// Refreshes the data from the current query without modifications.
  ///
  /// This is useful when data changes in the underlying collection,
  /// allowing the listener to reload and notify its observers.
  Future<void> _refresh() async {
    return await _listener!._refreshData();
  }
}
