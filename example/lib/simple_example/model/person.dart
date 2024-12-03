import 'package:dart_mappable/dart_mappable.dart';

part 'person.mapper.dart';

@MappableClass()
class Person with PersonMappable {
  final int
      persistentModelID; // This field is required for the cozy_data package to work

  String? name;
  int? age;
  Car? car;

  Person({required this.persistentModelID, this.name, this.age, this.car});
}

@MappableEnum()
enum Brand { Toyota, Audi, BMW }

@MappableClass()
class Car with CarMappable {
  final double miles;
  final Brand brand;

  const Car(this.miles, this.brand);
}
