part of cozy_data;

/// A class that represents a predicate for querying data in a database.
///
/// Predicates are used to build query conditions for filtering data. They support various
/// comparison operators, string operations, range checks, collection operations, array operations,
/// date operations, and numeric operations.
///
/// ## Basic Usage
///
/// ```dart
/// // Basic comparison
/// final equalsPredicate = Predicate.equals('age', 25);
/// final greaterThanPredicate = Predicate.greaterThan('price', 100.0);
///
/// // String operations
/// final containsPredicate = Predicate.contains('name', 'John');
/// final startsWithPredicate = Predicate.startsWith('email', 'john');
///
/// // Range operations
/// final betweenPredicate = Predicate.between('price', 10, 100);
///
/// // Collection operations
/// final inPredicate = Predicate.in_('status', ['active', 'pending']);
///
/// // Array operations
/// final arrayContainsPredicate = Predicate.arrayContains('tags', 'urgent');
///
/// // Date operations
/// final datePredicate = Predicate.dateBefore('createdAt', DateTime.now());
///
/// // Numeric operations
/// final evenPredicate = Predicate.isEven('count');
/// ```
///
/// ## Fields
///
/// * [field] - The name of the field to apply the predicate on
/// * [operator] - The type of operation to perform
/// * [value] - The primary value to compare against
/// * [secondValue] - The secondary value (used in operations like between)
/// * [table] - Optional table name for join operations
///
/// ## Categories of Operations
///
/// ### Basic Comparison Operators
/// * [equals] - Checks if field equals value
/// * [notEquals] - Checks if field does not equal value
/// * [greaterThan] - Checks if field is greater than value
/// * [lessThan] - Checks if field is less than value
/// * [greaterThanOrEquals] - Checks if field is greater than or equal to value
/// * [lessThanOrEquals] - Checks if field is less than or equal to value
///
/// ### Null Checks
/// * [isNull] - Checks if field is null
/// * [isNotNull] - Checks if field is not null
///
/// ### String Operations
/// * [contains] - Checks if field contains value
/// * [notContains] - Checks if field does not contain value
/// * [startsWith] - Checks if field starts with value
/// * [endsWith] - Checks if field ends with value
/// * [matches] - Checks if field matches regular expression pattern
///
/// ### Case-Insensitive String Operations
/// * [iEquals] - Case-insensitive equality check
/// * [iContains] - Case-insensitive contains check
/// * [iStartsWith] - Case-insensitive starts with check
/// * [iEndsWith] - Case-insensitive ends with check
///
/// ### Range Operations
/// * [between] - Checks if field is between start and end values
/// * [notBetween] - Checks if field is not between start and end values
///
/// ### Collection Operations
/// * [in_] - Checks if field value is in list of values
/// * [notIn] - Checks if field value is not in list of values
///
/// ### Array Operations
/// * [arrayContains] - Checks if array field contains single value
/// * [arrayContainsAny] - Checks if array field contains any of the values
/// * [arrayContainsAll] - Checks if array field contains all values
/// * [arrayIsEmpty] - Checks if array field is empty
/// * [arrayIsNotEmpty] - Checks if array field is not empty
///
/// ### Date Operations
/// * [dateEquals] - Checks if date field equals value
/// * [dateBefore] - Checks if date field is before value
/// * [dateAfter] - Checks if date field is after value
/// * [dateOnOrBefore] - Checks if date field is on or before value
/// * [dateOnOrAfter] - Checks if date field is on or after value
/// * [dateBetween] - Checks if date field is between start and end dates
///
/// ### Numeric Operations
/// * [isEven] - Checks if numeric field is even
/// * [isOdd] - Checks if numeric field is odd
/// * [isDivisibleBy] - Checks if numeric field is divisible by value
///
/// ### Full Text Search
/// * [fullTextMatch] - Performs full-text search on field
///
/// ## Example with Complex Query
///
/// ```dart
/// void main() {
///   // Query for active users aged between 18 and 65
///   // with email containing '@company.com'
///   // and having 'developer' tag
///   final predicates = [
///     Predicate.equals('status', 'active'),
///     Predicate.between('age', 18, 65),
///     Predicate.contains('email', '@company.com'),
///     Predicate.arrayContains('tags', 'developer')
///   ];
///
///   // These predicates can be used with your database query builder
///   // database.query(predicates);
/// }
/// ```

class Predicate {
  final String field;
  final PredicateOperator operator;
  final dynamic value;
  final dynamic secondValue;
  final String? table;

  const Predicate._({
    required this.field,
    required this.operator,
    this.value,
    this.secondValue,
    this.table,
  });

  // Basic comparison operators
  static Predicate equals(String field, dynamic value, {String? table}) =>
      Predicate._(
        field: field,
        operator: PredicateOperator.equals,
        value: value,
        table: table,
      );

  static Predicate notEquals(String field, dynamic value, {String? table}) =>
      Predicate._(
        field: field,
        operator: PredicateOperator.notEquals,
        value: value,
        table: table,
      );

  static Predicate greaterThan(String field, dynamic value, {String? table}) =>
      Predicate._(
        field: field,
        operator: PredicateOperator.greaterThan,
        value: value,
        table: table,
      );

  static Predicate lessThan(String field, dynamic value, {String? table}) =>
      Predicate._(
        field: field,
        operator: PredicateOperator.lessThan,
        value: value,
        table: table,
      );

  static Predicate greaterThanOrEquals(String field, dynamic value,
          {String? table}) =>
      Predicate._(
        field: field,
        operator: PredicateOperator.greaterThanOrEquals,
        value: value,
        table: table,
      );

  static Predicate lessThanOrEquals(String field, dynamic value,
          {String? table}) =>
      Predicate._(
        field: field,
        operator: PredicateOperator.lessThanOrEquals,
        value: value,
        table: table,
      );

  // Null checks
  static Predicate isNull(String field, {String? table}) => Predicate._(
        field: field,
        operator: PredicateOperator.isNull,
        table: table,
      );

  static Predicate isNotNull(String field, {String? table}) => Predicate._(
        field: field,
        operator: PredicateOperator.isNotNull,
        table: table,
      );

  // String operations
  static Predicate contains(String field, String value, {String? table}) =>
      Predicate._(
        field: field,
        operator: PredicateOperator.contains,
        value: value,
        table: table,
      );

  static Predicate notContains(String field, String value, {String? table}) =>
      Predicate._(
        field: field,
        operator: PredicateOperator.notContains,
        value: value,
        table: table,
      );

  static Predicate startsWith(String field, String value, {String? table}) =>
      Predicate._(
        field: field,
        operator: PredicateOperator.startsWith,
        value: value,
        table: table,
      );

  static Predicate endsWith(String field, String value, {String? table}) =>
      Predicate._(
        field: field,
        operator: PredicateOperator.endsWith,
        value: value,
        table: table,
      );

  // Regular expression
  static Predicate matches(String field, String pattern, {String? table}) =>
      Predicate._(
        field: field,
        operator: PredicateOperator.matches,
        value: pattern,
        table: table,
      );

  // Case-insensitive string operations
  static Predicate iEquals(String field, String value, {String? table}) =>
      Predicate._(
        field: field,
        operator: PredicateOperator.iEquals,
        value: value,
        table: table,
      );

  static Predicate iContains(String field, String value, {String? table}) =>
      Predicate._(
        field: field,
        operator: PredicateOperator.iContains,
        value: value,
        table: table,
      );

  static Predicate iStartsWith(String field, String value, {String? table}) =>
      Predicate._(
        field: field,
        operator: PredicateOperator.iStartsWith,
        value: value,
        table: table,
      );

  static Predicate iEndsWith(String field, String value, {String? table}) =>
      Predicate._(
        field: field,
        operator: PredicateOperator.iEndsWith,
        value: value,
        table: table,
      );

  // Range operations
  static Predicate between(String field, dynamic start, dynamic end,
          {String? table}) =>
      Predicate._(
        field: field,
        operator: PredicateOperator.between,
        value: start,
        secondValue: end,
        table: table,
      );

  static Predicate notBetween(String field, dynamic start, dynamic end,
          {String? table}) =>
      Predicate._(
        field: field,
        operator: PredicateOperator.notBetween,
        value: start,
        secondValue: end,
        table: table,
      );

  // Collection operations
  static Predicate in_(String field, List<dynamic> values, {String? table}) =>
      Predicate._(
        field: field,
        operator: PredicateOperator.in_,
        value: values,
        table: table,
      );

  static Predicate notIn(String field, List<dynamic> values, {String? table}) =>
      Predicate._(
        field: field,
        operator: PredicateOperator.notIn,
        value: values,
        table: table,
      );

  // Array operations
  static Predicate arrayContains(String field, dynamic value, {String? table}) {
    if (value is List) {
      throw ArgumentError('value cannot be a list on arrayContains');
    }
    return Predicate._(
      field: field,
      operator: PredicateOperator.arrayContains,
      value: value,
      table: table,
    );
  }

  static Predicate arrayContainsAny(String field, List<dynamic> values,
          {String? table}) =>
      Predicate._(
        field: field,
        operator: PredicateOperator.arrayContainsAny,
        value: values,
        table: table,
      );

  static Predicate arrayContainsAll(String field, List<dynamic> values,
          {String? table}) =>
      Predicate._(
        field: field,
        operator: PredicateOperator.arrayContainsAll,
        value: values,
        table: table,
      );

  static Predicate arrayIsEmpty(String field, {String? table}) => Predicate._(
        field: field,
        operator: PredicateOperator.arrayIsEmpty,
        table: table,
      );

  static Predicate arrayIsNotEmpty(String field, {String? table}) =>
      Predicate._(
        field: field,
        operator: PredicateOperator.arrayIsNotEmpty,
        table: table,
      );

  // Date operations
  static Predicate dateEquals(String field, DateTime date, {String? table}) =>
      Predicate._(
        field: field,
        operator: PredicateOperator.dateEquals,
        value: date,
        table: table,
      );

  static Predicate dateBefore(String field, DateTime date, {String? table}) =>
      Predicate._(
        field: field,
        operator: PredicateOperator.dateBefore,
        value: date,
        table: table,
      );

  static Predicate dateAfter(String field, DateTime date, {String? table}) =>
      Predicate._(
        field: field,
        operator: PredicateOperator.dateAfter,
        value: date,
        table: table,
      );

  static Predicate dateOnOrBefore(String field, DateTime date,
          {String? table}) =>
      Predicate._(
        field: field,
        operator: PredicateOperator.dateOnOrBefore,
        value: date,
        table: table,
      );

  static Predicate dateOnOrAfter(String field, DateTime date,
          {String? table}) =>
      Predicate._(
        field: field,
        operator: PredicateOperator.dateOnOrAfter,
        value: date,
        table: table,
      );

  static Predicate dateBetween(String field, DateTime start, DateTime end,
          {String? table}) =>
      Predicate._(
        field: field,
        operator: PredicateOperator.dateBetween,
        value: start,
        secondValue: end,
        table: table,
      );

  // Numeric operations
  static Predicate isEven(String field, {String? table}) => Predicate._(
        field: field,
        operator: PredicateOperator.isEven,
        table: table,
      );

  static Predicate isOdd(String field, {String? table}) => Predicate._(
        field: field,
        operator: PredicateOperator.isOdd,
        table: table,
      );

  static Predicate isDivisibleBy(String field, num divisor, {String? table}) =>
      Predicate._(
        field: field,
        operator: PredicateOperator.isDivisibleBy,
        value: divisor,
        table: table,
      );

  // Full text search
  static Predicate fullTextMatch(String field, String searchText,
          {String? table}) =>
      Predicate._(
        field: field,
        operator: PredicateOperator.fullTextMatch,
        value: searchText,
        table: table,
      );
}
