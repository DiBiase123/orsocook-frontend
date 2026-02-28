import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:orsocook/models/recipe.dart'; // <-- AGGIUNGI QUESTO
import 'package:orsocook/screens/home/viewmodels/home_viewmodel.dart';
import 'package:orsocook/screens/home/widgets/welcome_header.dart';
import 'package:orsocook/screens/home/widgets/recipe_search_bar.dart';
import 'package:orsocook/screens/home/widgets/categories_bar.dart';
import 'package:orsocook/screens/home/widgets/empty_state.dart';
import 'package:orsocook/screens/home/widgets/recipe_list.dart';

class HomeBody extends StatelessWidget {
  final VoidCallback onCreateRecipeTap;
  final TextEditingController searchController;
  final Function(Recipe) onRecipeTap;

  const HomeBody({
    super.key,
    required this.onCreateRecipeTap,
    required this.searchController,
    required this.onRecipeTap,
  });

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<HomeViewModel>(context);
    final recipes = viewModel.recipes;

    return Column(
      children: [
        const WelcomeHeader(),
        RecipeSearchBar(
          controller: searchController,
          onSearchChanged: viewModel.onSearchChanged,
        ),
        CategoriesBar(
          onCategorySelected: viewModel.onCategorySelected,
          selectedCategorySlug: viewModel.selectedCategory,
        ),
        const SizedBox(height: 8),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) =>
                FadeTransition(opacity: animation, child: child),
            child: recipes.isNotEmpty
                ? RecipeList(
                    key: const ValueKey('recipe-list'),
                    onRecipeTap: onRecipeTap,
                  )
                : EmptyState(
                    key: ValueKey(
                        'empty${viewModel.selectedCategory}${viewModel.searchQuery}'),
                    searchQuery: viewModel.searchQuery,
                    onRetry: viewModel.loadRecipesWithFilters,
                    onCreateRecipe: onCreateRecipeTap,
                  ),
          ),
        ),
      ],
    );
  }
}
