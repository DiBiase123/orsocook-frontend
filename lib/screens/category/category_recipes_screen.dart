import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:orsocook/models/recipe.dart';
import 'package:orsocook/services/recipe_service.dart';
import 'package:orsocook/screens/category/viewmodels/category_recipes_viewmodel.dart';
import 'package:orsocook/widgets/recipe_card.dart';
import 'package:orsocook/widgets/shimmer_effect.dart';

class CategoryRecipesScreen extends StatefulWidget {
  final String categorySlug;

  const CategoryRecipesScreen({
    super.key,
    required this.categorySlug,
  });

  @override
  State<CategoryRecipesScreen> createState() => _CategoryRecipesScreenState();
}

class _CategoryRecipesScreenState extends State<CategoryRecipesScreen> {
  late CategoryRecipesViewModel _viewModel;
  final ScrollController _scrollController = ScrollController();

  Color _getCategoryColor(String slug) {
    final colors = {
      'antipasti': const Color(0xFF7B1FA2),
      'primi-piatti': const Color(0xFF9C27B0),
      'secondi-piatti': const Color(0xFFAB47BC),
      'contorni': const Color(0xFFBA68C8),
      'dolci': const Color(0xFFCE93D8),
      'pane-e-pizza': const Color(0xFF8E24AA),
      'zuppe-e-minestre': const Color(0xFF6A1B9A),
      'insalate': const Color(0xFFB39DDB),
      'salse-e-condimenti': const Color(0xFF9575CD),
      'bevande': const Color(0xFF7E57C2),
      'colazioni-e-brunch': const Color(0xFF673AB7),
      'piatti-unici': const Color(0xFF5E35B1),
    };
    return colors[slug] ?? const Color(0xFF6750A4);
  }

  String _formatCategoryName(String slug) {
    final name = slug.replaceAll('-', ' ');
    return name[0].toUpperCase() + name.substring(1);
  }

  @override
  void initState() {
    super.initState();
    _viewModel = CategoryRecipesViewModel(
      recipeService: context.read<RecipeService>(),
      categorySlug: widget.categorySlug,
    );
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 300 &&
        !_viewModel.isLoading &&
        _viewModel.hasMore) {
      _viewModel.loadMore();
    }
  }

  void _navigateToRecipeDetail(Recipe recipe) {
    context.push('/recipe/detail/${recipe.id}', extra: recipe);
  }

  @override
  Widget build(BuildContext context) {
    final categoryColor = _getCategoryColor(widget.categorySlug);

    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: categoryColor,
          foregroundColor: Colors.white,
          title: Consumer<CategoryRecipesViewModel>(
            builder: (context, viewModel, child) {
              return Text(
                viewModel.categoryName.isNotEmpty
                    ? viewModel.categoryName
                    : _formatCategoryName(widget.categorySlug),
                style: const TextStyle(fontWeight: FontWeight.bold),
              );
            },
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.pop(),
          ),
        ),
        body: Consumer<CategoryRecipesViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading && viewModel.recipes.isEmpty) {
              return ShimmerGrid(count: 6);
            }

            if (viewModel.error != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        viewModel.error!,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () =>
                          viewModel.loadCategoryRecipes(refresh: true),
                      child: const Text('RIPROVA'),
                    ),
                  ],
                ),
              );
            }

            if (viewModel.recipes.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.restaurant_menu,
                        size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text(
                      'Nessuna ricetta in questa categoria',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => context.pop(),
                      child: const Text('TORNA ALLA HOME'),
                    ),
                  ],
                ),
              );
            }

            return GridView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.75,
              ),
              itemCount: viewModel.recipes.length + (viewModel.hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= viewModel.recipes.length) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final recipe = viewModel.recipes[index];
                return RecipeCard(
                  recipe: recipe,
                  onTap: () => _navigateToRecipeDetail(recipe),
                );
              },
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _viewModel.disposeViewModel();
    super.dispose();
  }
}
