part of cozy_data;

/// Represents a SQL Join operation with flexible configuration options
///
/// The [Join] class allows developers to create different types of SQL joins with custom conditions
/// and optional table aliases. It supports multiple join types and handles complex joining scenarios.
///
/// Example usage:
/// ```dart
/// final userRoleJoin = Join(
///   table: 'user_roles',
///   condition: 'users.id = user_roles.user_id',
///   type: JoinType.left
/// );
/// ```

class Join {
  final String table;
  final String condition;
  final JoinType type;
  final List<dynamic> arguments;
  final String? alias;

  Join({
    required this.table,
    required this.condition,
    this.type = JoinType.inner,
    this.arguments = const [],
    this.alias,
  });

  String build() {
    final tableClause = alias != null ? '$table AS $alias' : table;
    return '${type.name} JOIN $tableClause ON $condition';
  }
}

/// Defines the types of SQL joins available in the query builder
///
/// Provides a type-safe enumeration of standard SQL join types:
/// - INNER: Returns matching records from both tables
/// - LEFT: Returns all records from the left table and matched records from the right
/// - RIGHT: Returns all records from the right table and matched records from the left
/// - FULL: Returns all records when there's a match in either table
/// - CROSS: Cartesian product of both tables
enum JoinType {
  inner('INNER'),
  left('LEFT'),
  right('RIGHT'),
  full('FULL'),
  cross('CROSS');

  final String name;
  const JoinType(this.name);
}

/// A powerful predicate grouping mechanism for complex WHERE clause construction
///
/// [PredicateGroup] allows nested and complex logical conditions with AND/OR operations.
/// It supports combining multiple predicates and nested predicate groups, enabling
/// sophisticated query filtering strategies.
///
/// Example usage:
/// ```dart
/// final complexFilter = PredicateGroup(
///   type: PredicateGroupType.and,
///   predicates: [
///     Predicate(field: 'age', operator: PredicateOperator.greaterThan, value: 18),
///     Predicate(field: 'status', operator: PredicateOperator.equals, value: 'active')
///   ],
///   subgroups: [
///     PredicateGroup(
///       type: PredicateGroupType.or,
///       predicates: [
///         Predicate(field: 'department', operator: PredicateOperator.equals, value: 'Sales'),
///         Predicate(field: 'department', operator: PredicateOperator.equals, value: 'Marketing')
///       ]
///     )
///   ]
/// );
/// ```
class PredicateGroup {
  final List<Predicate> predicates;
  final PredicateGroupType type;
  final List<PredicateGroup> subgroups;

  const PredicateGroup({
    this.predicates = const [],
    this.type = PredicateGroupType.and,
    this.subgroups = const [],
  });

  List<dynamic> get arguments {
    final predicateArgs = predicates.expand((p) => [
          if (p.value != null) p.value,
          if (p.secondValue != null) p.secondValue,
        ]);

    final subgroupArgs = subgroups.expand((g) => g.arguments);

    return [...predicateArgs, ...subgroupArgs];
  }

  String build() {
    final conditions = <String>[];

    for (final predicate in predicates) {
      final field = predicate.field;

      switch (predicate.operator) {
        // Basic comparison operators
        case PredicateOperator.equals:
          conditions.add('$field = ?');
        case PredicateOperator.notEquals:
          conditions.add('$field != ?');
        case PredicateOperator.greaterThan:
          conditions.add('$field > ?');
        case PredicateOperator.lessThan:
          conditions.add('$field < ?');
        case PredicateOperator.greaterThanOrEquals:
          conditions.add('$field >= ?');
        case PredicateOperator.lessThanOrEquals:
          conditions.add('$field <= ?');

        // Null checks
        case PredicateOperator.isNull:
          conditions.add('$field IS NULL');
        case PredicateOperator.isNotNull:
          conditions.add('$field IS NOT NULL');

        // String operations
        case PredicateOperator.contains:
          conditions.add('$field LIKE ?');
        // Note: The value should be wrapped with % in the query builder
        case PredicateOperator.notContains:
          conditions.add('$field NOT LIKE ?');
        case PredicateOperator.startsWith:
          conditions.add('$field LIKE ?');
        // Note: The value should be appended with % in the query builder
        case PredicateOperator.endsWith:
          conditions.add('$field LIKE ?');
        // Note: The value should be prepended with % in the query builder
        case PredicateOperator.matches:
          conditions.add('$field REGEXP ?');

        // Case-insensitive string operations
        case PredicateOperator.iEquals:
          conditions.add('LOWER($field) = LOWER(?)');
        case PredicateOperator.iContains:
          conditions.add('LOWER($field) LIKE LOWER(?)');
        case PredicateOperator.iStartsWith:
          conditions.add('LOWER($field) LIKE LOWER(?)');
        case PredicateOperator.iEndsWith:
          conditions.add('LOWER($field) LIKE LOWER(?)');

        // Range operations
        case PredicateOperator.between:
          conditions.add('$field BETWEEN ? AND ?');
        case PredicateOperator.notBetween:
          conditions.add('$field NOT BETWEEN ? AND ?');

        // Collection operations
        case PredicateOperator.in_:
          final placeholders =
              List.filled((predicate.value as List).length, '?').join(',');
          conditions.add('$field IN ($placeholders)');
        case PredicateOperator.notIn:
          final placeholders =
              List.filled((predicate.value as List).length, '?').join(',');
          conditions.add('$field NOT IN ($placeholders)');

        // Array operations
        case PredicateOperator.arrayContains:
          conditions.add('JSON_CONTAINS($field, JSON_ARRAY(?))');
        case PredicateOperator.arrayContainsAny:
          conditions.add('JSON_OVERLAPS($field, JSON_ARRAY(?))');
        case PredicateOperator.arrayContainsAll:
          conditions.add('(JSON_CONTAINS($field, JSON_ARRAY(?)) = 1)');

        case PredicateOperator.arrayIsEmpty:
          conditions.add('(JSON_LENGTH($field) = 0 OR $field IS NULL)');
        case PredicateOperator.arrayIsNotEmpty:
          conditions.add('(JSON_LENGTH($field) > 0)');

        // Date operations
        case PredicateOperator.dateEquals:
          conditions.add('DATE($field) = DATE(?)');
        case PredicateOperator.dateBefore:
          conditions.add('DATE($field) < DATE(?)');
        case PredicateOperator.dateAfter:
          conditions.add('DATE($field) > DATE(?)');
        case PredicateOperator.dateOnOrBefore:
          conditions.add('DATE($field) <= DATE(?)');
        case PredicateOperator.dateOnOrAfter:
          conditions.add('DATE($field) >= DATE(?)');
        case PredicateOperator.dateBetween:
          conditions.add('DATE($field) BETWEEN DATE(?) AND DATE(?)');

        // Numeric operations
        case PredicateOperator.isEven:
          conditions.add('MOD($field, 2) = 0');
        case PredicateOperator.isOdd:
          conditions.add('MOD($field, 2) = 1');
        case PredicateOperator.isDivisibleBy:
          conditions.add('MOD($field, ?) = 0');

        // Full text search
        case PredicateOperator.fullTextMatch:
          conditions.add('MATCH($field) AGAINST(? IN NATURAL LANGUAGE MODE)');
      }
    }

    // Add subgroups
    for (final subgroup in subgroups) {
      conditions.add('(${subgroup.build()})');
    }

    return conditions.join(' ${type.name} ');
  }
}

/// Defines the logical grouping type for predicates
///
/// Allows specifying how multiple predicates should be combined in a query
/// using AND or OR operations. This enum provides a type-safe way to define
enum PredicateGroupType {
  and('AND'), // Requires all conditions to be true
  or('OR'); // Requires at least one condition to be true

  final String name;
  const PredicateGroupType(this.name);
}

/// Handles ORDER BY clause generation with advanced sorting options
///
/// [OrderBy] provides flexible sorting capabilities, including:
/// - Table-specific sorting
/// - Ascending/Descending order
/// - Null value positioning
///
/// Example usage:
/// ```dart
/// final nameOrder = OrderBy('name', OrderDirection.asc,
///   table: 'users',
///   nullsFirst: true
/// );
/// ```
class OrderBy {
  final String field;
  final OrderDirection direction;
  final String? table;
  final bool nullsFirst;

  OrderBy(
    this.field,
    this.direction, {
    this.table,
    this.nullsFirst = false,
  });

  String build() {
    final fieldName = table != null ? '$table.$field' : field;
    final nullsOrder = nullsFirst ? 'NULLS FIRST' : 'NULLS LAST';
    return '$fieldName ${direction.name} $nullsOrder';
  }
}

/// Defines sort direction for OrderBy clauses
enum OrderDirection {
  asc('ASC'), // Sort in ascending order
  desc('DESC'); // Sort in descending order

  final String name;
  const OrderDirection(this.name);
}

/// Provides HAVING clause support for aggregate query filtering
///
/// [Having] allows filtering on aggregated results after GROUP BY operations
///
/// Example usage:
/// ```dart
/// final aggregateFilter = Having(
///   condition: 'COUNT(orders) > ?',
///   arguments: [5],
///   type: HavingType.and
/// );
/// ```
class Having {
  final String condition;
  final List<dynamic> arguments;
  final HavingType type;

  Having({
    required this.condition,
    this.arguments = const [],
    this.type = HavingType.and,
  });

  String build() => condition;
}

/// Defines logical combination type for HAVING clauses
enum HavingType {
  and('AND'),
  or('OR');

  final String name;
  const HavingType(this.name);
}

/// Advanced subquery support with multiple integration modes
///
/// [Subquery] enables complex query composition, supporting various subquery types:
/// - FROM: Use as a data source
/// - EXISTS/NOT EXISTS: Conditional subquery checks
/// - IN/NOT IN: Membership testing
///
/// Example usage:
/// ```dart
/// final activeUserSubquery = Subquery(
///   builder: CozyQueryBuilder<User>()
///     ..where(PredicateGroup(
///       predicates: [
///         Predicate(field: 'status', operator: PredicateOperator.equals, value: 'active')
///       ]
///     )),
///   alias: 'active_users',
///   type: SubqueryType.from
/// );
/// ```
class Subquery {
  final CozyQueryBuilder builder;
  final String alias;
  final SubqueryType type;

  Subquery({
    required this.builder,
    required this.alias,
    this.type = SubqueryType.from,
  });

  String build() {
    final query = builder.build();
    switch (type) {
      case SubqueryType.from:
        return '(${query.sql}) AS $alias';
      case SubqueryType.exists:
        return 'EXISTS (${query.sql})';
      case SubqueryType.notExists:
        return 'NOT EXISTS (${query.sql})';
      case SubqueryType.in_:
        return 'IN (${query.sql})';
      case SubqueryType.notIn:
        return 'NOT IN (${query.sql})';
    }
  }

  List<dynamic> get arguments => builder.build().arguments;
}

/// Defines the integration mode for subqueries
enum SubqueryType {
  from, // Use as a data source
  exists, // check for existence
  notExists, // check for non-existence
  in_, // membership test
  notIn, // non-membership test
}

/// Query builder extension providing comprehensive SQL query generation
///
/// Converts the fluent query builder configuration into a complete SQL query
/// with parameter management and clause generation
extension QueryBuilderExtension<T> on CozyQueryBuilder<T> {
  Query build() {
    final parts = <String>[];
    final arguments = <dynamic>[];

    // SELECT clause
    final selectClause = selectFields.isEmpty ? '*' : selectFields.join(', ');
    parts.add('SELECT $selectClause');

    // FROM clause with subqueries
    parts.add('FROM ${T.toString()}');

    // Add subqueries
    for (final subquery in subqueries) {
      if (subquery.type == SubqueryType.from) {
        parts.add(', ${subquery.build()}');
        arguments.addAll(subquery.arguments);
      }
    }

    // JOIN clauses
    for (final join in joins) {
      parts.add(join.build());
      arguments.addAll(join.arguments);
    }

    // WHERE clause
    if (whereGroups.isNotEmpty) {
      final whereClause =
          whereGroups.map((group) => '(${group.build()})').join(' AND ');
      parts.add('WHERE $whereClause');
      arguments.addAll(whereGroups.expand((group) => group.arguments));
    }

    // GROUP BY clause
    if (groupByFields.isNotEmpty) {
      parts.add('GROUP BY ${groupByFields.join(', ')}');
    }

    // HAVING clause
    if (havingClauses.isNotEmpty) {
      final havingClause = havingClauses
          .map((h) => h.build())
          .join(' ${havingClauses[0].type.name} ');
      parts.add('HAVING $havingClause');
      arguments.addAll(havingClauses.expand((h) => h.arguments));
    }

    // ORDER BY clause
    if (orderByFields.isNotEmpty) {
      final orderClause = orderByFields.map((f) => f.build()).join(', ');
      parts.add('ORDER BY $orderClause');
    }

    // LIMIT and OFFSET
    if (limit != null) {
      parts.add('LIMIT $limit');
      if (offset != null) {
        parts.add('OFFSET $offset');
      }
    }

    return Query(parts.join(' '), arguments);
  }
}
