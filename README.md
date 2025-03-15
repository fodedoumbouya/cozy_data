<p align="center">
    <img src="https://raw.githubusercontent.com/fodedoumbouya/cozy_data/main/logo/cozyData.png" height="428">
  <h1 align="center">Cozy Data</h1>
</p>

<p align="center">
  <a href="https://pub.dev/packages/cozy_data">
    <img src="https://img.shields.io/pub/v/os_ui?label=pub.dev&labelColor=333940&logo=dart">
  </a>
  <a href="https://github.com/fodedoumbouya/cozy_data">
    <img src="https://img.shields.io/badge/github-cozy_data-blue">
  </a>
 
  <a href="https://x.com/fodedoumbouya1">
    <img src="https://img.shields.io/twitter/follow/fodedoumbouya?style=social">
  </a>
</p>

<p align="center">
  <a href="https://cozydata.web.app/docs/getting-started/installation/">Quickstart</a> •
  <a href="https://cozydata.web.app/">Documentation</a> •
  <a href="https://github.com/fodedoumbouya/cozy_data/tree/main/example">Sample Apps</a> •
  <a href="https://pub.dev/packages/cozy_data">Pub.dev</a>
</p>

> #### CozyData:

> 1. SwiftData for flutter.
> 2. Support sqflite, sqlite3, inMemory data Storage

A Swift-inspired persistent data management solution for Flutter. CozyData provides a simple, powerful, and type-safe way to persist your app's models and automatically update your UI when data changes.


## Features

- 🔄 Automatic UI updates when data changes
- 🏃‍♂️ Fast and efficient database operations
- 📱 Built specifically for Flutter
- 💾 Simple persistent storage
- 🔍 Powerful querying capabilities
- 🎯 Type-safe data operations
- 🧩 Easy-to-use annotations
- 📦 Zero configuration needed


## Quickstart

Add `cozy_data` to your `pubspec.yaml`:

### 1. Add to pubspec.yaml

```yaml
dependencies:
  cozy_data: latest
  dart_mappable: latest

dev_dependencies:
  build_runner: any
  dart_mappable_builder: any
```

## Usage

### 1. Define Your Models

```dart
import 'package:dart_mappable/dart_mappable.dart';
part 'recipe.mapper.dart';

@MappableClass()
class Recipe with RecipeMappable {
  final String persistentModelID; // This field is required for the cozy_data package to work
  String name;
  List<Ingredients>? ingredients;

  Recipe({required this.id, required this.name, this.ingredients});
}

@MappableClass()
class Ingredients with IngredientsMappable {
  String name;
  int? quantity;
  CookStyle cookStyle;
  Ingredients({required this.name, this.quantity, required this.cookStyle});
}

@MappableEnum()
enum CookStyle { bake, fry, boil }

```
and make sure to run `dart run build_runner build` after creating your model.

For more about the annotation please check [dart_mappable](https://pub.dev/packages/dart_mappable).


## 2. Initialize CozyData
Initialize CozyData in your `main.dart`:
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await CozyData.initialize(
      engine: CozyEngine.sqlite3,
      mappers: [RecipeMapper.ensureInitialized()]);

  runApp(MyApp());
}
 
```
the `RecipeMapper` will be generate in `.mapper.dart` file

## Basic Operations

### Save Data

```dart
final newRecipe = Recipe(
  persistentModelID: CozyId.cozyPersistentModelIDString(),
  name: 'salad',
  ingredients: [
    Ingredients(name: 'Tomato',quantity: 2,cookStyle: CookStyle.fry),
    Ingredients(name: 'Onion',quantity: 1,cookStyle: CookStyle.fry),
    Ingredients(name: 'Salt',quantity: 1,cookStyle: CookStyle.boil),
  ]
);

await CozyData.save<Recipe>(newRecipe);

```
Note: DataModel must be Specify `<Recipe>`

### Delete Data

```dart

await CozyData.delete<Recipe>(model);

```

### Update Data

```dart

await CozyData.update<Recipe>(updateRecipe);

```

### Simple Query Data with UI Updates

```dart
class RecipeListView extends StatefulWidget {
  @override
  _RecipeListViewState createState() => _RecipeListViewState();
}

class _RecipeistViewState extends State<RecipeListView> {

final CozyQueryListener<Recipe> _recipeQuery = CozyData.queryListener<Recipe>();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _recipeQuery,
      builder: (context, _) {
        final recipes = _recipeQuery.items;
        return ListView.builder(
          itemCount: recipes.length,
          itemBuilder: (context, index) => ListTile(
            title: Text(recipes[index].name),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _recipeQuery.dispose();
    super.dispose();
  }
}

```

### Fetch Data Once
```dart

final recipes = await CozyData.fetch<Recipe>();

```

### Find by ID

```dart
final recipe = await CozyData.fetcById<Recipe>(persistentModelID: id);

```

## Advanced Usage 

The `CozyQueryBuilder` is a class used to construct complex SQL-like queries in a structured and programmatic way. It allows you to specify various components of a query, such as fields to group by, order by, having clauses, joins, limits, offsets, selected fields, subqueries, table aliases, and where conditions.

```dart

final customBuilder = CozyQueryBuilder(
// groupByFields: A list of fields by which the results should be grouped. In this case, it's an empty list, meaning no grouping is applied.
groupByFields: [],
// orderByFields: A list of fields by which the results should be ordered. It's also an empty list here, so no specific ordering is applied.
orderByFields: [],
// Conditions that filter the groups created by the groupBy clause. It's empty, indicating no such conditions.
havingClauses: [],
// joins: A list of join operations to combine rows from two or more tables based on a related column. No joins are specified here
joins: [],
// limit: The maximum number of records to return. Here, it's set to 10.
limit: 10,
// offset: The number of records to skip before starting to return records. It's set to 0, meaning no records are skipped.
offset: 0,
// selectFields: A list of fields to be selected in the query. It's empty, meaning all fields are selected
selectFields: [],
// subqueries: A list of subqueries to be included in the main query. It's empty, indicating no subqueries.
subqueries: [],
// tableAliases: A map of table aliases to be used in the query. It's an empty map here.
tableAliases: {},
// whereGroups: A list of conditions to filter the results. It's empty, meaning no filtering conditions are applied.
whereGroups: [],
);

```

### Sorting and Filtering once


```dart

final recipes = await CozyData.fetch<Recipe>(customBuilder: customBuilder);

```

The `CozyQueryController` manages query operations for a `CozyQueryListener`. It allows adding where conditions, joins, order by fields, and custom queries to the listener.

Example usage:

```dart
  final controller = CozyQueryController<MyModel>();
  await controller.addWhere([PredicateGroup(predicates: [Predicate.equals('field', 'value')])]);
  await controller.addJoin([Join(table: 'other_table', condition: 'other_table.id = my_table.other_id')]);
  await controller.orderBy([OrderBy(field: 'created_at', direction: OrderDirection.desc)]);
  await controller.addCustomQuery(CozyQueryBuilder<MyModel>());
  await controller.reset();
```


### Sorting and Filtering 
```dart
// Controller
final CozyQueryController<Recipe> _queryController = CozyQueryController<Recipe>();

final CozyQueryListener<Recipe> _recipeQuery =
      CozyData.queryListener<Recipe>(controller: _queryController);

  await controller.addWhere([PredicateGroup(predicates: [Predicate.contains('field', 'value')])]);


```


## Best Practices
- **Initialize Early:** Call CozyData.initialize() as early as possible in your app lifecycle.

- **Dispose Queries:** Always dispose of queries when they're no longer needed to prevent memory leaks.

## Full Documentation
See the full documentation [here](https://cozydata.web.app/)
or jump directly to the topic you are looking for:
- [**CozyQueryController**](https://cozydata.web.app/docs/getting-started/api-reference/cozyQueryController/) 
  show you how to manages your query operations.
- [**Predicate**](https://cozydata.web.app/docs/getting-started/api-reference/predicate/) 
  show you the available prediacte query conditions for filtering data.
- [**CozyEngine Enum**](https://cozydata.web.app/docs/getting-started/api-reference/cozyEngine/)
  represents the types of storage engines supported by the Cozy
- [**Best Practices for CozyData**](https://cozydata.web.app/docs/getting-started/bestPracticesCozyData/)
  comprehensive guide to best practices for using CozyData in your Flutter applications.



