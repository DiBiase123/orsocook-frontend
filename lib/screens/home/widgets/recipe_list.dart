import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:orsocook/models/recipe.dart';
import 'package:orsocook/widgets/recipe_card.dart';
import 'package:orsocook/services/recipe_service.dart';

class RecipeList extends StatefulWidget {
  final void Function(Recipe) onRecipeTap;

  const RecipeList({
    super.key,
    required this.onRecipeTap,
  });

  @override
  State<RecipeList> createState() => _RecipeListState();
}

class _RecipeListState extends State<RecipeList> {
  final ScrollController _scrollController = ScrollController();
  int _lastLogCount = -1;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final recipeService = Provider.of<RecipeService>(context, listen: false);

    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 300 &&
        !recipeService.isLoading &&
        recipeService.hasMore) {
      _loadMoreRecipes(recipeService);
    }
  }

  Future<void> _loadMoreRecipes(RecipeService recipeService) async {
    await recipeService.loadMoreRecipes();
  }

  int _calculateCrossAxisCount(double width) {
    final safeWidth = width.clamp(300.0, double.infinity);
    if (safeWidth > 900) {
      return 3;
    } else if (safeWidth > 600) {
      return 2;
    } else {
      return 1;
    }
  }

  Widget _buildLoadingMore() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: const Center(
        child: Column(
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 12),
            Text(
              'Caricamento altre ricette...',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEndOfList() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.shade100, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle, color: Colors.green.shade600, size: 16),
          const SizedBox(width: 8),
          Text(
            'Tutte le ricette caricate',
            style: TextStyle(
              color: Colors.green.shade800,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Consumer<RecipeService>(
          builder: (context, recipeService, child) {
            final recipes = recipeService.cachedRecipes;
            final recipeCount = recipes.length;

            if (_lastLogCount != recipeCount) {
              _lastLogCount = recipeCount;
            }

            if (recipes.isEmpty && !recipeService.isLoading) {
              return const SizedBox.shrink();
            }

            final crossAxisCount =
                _calculateCrossAxisCount(constraints.maxWidth);
            final spacing = _calculateSpacing(crossAxisCount);
            final padding = _calculatePadding(crossAxisCount);

            final itemCount = recipeCount +
                (recipeService.hasMore && recipeService.isLoading ? 1 : 0);

            return Column(
              children: [
                Expanded(
                  child: NotificationListener<ScrollNotification>(
                    onNotification: (notification) => false,
                    child: RefreshIndicator(
                      onRefresh: () async {
                        await recipeService.fetchRecipes(
                            forceRefresh: true, page: 1);
                      },
                      child: GridView.builder(
                        controller: _scrollController,
                        padding: padding,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: spacing,
                          mainAxisSpacing: spacing,
                          childAspectRatio: 0.75,
                        ),
                        itemCount: itemCount,
                        itemBuilder: (context, index) {
                          if (index >= recipeCount) {
                            return _buildLoadingMore();
                          }

                          final recipe = recipes[index];
                          return RecipeCard(
                            key: ValueKey(recipe.id),
                            recipe: recipe,
                            onTap: () => widget.onRecipeTap(recipe),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                if (!recipeService.hasMore && recipes.isNotEmpty)
                  _buildEndOfList(),
              ],
            );
          },
        );
      },
    );
  }

  EdgeInsets _calculatePadding(int crossAxisCount) {
    final horizontalPadding = switch (crossAxisCount) {
      3 => 24.0,
      2 => 20.0,
      _ => 16.0,
    };

    return EdgeInsets.symmetric(
      horizontal: horizontalPadding,
      vertical: 16.0,
    );
  }

  double _calculateSpacing(int crossAxisCount) {
    return switch (crossAxisCount) {
      3 => 20.0,
      2 => 16.0,
      _ => 12.0,
    };
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
