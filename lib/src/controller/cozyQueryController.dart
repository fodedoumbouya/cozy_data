// ignore_for_file: invalid_use_of_protected_member, use_string_in_part_of_directives

part of cozy_data;

/// A controller to manage and modify data queries for a [CozyQueryListener].
///
/// {@template data_query_controller}
/// The [CozyQueryController] provides an interface to interact with
/// a [CozyQueryListener] instance, allowing control over the query builder
/// and refreshing data based on modified query conditions.
///
/// Use [queryPredicate] to dynamically adjust the query with additional filters,
/// sort conditions, or distinct conditions. This class is generic and works with any data
/// model type `T`.
/// {@endtemplate}
class CozyQueryController<T> {
  CozyQueryListener<T>? _listener;

  /// Attaches a [CozyQueryListener] to the controller.
  ///
  /// This private method is used internally by the [CozyQueryListener]
  /// to associate itself with this controller, enabling control over
  /// its query and data refresh actions.
  void _attach(CozyQueryListener<T> listener) {
    _listener = listener;
  }

  /// Provides access to the query builder from the attached listener.
  ///
  /// This allows external code to read the current query structure,
  /// useful for custom query manipulations or inspections.
  /// Throws an error if the controller is not attached to a listener.
  IsarQuery<T> get queryBuilder => _listener!._queryBuilder;

  /// Modifies the current query using [queryPredicate] function.
  ///
  /// [queryPredicate] allows dynamic reconfiguration of the query parameters,
  /// such as adding filters, adjusting sorting, or applying distinct conditions.
  ///
  /// After modifying the query, it triggers a data refresh to
  /// immediately reflect the updated results.
  ///
  /// Example:
  /// ```dart
  /// await controller.queryPredicate(
  ///   filterModifier: (filterQuery) =>
  ///    filterQuery.nameContains(value),
  ///    distinctModifier: (distinctQuery) =>
  ///    distinctQuery.distinctByName(),
  ///    sortModifier: (sortByQuery) => sortByQuery.sortByName(),
  ///    limit: 2,
  ///    offset: 0);
  /// ```
  Future<void> queryPredicate(
      {QueryBuilder<T, T, QAfterFilterCondition> Function(
              QueryBuilder<T, T, QAfterFilterCondition> filterQuery)?
          filterModifier,
      QueryBuilder<T, T, QAfterSortBy> Function(
              QueryBuilder<T, T, QAfterFilterCondition> sortByQuery)?
          sortModifier,
      QueryBuilder<T, T, QAfterDistinct> Function(
              QueryBuilder<T, T, QAfterFilterCondition> distinctQuery)?
          distinctModifier,
      int? limit,
      int? offset}) async {
    // Ensure that either distinctModifier or sortModifier is null, or both are null.
    // This assertion prevents both modifiers from being non-null simultaneously.
    assert(
        ((distinctModifier == null && sortModifier != null) ||
            (distinctModifier != null && sortModifier == null) ||
            (distinctModifier == null && sortModifier == null)),
        "distinctModifier and sortModifier must not be different from null at the same time");
    QueryBuilder<T, T, QAfterFilterCondition> query = await _listener!._fetch();
    if (sortModifier != null) {
      final qAfter = sortModifier(query);
      _listener!._queryBuilder = qAfter.build();
      query = QueryBuilder.apply<T, T, QAfterFilterCondition>(qAfter, (query) {
        return query;
      });
    }
    if (distinctModifier != null) {
      final qAfter = distinctModifier(query);
      _listener!._queryBuilder = qAfter.build();
      query = QueryBuilder.apply<T, T, QAfterFilterCondition>(qAfter, (query) {
        return query;
      });
    }
    if (filterModifier != null) {
      final qAfter = filterModifier(query);
      _listener!._queryBuilder = qAfter.build();
      query = QueryBuilder.apply<T, T, QAfterFilterCondition>(qAfter, (query) {
        return query;
      });
    }
    await _refresh(limit: limit, offset: offset);
  }

  /// Refreshes the data from the current query without modifications.
  ///
  /// This is useful when data changes in the underlying collection,
  /// allowing the listener to reload and notify its observers.
  Future<void> _refresh({int? limit, int? offset}) async {
    return await _listener!._refreshData(limit: limit, offset: offset);
  }
}
