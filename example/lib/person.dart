import 'package:cozy_data/cozy_data.dart';

part 'person.g.dart';

@collection
class Person {
  final int id;

  String? name;
  int? age;

  // @Index(type: IndexType.value)
  String? email;

  // List<Address>? addresses;
  Person(this.id, this.name, this.age, this.email);
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
