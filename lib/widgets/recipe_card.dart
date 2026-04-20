import 'package:flutter/material.dart';
import 'package:orsocook/models/recipe.dart';
import 'package:orsocook/screens/recipe/widgets/favorite_button.dart';
import 'package:orsocook/screens/recipe/widgets/like_button.dart';
import 'package:provider/provider.dart';
import 'package:orsocook/services/favorite_service.dart';
import 'package:orsocook/utils/responsive_utils.dart';

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
    final colorScheme = Theme.of(context).colorScheme;

    return _HoverCard(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(20),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageSection(context),
            _buildContentSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
          child: SizedBox(
            height: 160,
            width: double.infinity,
            child: recipe.imageUrl != null && recipe.imageUrl!.isNotEmpty
                ? Image.network(
                    recipe.imageUrl!,
                    headers: {'Accept': 'image/*'},
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: colorScheme.surfaceContainerHighest,
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
                        color: colorScheme.surfaceContainerHighest,
                        child: Icon(
                          Icons.restaurant,
                          size: 48,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      );
                    },
                  )
                : Container(
                    color: colorScheme.surfaceContainerHighest,
                    child: Icon(
                      Icons.restaurant,
                      size: 48,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
          ),
        ),
        Positioned(
          top: 12,
          left: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withAlpha(180),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.timer, size: 12, color: Colors.white),
                const SizedBox(width: 4),
                Text(
                  '${recipe.totalTime} min',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: 12,
          right: 12,
          child: _buildActionButtons(context),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(40),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: LikeButton(
            recipeId: recipe.id,
            size: 18,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(40),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: FavoriteButton(
            recipeId: recipe.id,
            recipe: recipe,
            size: 18,
          ),
        ),
      ],
    );
  }

  Widget _buildContentSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            recipe.title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              height: 1.3,
              color: colorScheme.onSurface,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: ResponsiveValues.gapSmall(context)),
          Row(
            children: [
              _buildInfoChip(
                icon: Icons.thermostat,
                label: _getDifficultyLabel(recipe.difficulty),
                color: _getDifficultyColor(recipe.difficulty),
              ),
              const SizedBox(width: 8),
              _buildInfoChip(
                icon: Icons.people,
                label: '${recipe.servings}',
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
          if (showAuthor && recipe.author.displayName != null) ...[
            SizedBox(height: ResponsiveValues.gapMedium(context)),
            Row(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundImage: recipe.author.avatarUrl != null
                      ? NetworkImage(recipe.author.avatarUrl!)
                      : null,
                  child: recipe.author.avatarUrl == null
                      ? const Icon(Icons.person, size: 12)
                      : null,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    recipe.author.displayName ?? recipe.author.username,
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _getDifficultyLabel(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return 'Facile';
      case Difficulty.medium:
        return 'Media';
      case Difficulty.hard:
        return 'Difficile';
    }
  }

  Color _getDifficultyColor(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return Colors.green;
      case Difficulty.medium:
        return Colors.orange;
      case Difficulty.hard:
        return Colors.red;
    }
  }
}

class _HoverCard extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _HoverCard({
    required this.child,
    required this.onTap,
  });

  @override
  State<_HoverCard> createState() => _HoverCardState();
}

class _HoverCardState extends State<_HoverCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Stack(
          children: [
            widget.child,
            AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: _isHovered ? 0.08 : 0.0,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
