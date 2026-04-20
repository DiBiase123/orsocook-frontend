import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:orsocook/models/recipe.dart';
import 'package:orsocook/widgets/recipe_card.dart';
import 'package:orsocook/services/recipe_service.dart';
import 'package:orsocook/utils/responsive_utils.dart';

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
      recipeService.loadMoreRecipes();
    }
  }

  int _calculateCrossAxisCount(double width) {
    final safeWidth = width.clamp(300.0, double.infinity);
    if (safeWidth > 1200) return 4;
    if (safeWidth > 900) return 3;
    if (safeWidth > 600) return 2;
    return 1;
  }

  double _calculateMaxCardWidth(double width, int crossAxisCount) {
    final availableWidth =
        width - _calculatePadding(crossAxisCount).horizontal * 2;
    return (availableWidth / crossAxisCount).clamp(200.0, 280.0);
  }

  Widget _buildLoadingMore() {
    return Container(
      padding: ResponsiveValues.screenPadding(context),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 12),
            Text('Caricamento altre ricette...',
                style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildEndOfList() {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 16),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.green.shade100),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, color: Colors.green.shade600, size: 16),
            const SizedBox(width: 8),
            Text('Tutte le ricette caricate',
                style: TextStyle(
                    color: Colors.green.shade800,
                    fontSize: 13,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  EdgeInsets _calculatePadding(int crossAxisCount) {
    final horizontalPadding = switch (crossAxisCount) {
      4 => 32.0,
      3 => 24.0,
      2 => 20.0,
      _ => 16.0,
    };
    return EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: ResponsiveValues.gapMedium(context));
  }

  double _calculateSpacing(int crossAxisCount) {
    return switch (crossAxisCount) {
      4 => 24.0,
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

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Consumer<RecipeService>(
          builder: (context, recipeService, child) {
            final recipes = recipeService.cachedRecipes;
            final recipeCount = recipes.length;

            if (recipes.isEmpty && !recipeService.isLoading) {
              return const SizedBox.shrink();
            }

            final crossAxisCount =
                _calculateCrossAxisCount(constraints.maxWidth);
            final spacing = _calculateSpacing(crossAxisCount);
            final padding = _calculatePadding(crossAxisCount);
            final maxCardWidth =
                _calculateMaxCardWidth(constraints.maxWidth, crossAxisCount);

            final itemCount = recipeCount +
                (recipeService.hasMore && recipeService.isLoading ? 1 : 0);

            return RefreshIndicator(
              onRefresh: () async {
                await recipeService.fetchRecipes(forceRefresh: true, page: 1);
              },
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  children: [
                    Center(
                      child: SizedBox(
                        width: constraints.maxWidth > 1200
                            ? constraints.maxWidth * 0.9
                            : constraints.maxWidth,
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: padding,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: spacing,
                            mainAxisSpacing: spacing,
                            childAspectRatio: 1.0,
                            mainAxisExtent: maxCardWidth,
                          ),
                          itemCount: itemCount,
                          itemBuilder: (context, index) {
                            if (index >= recipeCount) {
                              return _buildLoadingMore();
                            }
                            final recipe = recipes[index];
                            return SizedBox(
                              width: maxCardWidth,
                              child: RecipeCard(
                                key: ValueKey(recipe.id),
                                recipe: recipe,
                                onTap: () => widget.onRecipeTap(recipe),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    if (!recipeService.hasMore && recipes.isNotEmpty)
                      _buildEndOfList(),
                    SizedBox(height: ResponsiveValues.gapMedium(context)),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
