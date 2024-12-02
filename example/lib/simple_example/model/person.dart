import 'package:dart_mappable/dart_mappable.dart';

part 'person.mapper.dart';

@MappableClass()
class Person with PersonMappable {
  final int id;

  String? name;
  int? age;
  Car? car;

  Person({required this.id, this.name, this.age, this.car});
}

@MappableEnum()
enum Brand { Toyota, Audi, BMW }

@MappableClass()
class Car with CarMappable {
  final double miles;
  final Brand brand;

  const Car(this.miles, this.brand);
}
