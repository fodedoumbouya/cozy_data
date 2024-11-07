import 'package:cozy_data/cozy_data.dart';
import 'package:flutter/material.dart';

import 'person.dart';
import 'simple_example.dart';

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
      title: 'Cozy Data Example',
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SimpleExample()),
              );
            },
            child: const Text("Simple Example"),
          ),
        ],
      ),
    ));
  }
}
