<p align="center">
  <a href="https://doumbouya.dev">
    <img src="https://github.com/user-attachments/assets/cec31d91-4991-40bd-aeb4-9ecbdeee1ba1?sanitize=true" height="428">
  </a>
  <h1 align="center">Cozy Data</h1>
</p>

<p align="center">
  <a href="https://pub.dev/publishers/doumbouya.dev/packagesr">
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
  <a href="https://github.com/fodedoumbouya/cozy_data">Quickstart</a> •
  <a href="https://github.com/fodedoumbouya/cozy_data">Documentation</a> •
  <a href="https://github.com/fodedoumbouya/cozy_data/tree/main/example">Sample Apps</a> •
  <a href="https://pub.dev/packages/cozy_data">Pub.dev</a>
</p>

> #### CozyData:

> 1. SwiftData for flutter.
> 2. Based on [isar](https://pub.dev/packages/isar).

A Swift-inspired persistent data management solution for Flutter. CozyData provides a simple, powerful, and type-safe way to persist your app's models and automatically update your UI when data changes.

⚠️ CozyData is not READY FOR PRODUCTION USE YET⚠️  

## Features

- 🔄 Automatic UI updates when data changes
- 🏃‍♂️ Fast and efficient database operations
- 📱 Built specifically for Flutter
- 💾 Simple persistent storage
- 🔍 Powerful querying capabilities
- 🎯 Type-safe data operations
- 🧩 Easy-to-use annotations
- 📦 Zero configuration needed

## showcases
https://github.com/user-attachments/assets/5295950d-3ed9-45d8-abb2-549aa30e9aad


## Quickstart

Add `cozy_data` to your `pubspec.yaml`:

### 1. Add to pubspec.yaml

```yaml
dependencies:
  cozy_data: latest

dev_dependencies:
  build_runner: any
```

## Usage

### 1. Define Your Models

```dart
import 'package:cozy_data/cozy_data.dart';
part 'recipe.g.dart';

@collection
class Recipe {
  final int id;
  String name;
  List<Ingredients>? ingredients;

  Recipe({required this.id, required this.name, this.ingredients});
}

@embedded
class Ingredients {
  String name;
  int quantity;
  Ingredients({required this.name, required this.quantity});
}

```
and make sure to run `dart run build_runner build` after creating your model

## 2. Initialize CozyData
Initialize CozyData in your `main.dart`:
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
 await CozyData.initialize(
      schemas: [RecipeSchema]);
  runApp(MyApp());
}
 
```
the `RecipeSchema` will be generate in `.g.dart` file

## Basic Operations

### Save Data

```dart
final newRecipe = Recipe(
  id: 1,
  name: 'salad',
  ingredients: [
  Ingredients(name: 'lettuce', quantity: 1),
  Ingredients(name: 'tomato', quantity: 2),
  Ingredients(name: 'cucumber', quantity: 1),
  ]
);

await CozyData.save<Recipe>(newRecipe);

```
### Delete Data

```dart

await CozyData.delete<Recipe>(id: 1);

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

final recipes = await CozyData.fetch<Recipe>(
  sortByProperties: [
    SortProperty(property: 1, sort: Sort.desc),
  ]
);

```

Note: `property` is the index of the `name` in our class model

### Find by ID

```dart
final recipe = await CozyData.findById<Recipe>(id: id);

```

## Advanced Usage 

### Sorting and Filtering once

```dart

final recipes = CozyData.fetch<Person>(
  filterCondition: EqualCondition(property: 1, value: "salad"),
    sortByProperties: [
      SortProperty(property: 1, sort: Sort.desc),
  ]
);

```

### Sorting and Filtering 
```dart
// Controllers
final CozyQueryController<Recipe> _queryController = CozyQueryController<Recipe>();

final CozyQueryListener<Recipe> _recipeQuery =
      CozyData.queryListener<Recipe>(controller: _queryController);

await controller.queryPredicate(
    filterModifier: (filterQuery) => filterQuery.nameContains(value),
    istinctModifier: (distinctQuery) =>distinctQuery.distinctByName(),
    sortModifier: (sortByQuery) => sortByQuery.sortByName(),
    limit: 2,
    offset: 0
);

```

## Model Attributes

### @collection
Marks a class as a persistent model that can be stored in the database.

### @embedded
Marks a class as an embedded object that can be included in other models.

## Best Practices
- **Initialize Early:** Call CozyData.initialize() as early as possible in your app lifecycle.

- **Dispose Queries:** Always dispose of queries when they're no longer needed to prevent memory leaks.


### License

```
Copyright 2024 Fode DOUMBOUYA

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```

