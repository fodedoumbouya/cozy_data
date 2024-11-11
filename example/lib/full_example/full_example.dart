import 'package:cozy_data/cozy_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'model/recipe.dart';
import 'widgets/recipeViewDetails.dart';
import 'widgets/sortPicker.dart';

/// A full example screen that demonstrates how to use CozyData
class FullExample extends StatefulWidget {
  const FullExample({super.key});

  @override
  State<FullExample> createState() => _FullExampleState();
}

class _FullExampleState extends State<FullExample> {
  // Controllers
  static final CozyQueryController<Recipe> _queryController =
      CozyQueryController<Recipe>();
  final TextEditingController _searchController = TextEditingController();

  final ValueNotifier<SortOrder> _currentSortOrder =
      ValueNotifier<SortOrder>(SortOrder.itemAsc);

  /// Query listener for Recipe data from CozyData
  final CozyQueryListener<Recipe> _recipeQuery =
      CozyData.queryListener<Recipe>(controller: _queryController);

  /// Returns the appropriate sort function based on the selected order
  QueryBuilder<Recipe, Recipe, QAfterSortBy> _getSortFunction(
    SortOrder order,
    QueryBuilder<Recipe, Recipe, QAfterFilterCondition> sortByQuery,
  ) {
    switch (order) {
      case SortOrder.itemAsc:
        return sortByQuery.sortById();
      case SortOrder.itemDesc:
        return sortByQuery.sortByIdDesc();
      case SortOrder.nameAsc:
        return sortByQuery.sortByName();
      case SortOrder.nameDesc:
        return sortByQuery.sortByNameDesc();
      default:
        return sortByQuery.sortById();
    }
  }

  /// Updates the query based on search text and sort order
  void _updateQuery() async {
    await _queryController.queryPredicate(
      filterModifier: (filterQuery) =>
          filterQuery.nameContains(_searchController.text),
      sortModifier: (sortByQuery) =>
          _getSortFunction(_currentSortOrder.value, sortByQuery),
    );
  }

  /// Creates and navigates to a new recipe
  void _createNewRecipe() {
    final newRecipe = Recipe(
      id: DateTime.now().millisecondsSinceEpoch,
      name: '',
    );
    _navigateToRecipeDetails(newRecipe);
  }

  /// Navigates to recipe details screen
  void _navigateToRecipeDetails(Recipe recipe) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => RecipeViewDetails(recipe: recipe),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_updateQuery);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _currentSortOrder.dispose();
    _recipeQuery.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          _buildSearchBar(),
          _buildRecipeList(),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      pinned: true,
      floating: true,
      elevation: 0,
      backgroundColor: const Color.fromRGBO(242, 242, 247, 1),
      title: const Text(
        "Recipes",
        style: TextStyle(
          color: CupertinoColors.black,
          fontSize: 34,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        ValueListenableBuilder(
          valueListenable: _currentSortOrder,
          builder: (context, value, _) => SortMenu(
            currentSort: value,
            onSortChanged: _handleSortChange,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.add),
          color: CupertinoColors.activeBlue,
          onPressed: _createNewRecipe,
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildSearchBar() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(13),
        child: CupertinoSearchTextField(
          placeholder: 'Search',
          backgroundColor: const Color.fromRGBO(227, 227, 233, 1),
          controller: _searchController,
        ),
      ),
    );
  }

  Widget _buildRecipeList() {
    return SliverToBoxAdapter(
      child: ListenableBuilder(
          listenable: _recipeQuery,
          builder: (context, _) {
            final recipes = _recipeQuery.items;
            if (recipes.isEmpty) {
              return const Center(
                child: Text(
                  "Please click the + button to add a new recipe\n\nOnce added, you can edit the by tapping on it",
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
                      recipes.length,
                      (index) {
                        final recipe = recipes[index];
                        final isLastitem = index == recipes.length - 1;
                        return Column(
                          children: [
                            ListTile(
                              minTileHeight: 45,
                              title: Text(
                                recipe.name,
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w500),
                              ),
                              trailing: const Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.grey,
                                size: 15,
                              ),
                              onTap: () {
                                _navigateToRecipeDetails(recipe);
                              },
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
    );
  }

  Future<void> _handleSortChange(SortOrder newOrder) async {
    _currentSortOrder.value = newOrder;
    _searchController.clear();

    await _queryController.queryPredicate(
      sortModifier: (sortByQuery) => _getSortFunction(newOrder, sortByQuery),
    );
  }
}
