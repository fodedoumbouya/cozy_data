import 'package:cozy_data_example/full_example/model/recipe.dart';
import 'package:flutter/material.dart';

class AddIngredient extends StatelessWidget {
  final Ingredients ingredient;
  final Function(void)? onDeleted;
  const AddIngredient({
    super.key,
    required this.ingredient,
    this.onDeleted,
  });

  Widget field({
    required bool isName,
  }) {
    final hintText = isName ? 'name' : 'quantity';
    final keyboardType = isName ? TextInputType.text : TextInputType.number;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        keyboardType: keyboardType,
        controller: isName
            ? TextEditingController(text: ingredient.name)
            : TextEditingController(text: ingredient.quantity.toString()),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.grey),
          border: const OutlineInputBorder(
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.all(16),
        ),
        onChanged: (value) {
          if (isName) {
            ingredient.name = value;
          } else {
            ingredient.quantity = int.tryParse(value) ?? 0;
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5F5),
        title: const Text(
          'Add Ingredient',
          style: TextStyle(fontSize: 17),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              field(isName: true),
              const SizedBox(height: 20),
              field(isName: false),
              if (onDeleted != null) ...[
                const SizedBox(height: 50),
                ElevatedButton(
                  onPressed: () {
                    onDeleted?.call(null);
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text(
                    'Delete Ingredient',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
