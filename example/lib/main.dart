import 'dart:math';

import 'package:cozy_data/cozy_data.dart';
import 'package:flutter/material.dart';

import 'person.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await CozyData.initialize(
    schemas: [PersonSchema],
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CozyData Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const PersonListView(),
    );
  }
}

// Example usage in a Flutter widget
class PersonListView extends StatefulWidget {
  const PersonListView({super.key});

  @override
  _PersonListViewState createState() => _PersonListViewState();
}

class _PersonListViewState extends State<PersonListView> {
  static DataQueryController<Person> controller = DataQueryController<Person>();
  final DataQueryListener<Person> _personQuery =
      CozyData.queryListener<Person>(controller: controller);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListenableBuilder(
        listenable: _personQuery,
        builder: (context, _) {
          final persons = _personQuery.items;
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
          final person = Person(
              DateTime.now().millisecondsSinceEpoch,
              "New Person ${DateTime.now().millisecondsSinceEpoch}",
              Random().nextInt(100),
              "email@gmail.com");
          await CozyData.save<Person>(person);
        },
        backgroundColor: Colors.red,
        child: const Icon(Icons.add),
      ),
    );
  }

  @override
  void dispose() {
    _personQuery.dispose();
    super.dispose();
  }
}

class EditableListTile extends StatefulWidget {
  final Person person;

  const EditableListTile({super.key, required this.person});

  @override
  State<EditableListTile> createState() => _EditableListTileState();
}

class _EditableListTileState extends State<EditableListTile> {
  late TextEditingController _nameController;
  late TextEditingController _ageController;
  bool isEditingName = false;
  bool isEditingAge = false;
  late Person person;
  @override
  void initState() {
    person = widget.person;
    _nameController = TextEditingController(text: person.name ?? 'Unnamed');
    _ageController = TextEditingController(text: '${person.age ?? 0}');
    super.initState();
  }

  @override
  void didUpdateWidget(covariant EditableListTile oldWidget) {
    if (oldWidget.person != widget.person) {
      person = widget.person;
      _nameController.text = person.name ?? 'Unnamed';
      _ageController.text = '${person.age ?? 0}';
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _saveName() async {
    setState(() => isEditingName = false);
    person.name = _nameController.text;
    await CozyData.update<Person>(person);
  }

  Future<void> _saveAge() async {
    setState(() => isEditingAge = false);
    final age = int.tryParse(_ageController.text);
    person.age = age ?? person.age;
    await CozyData.save<Person>(person);
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: isEditingName
          ? TextField(
              controller: _nameController,
              autofocus: true,
              onSubmitted: (_) => _saveName(),
              onEditingComplete: _saveName,
              decoration: const InputDecoration(
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                isDense: true,
              ),
            )
          : GestureDetector(
              onTap: () {
                if (!isEditingAge) {
                  setState(() => isEditingName = true);
                }
              },
              child: Text(_nameController.text),
            ),
      subtitle: isEditingAge
          ? TextField(
              controller: _ageController,
              autofocus: true,
              keyboardType: TextInputType.number,
              onSubmitted: (_) => _saveAge(),
              onEditingComplete: () => _saveAge(),
              decoration: const InputDecoration(
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                isDense: true,
              ),
            )
          : GestureDetector(
              onTap: () {
                if (!isEditingName) {
                  setState(() => isEditingAge = true);
                }
              },
              child: Text(_ageController.text),
            ),
      trailing: IconButton(
        icon:
            Icon((isEditingAge || isEditingName) ? Icons.check : Icons.delete),
        onPressed: () async {
          if (isEditingName) {
            await _saveName();
          } else if (isEditingAge) {
            await _saveAge();
          } else {
            await CozyData.delete<Person>(person.id);
          }
        },
      ),
    );
  }
}
