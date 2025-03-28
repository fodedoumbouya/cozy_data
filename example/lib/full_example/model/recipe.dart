import 'package:dart_mappable/dart_mappable.dart';
part 'recipe.mapper.dart';

@MappableClass()
class Recipe with RecipeMappable {
  final String
      persistentModelID; // This field is required for the cozy_data package to work
  String name;
  List<Ingredients>? ingredients;

  Recipe(
      {required this.persistentModelID, required this.name, this.ingredients});
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
