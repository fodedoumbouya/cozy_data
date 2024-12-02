part of cozy_data;

/// A powerful, immutable query builder for constructing complex SQL queries in a type-safe, fluent manner
///
/// The [CozyQueryBuilder] provides a flexible and intuitive interface for building SQL queries
/// through method chaining. It supports sophisticated query construction with features like:
/// - Selective field retrieval
/// - Complex join operations
/// - Advanced filtering with predicate groups
/// - Aggregation and grouping
/// - Sorting and pagination
/// - Subquery integration
///
/// Key Design Principles:
/// 1. Immutability: Each method returns a new builder instance
/// 2. Type-safety: Generic typing ensures compile-time type checking
/// 3. Fluent Interface: Allows method chaining for readable query construction
///
/// Example Usage:
/// ```dart
/// final query = CozyQueryBuilder<User>()
///   .select(['id', 'name', 'email'])
///   .join(Join(
///     table: 'userRoles',
///     condition: 'users.id = userRoles.user_id',
///     type: JoinType.left
///   ))
///   .where(PredicateGroup(
///     predicates: [
///         Predicate.greaterThan('age', 18),
///         Predicate.equals('status', 'active')
///     ]
///   ))
///   .orderBy(OrderBy('name', OrderDirection.asc))
///   .setLimit(10)
///   .setOffset(0);
///
/// final result = query.build(); // Returns a Query object with SQL and arguments
/// ```
///
/// This comprehensive example demonstrates:
/// - Selecting specific fields
/// - Performing a left join
/// - Applying complex where conditions
/// - Sorting results
/// - Implementing pagination
class CozyQueryBuilder<T> {
  final List<Join> joins;
  final List<PredicateGroup> whereGroups;
  final List<String> selectFields;
  final List<String> groupByFields;
  final List<OrderBy> orderByFields;
  final List<Having> havingClauses;
  final int? limit;
  final int? offset;
  final Map<String, String> tableAliases;
  final List<Subquery> subqueries;

  /// Creates a new query builder with optional initial configuration
  ///
  /// Provides sensible defaults for all query components, allowing incremental
  /// query construction through method chaining.
  ///
  /// [joins]: Initial set of join operations
  /// [whereGroups]: Initial filtering conditions
  /// [selectFields]: Fields to retrieve in the query
  /// [groupByFields]: Fields for result aggregation
  /// [orderByFields]: Sorting specifications
  /// [havingClauses]: Post-aggregation filtering
  /// [limit]: Maximum number of results
  /// [offset]: Number of results to skip
  /// [tableAliases]: Custom table name mappings
  /// [subqueries]: Nested query operations
  CozyQueryBuilder({
    this.joins = const [],
    this.whereGroups = const [],
    this.selectFields = const [],
    this.groupByFields = const [],
    this.orderByFields = const [],
    this.havingClauses = const [],
    this.limit,
    this.offset,
    this.tableAliases = const {},
    this.subqueries = const [],
  });

  /// Select specific fields to retrieve in the query
  ///
  /// Allows fine-grained control over which columns are returned.
  /// If no fields are specified, defaults to selecting all fields (*).
  ///
  /// [fields]: List of field names to retrieve
  /// Returns a new query builder with updated select fields
  CozyQueryBuilder<T> select(List<String> fields) {
    return CozyQueryBuilder<T>(
      joins: joins,
      whereGroups: whereGroups,
      selectFields: fields,
      groupByFields: groupByFields,
      orderByFields: orderByFields,
      havingClauses: havingClauses,
      limit: limit,
      offset: offset,
      tableAliases: tableAliases,
      subqueries: subqueries,
    );
  }

  /// Add a join operation to the query
  ///
  /// Supports various join types (INNER, LEFT, RIGHT, FULL, CROSS)
  /// with custom join conditions and optional table aliases.
  ///
  /// [join]: Join configuration specifying table, condition, and type
  /// Returns a new query builder with the added join operation
  CozyQueryBuilder<T> join(Join join) {
    return CozyQueryBuilder<T>(
      joins: [...joins, join],
      whereGroups: whereGroups,
      selectFields: selectFields,
      groupByFields: groupByFields,
      orderByFields: orderByFields,
      havingClauses: havingClauses,
      limit: limit,
      offset: offset,
      tableAliases: tableAliases,
      subqueries: subqueries,
    );
  }

  /// Apply filtering conditions to the query
  ///
  /// Enables complex, nested filtering through predicate groups.
  /// Supports logical AND/OR combinations and multiple nested conditions.
  ///
  /// [predicateGroup]: A group of predicates defining query filters
  /// Returns a new query builder with added where conditions
  CozyQueryBuilder<T> where(PredicateGroup predicateGroup) {
    return CozyQueryBuilder<T>(
      joins: joins,
      whereGroups: [...whereGroups, predicateGroup],
      selectFields: selectFields,
      groupByFields: groupByFields,
      orderByFields: orderByFields,
      havingClauses: havingClauses,
      limit: limit,
      offset: offset,
      tableAliases: tableAliases,
      subqueries: subqueries,
    );
  }

  /// Group query results
  ///
  /// Used with aggregate functions to create summary or grouped results.
  ///
  /// [fields]: Fields to group results by
  /// Returns a new query builder with group by configuration
  CozyQueryBuilder<T> groupBy(List<String> fields) {
    return CozyQueryBuilder<T>(
      joins: joins,
      whereGroups: whereGroups,
      selectFields: selectFields,
      groupByFields: fields,
      orderByFields: orderByFields,
      havingClauses: havingClauses,
      limit: limit,
      offset: offset,
      tableAliases: tableAliases,
      subqueries: subqueries,
    );
  }

  /// Add HAVING clause for filtered aggregate results
  ///
  /// Applies conditions to grouped results after aggregation.
  ///
  /// [havingClause]: Condition to filter aggregated results
  /// Returns a new query builder with added HAVING condition
  CozyQueryBuilder<T> having(Having havingClause) {
    return CozyQueryBuilder<T>(
      joins: joins,
      whereGroups: whereGroups,
      selectFields: selectFields,
      groupByFields: groupByFields,
      orderByFields: orderByFields,
      havingClauses: [...havingClauses, havingClause],
      limit: limit,
      offset: offset,
      tableAliases: tableAliases,
      subqueries: subqueries,
    );
  }

  /// Specify result sorting order
  ///
  /// Supports multiple sorting criteria with options for:
  /// - Ascending/descending order
  /// - Null value positioning
  /// - Table-specific sorting
  ///
  /// [orderBy]: Sorting specification
  /// Returns a new query builder with added sorting
  CozyQueryBuilder<T> orderBy(OrderBy orderBy) {
    return CozyQueryBuilder<T>(
      joins: joins,
      whereGroups: whereGroups,
      selectFields: selectFields,
      groupByFields: groupByFields,
      orderByFields: [...orderByFields, orderBy],
      havingClauses: havingClauses,
      limit: limit,
      offset: offset,
      tableAliases: tableAliases,
      subqueries: subqueries,
    );
  }

  /// Set maximum number of results to retrieve
  ///
  /// Enables result pagination and limits query output.
  ///
  /// [value]: Maximum number of results
  /// Returns a new query builder with limit set
  CozyQueryBuilder<T> setLimit(int value) {
    return CozyQueryBuilder<T>(
      joins: joins,
      whereGroups: whereGroups,
      selectFields: selectFields,
      groupByFields: groupByFields,
      orderByFields: orderByFields,
      havingClauses: havingClauses,
      limit: value,
      offset: offset,
      tableAliases: tableAliases,
      subqueries: subqueries,
    );
  }

  /// Set number of results to skip
  ///
  /// Used in combination with [setLimit] for pagination.
  ///
  /// [value]: Number of results to skip
  /// Returns a new query builder with offset set
  CozyQueryBuilder<T> setOffset(int value) {
    return CozyQueryBuilder<T>(
      joins: joins,
      whereGroups: whereGroups,
      selectFields: selectFields,
      groupByFields: groupByFields,
      orderByFields: orderByFields,
      havingClauses: havingClauses,
      limit: limit,
      offset: value,
      tableAliases: tableAliases,
      subqueries: subqueries,
    );
  }

  /// Add table alias for complex queries
  ///
  /// Enables referencing tables with custom names in joins and conditions.
  ///
  /// [table]: Original table name
  /// [alias]: Custom alias for the table
  /// Returns a new query builder with added table alias
  CozyQueryBuilder<T> withAlias(String table, String alias) {
    return CozyQueryBuilder<T>(
      joins: joins,
      whereGroups: whereGroups,
      selectFields: selectFields,
      groupByFields: groupByFields,
      orderByFields: orderByFields,
      havingClauses: havingClauses,
      limit: limit,
      offset: offset,
      tableAliases: {...tableAliases, table: alias},
      subqueries: subqueries,
    );
  }

  /// Add a subquery to the main query
  ///
  /// Supports various subquery types like FROM, EXISTS, IN, etc.
  /// Enables complex query composition and nested data retrieval.
  ///
  /// [subquery]: Subquery configuration
  /// Returns a new query builder with added subquery
  CozyQueryBuilder<T> addSubquery(Subquery subquery) {
    return CozyQueryBuilder<T>(
      joins: joins,
      whereGroups: whereGroups,
      selectFields: selectFields,
      groupByFields: groupByFields,
      orderByFields: orderByFields,
      havingClauses: havingClauses,
      limit: limit,
      offset: offset,
      tableAliases: tableAliases,
      subqueries: [...subqueries, subquery],
    );
  }

  /// Create a deep copy of the current query builder
  ///
  /// Useful for creating query variations without modifying the original.
  /// Performs a deep copy of all mutable components.
  ///
  /// Returns a new query builder with identical configuration
  CozyQueryBuilder<T> clone() {
    return CozyQueryBuilder<T>(
      joins: List.from(joins),
      whereGroups: List.from(whereGroups),
      selectFields: List.from(selectFields),
      groupByFields: List.from(groupByFields),
      orderByFields: List.from(orderByFields),
      havingClauses: List.from(havingClauses),
      limit: limit,
      offset: offset,
      tableAliases: Map.from(tableAliases),
      subqueries: List.from(subqueries),
    );
  }

  /// Comprehensive Example Demonstrating Advanced Query Construction
  ///
  /// This example shows a complex query that combines multiple features:
  /// ```dart
  /// class User {
  ///   int id;
  ///   String name;
  ///   int age;
  ///   String status;
  ///   List<String> roles;
  /// User({this.id, this.name, this.age, this.status, this.roles});
  /// }
  ///
  /// void exampleQueryUsage() {
  /// final complexUserQuery = CozyQueryBuilder<User>()
  ///     // Select specific fields
  ///     .select(['id', 'name', 'email'])
  ///     // Left join with user roles
  ///     .join(Join(
  ///       table: 'userRoles',
  ///       condition: 'users.id = userRoles.user_id',
  ///       type: JoinType.left
  ///     ))
  ///     // Complex filtering with nested conditions
  ///     .where(PredicateGroup(
  ///       type: PredicateGroupType.and,
  ///       predicates: [
  ///         Predicate.greaterThan('age', 18),
  ///         Predicate.equals('status', 'active')
  ///       ],
  ///       subgroups: [
  ///         PredicateGroup(
  ///           type: PredicateGroupType.or,
  ///           predicates: [
  ///             Predicate.arrayContains("roles", "admin"),
  ///             Predicate.arrayContains("roles", "manager"),
  ///           ]
  ///         )
  ///       ]
  ///     ))
  ///     // Group by specific fields
  ///     .groupBy(['status'])
  ///     // Having clause for aggregated results
  ///     .having(Having(
  ///       condition: 'COUNT(*) > ?',
  ///       arguments: [5]
  ///     ))
  ///     // Sorting and pagination
  ///     .orderBy(OrderBy('name', OrderDirection.asc))
  ///     .setLimit(10)
  ///     .setOffset(20);
  ///
  ///   // Build the final query
  ///   final queryResult = complexUserQuery.build();
  ///   print(queryResult.sql);    // Prints generated SQL
  ///   print(queryResult.arguments); // Prints query parameters
  /// }
  /// ```
  ///
  /// This example demonstrates the power and flexibility of the [CozyQueryBuilder],
  /// showing how complex queries can be constructed in a readable, type-safe manner.
}
