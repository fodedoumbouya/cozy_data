import 'package:cozy_data/cozy_data.dart';

part 'person.g.dart';

@collection
class Person {
  final int id;

  String? name;
  int? age;

  Person({required this.id, this.name, this.age});
}

// @embedded
// class Address {
//   String? street;
//   String? city;
//   String? country;
// }

// @collection
// class Person2 extends PersistentData {
//   String? name;
//   @Index()
//   int? age;

//   // @Index(type: IndexType.value)
//   String? email;

//   List<Address>? addresses;
// }
