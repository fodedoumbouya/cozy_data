import 'package:cozy_data_example/full_example/model/recipe.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AddIngredient extends StatefulWidget {
  final Ingredients ingredient;
  final Function(void)? onDeleted;
  const AddIngredient({
    super.key,
    required this.ingredient,
    this.onDeleted,
  });

  @override
  State<AddIngredient> createState() => _AddIngredientState();
}

class _AddIngredientState extends State<AddIngredient> {
  Widget field({
    required bool isName,
  }) {
    final hintText = isName ? 'name' : 'quantity';
    final keyboardType = isName ? TextInputType.text : TextInputType.number;
    TextEditingController controller;
    if (isName) {
      controller = TextEditingController(text: widget.ingredient.name);
    } else if (widget.ingredient.quantity == null) {
      controller = TextEditingController();
    } else {
      controller = TextEditingController(
        text: widget.ingredient.quantity.toString(),
      );
    }
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        keyboardType: keyboardType,
        controller: controller,
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
            widget.ingredient.name = value;
          } else {
            widget.ingredient.quantity = int.tryParse(value) ?? 0;
          }
        },
      ),
    );
  }

  void _showDialog(Widget child) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => Container(
        height: 216,
        padding: const EdgeInsets.only(top: 6.0),
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: SafeArea(
          top: false,
          child: child,
        ),
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
              const SizedBox(height: 20),
              Row(
                children: [
                  const Text("Cook Style: ",
                      style: TextStyle(
                          fontSize: 20.0, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 10),
                  CupertinoButton(
                    padding: const EdgeInsets.all(8),
                    color: CupertinoColors.activeBlue,
                    onPressed: () => _showDialog(CupertinoPicker(
                      magnification: 1.22,
                      squeeze: 1.2,
                      useMagnifier: true,
                      itemExtent: 32,
                      scrollController: FixedExtentScrollController(
                        initialItem: widget.ingredient.cookStyle.index,
                      ),
                      onSelectedItemChanged: (int selectedItem) {
                        widget.ingredient.cookStyle =
                            CookStyle.values[selectedItem];
                        setState(() {});
                      },
                      children: List<Widget>.generate(CookStyle.values.length,
                          (int index) {
                        return Center(
                            child: Text(CookStyle.values[index].name));
                      }),
                    )),
                    child: Text(
                      widget.ingredient.cookStyle.name,
                      style: const TextStyle(
                        fontSize: 22.0,
                        color: CupertinoColors.white,
                      ),
                    ),
                  ),
                ],
              ),
              if (widget.onDeleted != null) ...[
                const SizedBox(height: 50),
                ElevatedButton(
                  onPressed: () {
                    widget.onDeleted?.call(null);
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
