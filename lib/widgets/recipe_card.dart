import 'package:flutter/material.dart';
import 'package:orsocook/models/recipe.dart';
import 'package:orsocook/screens/recipe/widgets/favorite_button.dart';
import 'package:orsocook/screens/recipe/widgets/like_button.dart';
import 'package:provider/provider.dart';
import 'package:orsocook/services/favorite_service.dart';

@immutable
class RecipeCard extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback onTap;
  final bool showAuthor;

  const RecipeCard({
    super.key,
    required this.recipe,
    required this.onTap,
    this.showAuthor = false,
  });

  @override
  Widget build(BuildContext context) {
    final favoriteService =
        Provider.of<FavoriteService>(context, listen: false);
    favoriteService.registerRecipeTitle(recipe.id, recipe.title);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (recipe.imageUrl != null && recipe.imageUrl!.isNotEmpty)
              _buildRecipeImage()
            else
              _buildPlaceholderImage(),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  if (recipe.description.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(
                        recipe.description,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  _buildRecipeInfo(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipeInfo() {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 200),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Row(
              children: [
                const Icon(Icons.timer, size: 12, color: Colors.grey),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    '${recipe.totalTime}',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Flexible(
            child: Row(
              children: [
                const Icon(Icons.restaurant, size: 12, color: Colors.grey),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    '${recipe.servings}',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipeImage() {
    final imageUrl = recipe.imageUrl!;

    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
          ),
          child: SizedBox(
            height: 120,
            width: double.infinity,
            child: _OptimizedRecipeImage(imageUrl: imageUrl),
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: Row(
            children: [
              _buildButtonContainer(
                child: LikeButton(
                  recipeId: recipe.id,
                  size: 18,
                ),
                margin: const EdgeInsets.only(right: 4),
              ),
              _buildButtonContainer(
                child: FavoriteButton(
                  recipeId: recipe.id,
                  recipe: recipe,
                  size: 18,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholderImage() {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
          ),
          child: Container(
            height: 120,
            width: double.infinity,
            color: Colors.grey[200],
            child: const Center(
              child: Icon(
                Icons.restaurant,
                size: 40,
                color: Colors.grey,
              ),
            ),
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: Row(
            children: [
              _buildButtonContainer(
                child: LikeButton(
                  recipeId: recipe.id,
                  size: 18,
                ),
                margin: const EdgeInsets.only(right: 4),
              ),
              _buildButtonContainer(
                child: FavoriteButton(
                  recipeId: recipe.id,
                  recipe: recipe,
                  size: 18,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildButtonContainer({
    required Widget child,
    EdgeInsetsGeometry? margin,
  }) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(230),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(26),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _OptimizedRecipeImage extends StatelessWidget {
  final String imageUrl;

  const _OptimizedRecipeImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Image.network(
      imageUrl,
      headers: {'Accept': 'image/*'},
      cacheWidth: 300,
      cacheHeight: 180,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;

        return Container(
          color: Colors.grey[200],
          child: Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.red[100],
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, color: Colors.red, size: 30),
                SizedBox(height: 4),
                Text(
                  'Image error',
                  style: TextStyle(color: Colors.red, fontSize: 10),
                ),
              ],
            ),
          ),
        );
      },
      fit: BoxFit.cover,
      filterQuality: FilterQuality.medium,
    );
  }
}
