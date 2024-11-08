import 'package:cozy_data/cozy_data.dart';
import 'package:flutter/material.dart';

import '../model/person.dart';

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
