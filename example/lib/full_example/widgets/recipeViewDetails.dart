import 'package:cozy_data_example/full_example/model/recipe.dart';
import 'package:cozy_data/cozy_data.dart';
import 'package:cozy_data_example/full_example/widgets/addIngredient.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RecipeViewDetails extends StatefulWidget {
  final Recipe? recipe;
  const RecipeViewDetails({super.key, this.recipe});

  @override
  State<RecipeViewDetails> createState() => _RecipeViewDetailsState();
}

class _RecipeViewDetailsState extends State<RecipeViewDetails> {
  late Recipe recipe;
  Widget field({required String hintText}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: TextEditingController(text: recipe.name),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.grey),
          border: const OutlineInputBorder(
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.all(16),
        ),
        onChanged: (value) {
          recipe.name = value;
        },
      ),
    );
  }

  @override
  void initState() {
    // Initialize the recipe object with the provided recipe or a new one
    recipe = widget.recipe ??
        Recipe(
          id: CozyId.cozyPersistentModelIDString(),
          name: '',
        );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;

        if (widget.recipe != null) {
          CozyData.update<Recipe>(recipe);
        } else if (recipe.name.isNotEmpty) {
          CozyData.save<Recipe>(recipe);
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
            if (recipe.name.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  if (recipe.name.isNotEmpty) {
                    CozyData.delete<Recipe>(recipe);
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
                      ...List.generate((recipe.ingredients ?? []).length,
                          (index) {
                        final ingredient = recipe.ingredients![index];
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
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddIngredient(
                                  ingredient: ingredient,
                                  onDeleted: (p0) {
                                    recipe.ingredients!.remove(ingredient);
                                  },
                                ),
                              ),
                            );
                            setState(() {});
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
                        Ingredients(name: "", cookStyle: CookStyle.fry);
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddIngredient(
                          ingredient: newIngredient,
                        ),
                      ),
                    );
                    if (newIngredient.name.isNotEmpty) {
                      recipe.ingredients ??= [];
                      newIngredient.quantity ??= 0;
                      recipe.ingredients!.add(newIngredient);
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
