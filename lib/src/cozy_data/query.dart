part of cozy_data;

/// A query representation for SQLite database operations.
///
/// This file provides classes and utilities for building SQL queries in a type-safe
/// and structured manner. It supports various SQL operations including SELECT, JOIN,
/// WHERE conditions, and ORDER BY clauses.
///
/// The main components are:
/// * [Query] - Represents a complete SQL query with its arguments
/// * [_QueryBuilder] - Internal builder class for constructing SQL queries
///
///
/// The query builder supports various SQL operations including:
/// * Basic comparisons (=, !=, >, <, >=, <=)
/// * String operations (LIKE, NOT LIKE, REGEXP)
/// * Case-insensitive string operations
/// * Range operations (BETWEEN, NOT BETWEEN)
/// * Collection operations (IN, NOT IN)
/// * Array operations (JSON array functions)
/// * Date operations
/// * Numeric operations
/// * Full-text search
///
/// Key classes and their purposes:
///
/// [Query]
/// Represents a complete SQL query with its parameters.
/// - [sql]: The SQL query string
/// - [arguments]: List of arguments to be bound to the query
///
/// [_QueryBuilder]
/// Internal builder class for constructing SQL queries.
/// - [table]: The main table to query from
/// - [joins]: List of JOIN operations
/// - [whereGroups]: List of WHERE conditions grouped by AND/OR
/// - [orderByFields]: List of ORDER BY fields
/// - [limit]: Optional LIMIT clause
/// - [offset]: Optional OFFSET clause
///
/// Methods:
/// [_processPredicateArguments]
/// Processes arguments for a single predicate based on its operator.
/// Returns the appropriate argument list for the SQL query.
///
/// [_getOperatorSql]
/// Generates the SQL fragment for a specific predicate operator.
/// Handles various types of operators and their SQL representations.
///
/// [_processPredicateGroup]
/// Processes a group of predicates and their relationships.
/// Returns a tuple of SQL fragment and its arguments.
///
/// [_escapeLikePattern]
/// Escapes special characters in LIKE patterns to prevent SQL injection.
///
/// [_formatDate]
/// Formats DateTime objects for SQL compatibility.
///
/// [build]
/// Constructs the final SQL query by combining all components.
/// Returns a [Query] object with the complete SQL and its arguments.
///
/// Note: This implementation uses SQLite-specific SQL syntax and functions.
/// Modify the SQL generation if using with other database systems.
class Query {
  final String sql;
  final List<dynamic> arguments;

  Query(this.sql, this.arguments);
}

class _QueryBuilder {
  final String table;
  final List<Join> joins;
  final List<PredicateGroup> whereGroups;
  final List<OrderBy> orderByFields;
  final int? limit;
  final int? offset;

  _QueryBuilder({
    required this.table,
    this.joins = const [],
    this.whereGroups = const [],
    this.orderByFields = const [],
    this.limit,
    this.offset,
  });

  /// Process a single predicate and return its arguments
  List<dynamic> _processPredicateArguments(Predicate predicate) {
    switch (predicate.operator) {
      // String operations with wildcards
      case PredicateOperator.contains:
      case PredicateOperator.iContains:
        return ['%${_escapeLikePattern(predicate.value)}%'];

      case PredicateOperator.startsWith:
      case PredicateOperator.iStartsWith:
        return ['${_escapeLikePattern(predicate.value)}%'];

      case PredicateOperator.endsWith:
      case PredicateOperator.iEndsWith:
        return ['%${_escapeLikePattern(predicate.value)}'];

      case PredicateOperator.notContains:
        return ['%${_escapeLikePattern(predicate.value)}%'];

      // Range operations
      case PredicateOperator.between:
      case PredicateOperator.notBetween:
        return [predicate.value, predicate.secondValue];

      // Date range operations
      case PredicateOperator.dateBetween:
        return [
          _formatDate(predicate.value),
          _formatDate(predicate.secondValue),
        ];

      // Date operations
      case PredicateOperator.dateEquals:
      case PredicateOperator.dateBefore:
      case PredicateOperator.dateAfter:
      case PredicateOperator.dateOnOrBefore:
      case PredicateOperator.dateOnOrAfter:
        return [_formatDate(predicate.value)];

      // List operations
      case PredicateOperator.in_:
      case PredicateOperator.notIn:
        return (predicate.value as List).toList();

      // Array operations
      case PredicateOperator.arrayContainsAny:
        // Return the values directly instead of JSON encoding them
        return (predicate.value as List).toList();

      case PredicateOperator.arrayContains:
        return [predicate.value];

      case PredicateOperator.arrayContainsAll:
        return (predicate.value as List).toList();

      // Operations with no arguments
      case PredicateOperator.isNull:
      case PredicateOperator.isNotNull:
      case PredicateOperator.arrayIsEmpty:
      case PredicateOperator.arrayIsNotEmpty:
      case PredicateOperator.isEven:
      case PredicateOperator.isOdd:
        return [];

      // Numeric operations
      case PredicateOperator.isDivisibleBy:
        return [predicate.value];

      // Full text search
      case PredicateOperator.fullTextMatch:
        return [predicate.value];

      // Default case for simple single-value operations
      default:
        return predicate.value != null ? [predicate.value] : [];
    }
  }

  String _getOperatorSql(Predicate predicate, String field) {
    final operator = predicate.operator;
    switch (operator) {
      // Basic comparison
      case PredicateOperator.equals:
        return '$field = ?';
      case PredicateOperator.notEquals:
        return '$field != ?';
      case PredicateOperator.greaterThan:
        return '$field > ?';
      case PredicateOperator.lessThan:
        return '$field < ?';
      case PredicateOperator.greaterThanOrEquals:
        return '$field >= ?';
      case PredicateOperator.lessThanOrEquals:
        return '$field <= ?';

      // Null checks
      case PredicateOperator.isNull:
        return '$field IS NULL';
      case PredicateOperator.isNotNull:
        return '$field IS NOT NULL';

      // String operations
      case PredicateOperator.contains:
        return '$field LIKE ?';
      case PredicateOperator.notContains:
        return '$field NOT LIKE ?';
      case PredicateOperator.startsWith:
        return '$field LIKE ?';
      case PredicateOperator.endsWith:
        return '$field LIKE ?';
      case PredicateOperator.matches:
        return '$field REGEXP ?';

      // Case-insensitive string operations
      case PredicateOperator.iEquals:
        return 'LOWER($field) = LOWER(?)';
      case PredicateOperator.iContains:
        return 'LOWER($field) LIKE LOWER(?)';
      case PredicateOperator.iStartsWith:
        return 'LOWER($field) LIKE LOWER(?)';
      case PredicateOperator.iEndsWith:
        return 'LOWER($field) LIKE LOWER(?)';

      // Range operations
      case PredicateOperator.between:
        return '$field BETWEEN ? AND ?';
      case PredicateOperator.notBetween:
        return '$field NOT BETWEEN ? AND ?';

      // Collection operations
      case PredicateOperator.in_:
        return '$field IN (?)';
      case PredicateOperator.notIn:
        return '$field NOT IN (?)';

      // Array operations
      case PredicateOperator.arrayContains:
        return '''
        JSON_TYPE($field) IS NOT NULL 
        AND EXISTS (
          SELECT 1 FROM JSON_EACH($field) 
          WHERE value IN (?)
        )
      ''';
      case PredicateOperator.arrayContainsAny:
        // Get the list length from the value to create the right number of placeholders
        final valuesList = (predicate.value as List);
        final placeholders = List.filled(valuesList.length, '?').join(',');
        return '''
        JSON_TYPE($field) IS NOT NULL 
        AND EXISTS (
          SELECT 1 FROM JSON_EACH($field) 
          WHERE value IN ($placeholders)
        )
      ''';

      case PredicateOperator.arrayContainsAll:
        final valuesList = (predicate.value as List);
        final placeholders = List.filled(valuesList.length, '?').join(',');
        return '''
        JSON_TYPE($field) IS NOT NULL 
        AND (
          SELECT COUNT(DISTINCT value) 
          FROM JSON_EACH($field) 
          WHERE value IN ($placeholders)
        ) = ${valuesList.length}
      ''';

      case PredicateOperator.arrayIsEmpty:
        // Check if array is empty or null
        return '($field IS NULL OR JSON_TYPE($field) IS NULL OR JSON_ARRAY_LENGTH($field) = 0)';

      case PredicateOperator.arrayIsNotEmpty:
        // Check if array has elements
        return 'JSON_TYPE($field) IS NOT NULL AND JSON_ARRAY_LENGTH($field) > 0';

      // Date operations
      case PredicateOperator.dateEquals:
        return 'DATE($field) = DATE(?)';
      case PredicateOperator.dateBefore:
        return 'DATE($field) < DATE(?)';
      case PredicateOperator.dateAfter:
        return 'DATE($field) > DATE(?)';
      case PredicateOperator.dateOnOrBefore:
        return 'DATE($field) <= DATE(?)';
      case PredicateOperator.dateOnOrAfter:
        return 'DATE($field) >= DATE(?)';
      case PredicateOperator.dateBetween:
        return 'DATE($field) BETWEEN DATE(?) AND DATE(?)';

      // Numeric operations
      case PredicateOperator.isEven:
        return 'MOD($field, 2) = 0';
      case PredicateOperator.isOdd:
        return 'MOD($field, 2) = 1';
      case PredicateOperator.isDivisibleBy:
        return 'MOD($field, ?) = 0';

      // Full text search
      case PredicateOperator.fullTextMatch:
        return 'MATCH($field) AGAINST(? IN NATURAL LANGUAGE MODE)';
    }
  }

  /// Process a predicate group and return its SQL and arguments
  (String, List<dynamic>) _processPredicateGroup(PredicateGroup group) {
    final conditions = <String>[];
    final arguments = <dynamic>[];

    for (final predicate in group.predicates) {
      final field = predicate.table != null
          ? '${predicate.table}.${predicate.field}'
          : predicate.field;

      final predicateArgs = _processPredicateArguments(predicate);
      final sql = _getOperatorSql(predicate, field);

      if (sql.isNotEmpty) {
        conditions.add(sql);
        arguments.addAll(predicateArgs);
      }
    }

    // Process subgroups
    for (final subgroup in group.subgroups) {
      final (subSql, subArgs) = _processPredicateGroup(subgroup);
      if (subSql.isNotEmpty) {
        conditions.add('($subSql)');
        arguments.addAll(subArgs);
      }
    }

    return (conditions.join(' ${group.type.name} '), arguments);
  }

  /// Escape special characters in LIKE patterns
  String _escapeLikePattern(String pattern) {
    return pattern
        .replaceAll('\\', '\\\\')
        .replaceAll('%', '\\%')
        .replaceAll('_', '\\_');
  }

  /// Format date for SQL
  String _formatDate(DateTime date) {
    return date.toUtc().toIso8601String();
  }

  Query build() {
    final parts = <String>[];
    final arguments = <dynamic>[];

    // SELECT clause
    parts.add('SELECT *');

    // FROM clause
    parts.add('FROM $table');

    // JOIN clauses
    for (final join in joins) {
      parts.add(join.build());
      arguments.addAll(join.arguments);
    }

    // WHERE clause
    if (whereGroups.isNotEmpty) {
      final whereConditions = whereGroups.map((group) {
        final (sql, args) = _processPredicateGroup(group);
        arguments.addAll(args);
        return '($sql)';
      }).join(' AND ');

      if (whereConditions.isNotEmpty) {
        parts.add('WHERE $whereConditions');
      }
    }

    // ORDER BY clause
    if (orderByFields.isNotEmpty) {
      final orderClause = orderByFields.map((f) {
        final field = f.table != null ? '${f.table}.${f.field}' : f.field;
        final nulls = f.nullsFirst ? 'NULLS FIRST' : 'NULLS LAST';
        return '$field ${f.direction.name} $nulls';
      }).join(', ');
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
