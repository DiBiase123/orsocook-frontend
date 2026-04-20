import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:orsocook/services/category_service.dart';
import 'package:orsocook/screens/home/widgets/categories_skeleton.dart';
import 'package:orsocook/utils/responsive_utils.dart';

class CategoriesBar extends StatefulWidget {
  final ValueChanged<String?>? onCategorySelected;
  final String? selectedCategorySlug;

  const CategoriesBar({
    super.key,
    this.onCategorySelected,
    this.selectedCategorySlug,
  });

  @override
  State<CategoriesBar> createState() => _CategoriesBarState();
}

class _CategoriesBarState extends State<CategoriesBar> {
  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final categoryService = context.read<CategoryService>();
    if (categoryService.categories.isEmpty) {
      await categoryService.fetchCategories();
    }
  }

  String _getSelectedCategoryName(List<_CategoryItem> categories) {
    if (widget.selectedCategorySlug == null) {
      return 'Tutte';
    }
    final selected = categories.firstWhere(
      (c) => c.slug == widget.selectedCategorySlug,
      orElse: () => const _CategoryItem(id: 'all', name: 'Tutte', slug: ''),
    );
    return selected.name;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<CategoryService>(
      builder: (context, categoryService, child) {
        if (categoryService.isLoading && categoryService.categories.isEmpty) {
          return const CategoriesSkeleton();
        }

        final categories = categoryService.categories;

        final allCategories = [
          const _CategoryItem(
            id: 'all',
            name: 'Tutte',
            slug: '',
          ),
          ...categories.map((cat) => _CategoryItem(
                id: cat.id,
                name: cat.name,
                slug: cat.slug,
                recipeCount: cat.recipeCount,
              )),
        ];

        final selectedName = _getSelectedCategoryName(allCategories);

        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveValues.horizontalPadding(context).horizontal,
            vertical: ResponsiveValues.gapSmall(context),
          ),
          child: PopupMenuButton<String>(
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: 'Categoria',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.category),
                suffixIcon: Icon(Icons.arrow_drop_down,
                    color: theme.colorScheme.primary),
              ),
              child: Text(
                selectedName,
                style: TextStyle(fontSize: ResponsiveValues.bodySize(context)),
              ),
            ),
            itemBuilder: (context) {
              return allCategories.map((category) {
                return PopupMenuItem<String>(
                  value: category.slug.isEmpty ? '' : category.slug,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(category.name),
                      ),
                      if (category.recipeCount > 0 && category.id != 'all')
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${category.recipeCount}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              }).toList();
            },
            onSelected: (value) {
              if (value == widget.selectedCategorySlug) return;
              widget.onCategorySelected?.call(value.isEmpty ? null : value);
            },
          ),
        );
      },
    );
  }
}

class _CategoryItem {
  final String id;
  final String name;
  final String slug;
  final int recipeCount;

  const _CategoryItem({
    required this.id,
    required this.name,
    required this.slug,
    this.recipeCount = 0,
  });
}
