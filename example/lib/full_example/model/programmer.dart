import 'package:cozy_data/cozy_data.dart';

part 'programmer.g.dart';

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
