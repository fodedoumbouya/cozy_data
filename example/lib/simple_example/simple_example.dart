import 'dart:math';

import 'package:cozy_data/cozy_data.dart';
import 'package:flutter/material.dart';

import 'model/person.dart';
import 'widgets/editableListTile.dart';

final _personNames = [
  "John Doe",
  "Jane Doe",
  "Alice",
  "Bob",
  "Charlie",
  "David",
  "Eve",
  "Frank",
  "Grace",
  "Heidi",
  "Ivan",
  "Judy",
  "Mallory",
  "Oscar",
  "Peggy",
  "Trent",
  "Victor",
  "Walter",
  "Zoe",
];

class ClassName {}

class SimpleExample extends StatefulWidget {
  const SimpleExample({super.key});

  @override
  State<SimpleExample> createState() => _SimpleExampleState();
}

class _SimpleExampleState extends State<SimpleExample> {
  final CozyQueryListener<Person> personQuery =
      CozyData.queryListener<Person>();

  @override
  void dispose() {
    personQuery.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(242, 242, 247, 1),
        title: const Text("Simple Example"),
      ),
      body: ListenableBuilder(
        listenable: personQuery,
        builder: (context, _) {
          /// Reverse the list to show the latest person at the top
          final persons = personQuery.items.reversed.toList();
          if (persons.isEmpty) {
            return const Center(
              child: Text(
                "Please click the + button to add a new person\n\nOnce added, you can edit the person's name and age by tapping on the name or age",
                textAlign: TextAlign.center,
              ),
            );
          }
          return ListView.builder(
            itemCount: persons.length,
            itemBuilder: (context, index) {
              final person = persons[index];
              return EditableListTile(person: person);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          /// Generate a new id for the person
          final id = CozyId.cozyPersistentModelIDInt();

          /// Create a new person with the generated id
          final person = Person(
            id: id,
            name: _personNames[Random().nextInt(_personNames.length)],
            age: Random().nextInt(100),
            car: Car(Random().nextDouble() * 100,
                Brand.values[Random().nextInt(Brand.values.length)]),
          );
          // Save the person to the database
          // Make sure to use the model <Model> to save in the database
          await CozyData.save<Person>(person);
        },
        backgroundColor: Colors.red,
        child: const Icon(Icons.add),
      ),
    );
  }
}
