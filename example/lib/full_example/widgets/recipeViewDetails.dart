import 'package:cozy_data/cozy_data.dart';
import 'package:cozy_data_example/full_example/model/programmer.dart';
import 'package:cozy_data_example/full_example/widgets/addIngredient.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RecipeViewDetails extends StatefulWidget {
  final Recipe recipe;
  const RecipeViewDetails({super.key, required this.recipe});

  @override
  State<RecipeViewDetails> createState() => _RecipeViewDetailsState();
}

class _RecipeViewDetailsState extends State<RecipeViewDetails> {
  Widget field({required String hintText}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: TextEditingController(text: widget.recipe.name),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.grey),
          border: const OutlineInputBorder(
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.all(16),
        ),
        onChanged: (value) {
          widget.recipe.name = value;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        if (widget.recipe.name.isNotEmpty) {
          CozyData.save<Recipe>(widget.recipe);
        }
        Navigator.of(context).pop();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF5F5F5),
          title: const Text(
            'Edit Recipe',
            style: TextStyle(fontSize: 17),
          ),
          actions: [
            if (widget.recipe.name.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  if (widget.recipe.name.isNotEmpty) {
                    CozyData.delete<Recipe>(id: widget.recipe.id);
                    Navigator.of(context).pop();
                  }
                },
              ),
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                field(hintText: 'Name'),
                const SizedBox(height: 20),
                const Text(
                  'WHAT IS THE INGREDIENTS?',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      // Source Dropdown
                      ...List.generate((widget.recipe.ingredients ?? []).length,
                          (index) {
                        final ingredient = widget.recipe.ingredients![index];
                        return ListTile(
                          title: Text(
                            ingredient.name,
                            style: const TextStyle(),
                          ),
                          subtitle: Text(
                            '${ingredient.quantity}',
                            style: const TextStyle(),
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            ingredient.quantity.toString();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddIngredient(
                                  ingredient: ingredient,
                                  onDeleted: (p0) {
                                    widget.recipe.ingredients!
                                        .remove(ingredient);
                                    setState(() {});
                                  },
                                ),
                              ),
                            );
                          },
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () async {
                    Ingredients newIngredient =
                        Ingredients(name: "", quantity: 0);
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddIngredient(
                          ingredient: newIngredient,
                        ),
                      ),
                    );
                    if (newIngredient.name.isNotEmpty) {
                      widget.recipe.ingredients ??= [];
                      widget.recipe.ingredients!.add(newIngredient);
                      setState(() {});
                    }
                  },
                  child: const Text(
                    'add a new ingredient',
                    style: TextStyle(
                      color: CupertinoColors.activeBlue,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
