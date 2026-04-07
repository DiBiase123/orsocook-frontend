import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:orsocook/services/category_service.dart';
import 'package:orsocook/screens/home/widgets/categories_skeleton.dart';
import 'package:orsocook/utils/responsive_values.dart';

class CategoriesScrollBar extends StatelessWidget {
  final ValueChanged<String?> onCategorySelected;
  final String? selectedCategorySlug;

  const CategoriesScrollBar({
    super.key,
    required this.onCategorySelected,
    this.selectedCategorySlug,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<CategoryService>(
      builder: (context, categoryService, child) {
        if (categoryService.isLoading && categoryService.categories.isEmpty) {
          return const CategoriesSkeleton();
        }

        final categories = categoryService.categories;

        return Container(
          width: double.infinity,
          color: Colors.white,
          padding: EdgeInsets.symmetric(
              vertical: ResponsiveValues.gapMedium(context)),
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: ResponsiveValues.gapSmall(context),
            runSpacing: ResponsiveValues.gapSmall(context),
            children: [
              _buildCategoryChip(
                context: context,
                label: 'Tutte',
                isSelected: selectedCategorySlug == null,
                onTap: () => onCategorySelected(null),
                theme: theme,
                slug: null,
              ),
              ...categories.map((category) {
                final isSelected = selectedCategorySlug == category.slug;
                return _buildCategoryChip(
                  context: context,
                  label: category.name,
                  isSelected: isSelected,
                  onTap: () => onCategorySelected(category.slug),
                  recipeCount: category.recipeCount,
                  theme: theme,
                  slug: category.slug,
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoryChip({
    required BuildContext context,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    int? recipeCount,
    required ThemeData theme,
    String? slug,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: ActionChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: isSelected
                    ? ResponsiveValues.bodySize(context) + 2
                    : ResponsiveValues.bodySize(context),
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
            if (recipeCount != null && recipeCount > 0) ...[
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withAlpha(50)
                      : theme.colorScheme.primary.withAlpha(30),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$recipeCount',
                  style: TextStyle(
                    fontSize: isSelected ? 12 : 10,
                    fontWeight: FontWeight.w500,
                    color:
                        isSelected ? Colors.white : theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ],
        ),
        onPressed: () {
          if (label == 'Tutte') {
            onTap();
          } else if (slug != null) {
            context.push('/category/$slug');
          }
        },
        backgroundColor:
            isSelected ? theme.colorScheme.primary : Colors.transparent,
        side: BorderSide(
          color: isSelected ? Colors.transparent : Colors.grey[300]!,
          width: 1,
        ),
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : theme.colorScheme.primary,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
    );
  }
}
