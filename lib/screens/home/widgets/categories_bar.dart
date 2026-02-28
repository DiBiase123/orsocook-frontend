import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:orsocook/services/category_service.dart';
import 'package:orsocook/utils/logger.dart';

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

  @override
  Widget build(BuildContext context) {
    return Consumer<CategoryService>(
      builder: (context, categoryService, child) {
        if (categoryService.isLoading && categoryService.categories.isEmpty) {
          return const SizedBox(
            height: 50,
            child: Center(
              child: CircularProgressIndicator.adaptive(),
            ),
          );
        }

        final categories = categoryService.categories;

        // Lista completa: "Tutte" + categorie reali
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

        return SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: allCategories.length,
            itemBuilder: (context, index) {
              final category = allCategories[index];
              final isSelected = widget.selectedCategorySlug == category.slug ||
                  (widget.selectedCategorySlug == null && index == 0);

              return Padding(
                padding: EdgeInsets.only(
                  left: index == 0 ? 16 : 8,
                  right: index == allCategories.length - 1 ? 16 : 0,
                ),
                child: ChoiceChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(category.name),
                      if (category.recipeCount > 0 && category.id != 'all')
                        Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: Text(
                            '(${category.recipeCount})',
                            style: TextStyle(
                              fontSize: 11,
                              color: isSelected
                                  ? Colors.white70
                                  : Colors.grey.shade600,
                            ),
                          ),
                        ),
                    ],
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      AppLogger.debug(
                          '🎯 Categoria selezionata: ${category.name} (${category.slug})');
                      widget.onCategorySelected
                          ?.call(category.id == 'all' ? null : category.slug);
                    }
                  },
                ),
              );
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
