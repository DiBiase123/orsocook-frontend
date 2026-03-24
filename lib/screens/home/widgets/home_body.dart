import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:orsocook/models/recipe.dart';
import 'package:orsocook/screens/home/viewmodels/home_viewmodel.dart';
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

    return recipes.isNotEmpty
        ? RecipeList(
            onRecipeTap: onRecipeTap,
          )
        : EmptyState(
            searchQuery: viewModel.searchQuery,
            onRetry: viewModel.loadRecipesWithFilters,
            onCreateRecipe: onCreateRecipeTap,
          );
  }
}
