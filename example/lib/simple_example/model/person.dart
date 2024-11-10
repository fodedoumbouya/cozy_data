import 'package:cozy_data/cozy_data.dart';

part 'person.g.dart';

@collection
class Person {
  final int id;

  String? name;
  int? age;

  Person({required this.id, this.name, this.age});
}
