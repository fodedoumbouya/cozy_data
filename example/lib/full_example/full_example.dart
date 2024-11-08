import 'package:cozy_data/cozy_data.dart';
import 'package:cozy_data_example/full_example/model/programmer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class RecipeListScreen extends StatelessWidget {
  const RecipeListScreen({super.key});

  static final DataQueryController<Programmer> controller =
      DataQueryController<Programmer>();

  /// Query  for the Person Data from CozyData
  static final DataQueryListener<Programmer> _programmerQuery =
      CozyData.queryListener<Programmer>(controller: controller);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(242, 242, 247, 1),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            floating: true,
            elevation: 0,
            backgroundColor: const Color.fromRGBO(242, 242, 247, 1),
            title: const Text(
              'Recipes',
              style: TextStyle(
                color: Colors.black,
                fontSize: 34,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.add),
                color: CupertinoColors.activeBlue,
                onPressed: () {},
              ),
              const SizedBox(width: 8),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(13.0),
              child: CupertinoSearchTextField(
                placeholder: 'Search',
                backgroundColor: const Color.fromRGBO(227, 227, 233, 1),
                onChanged: (value) async {
                  await controller.applyFilterQueryPredicate((queryBuilder) {
                    return queryBuilder.nameContains(value);
                  });
                },
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: ListenableBuilder(
                listenable: _programmerQuery,
                builder: (context, _) {
                  final programmers = _programmerQuery.items;
                  if (programmers.isEmpty) {
                    return const Center(
                      child: Text(
                        "Please click the + button to add a new programmer\n\nOnce added, you can edit the by tapping on it",
                        textAlign: TextAlign.center,
                      ),
                    );
                  }
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          ...List.generate(
                            programmers.length,
                            (index) {
                              final programmer = programmers[index];
                              final isLastitem =
                                  index == programmers.length - 1;
                              return Column(
                                children: [
                                  ListTile(
                                    minTileHeight: 45,
                                    title: Text(
                                      programmer.name,
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500),
                                    ),
                                    trailing: const Icon(
                                      Icons.arrow_forward_ios,
                                      color: Colors.grey,
                                      size: 15,
                                    ),
                                    onTap: () {},
                                  ),
                                  if (!isLastitem)
                                    const Divider(
                                      height: 1,
                                      indent: 16,
                                    ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                }),
          ),
        ],
      ),
    );
  }
}
