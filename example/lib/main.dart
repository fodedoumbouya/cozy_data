import 'package:cozy_data/cozy_data.dart';
import 'package:cozy_data_example/full_example/full_example.dart';
import 'package:cozy_data_example/full_example/model/recipe.dart';
import 'package:flutter/material.dart';

import 'simple_example/model/person.dart';
import 'simple_example/simple_example.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await CozyData.initialize(
      schemas: [PersonSchema, RecipeSchema], engine: IsarEngine.sqlite);
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
        scaffoldBackgroundColor: const Color.fromRGBO(242, 242, 247, 1),
      ),
      home: const Examples(),
    );
  }
}

// Example usage in a Flutter widget
class Examples extends StatefulWidget {
  const Examples({super.key});

  @override
  _ExamplesState createState() => _ExamplesState();
}

class _ExamplesState extends State<Examples> {
  CozyQueryListener<Person> personQuery = CozyData.queryListener<Person>();

  @override
  void dispose() {
    super.dispose();
    personQuery.dispose();
  }

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
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FullExample(),
                ),
              );
            },
            child: const Text("Full Example"),
          ),
        ],
      ),
    ));
  }
}
