import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:orsocook/services/category_service.dart';
import 'package:orsocook/utils/logger.dart';
import 'package:orsocook/screens/home/widgets/categories_skeleton.dart';

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
    final theme = Theme.of(context);

    return Consumer<CategoryService>(
      builder: (context, categoryService, child) {
        if (categoryService.isLoading && categoryService.categories.isEmpty) {
          return const CategoriesSkeleton();
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

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: DropdownButtonFormField<String>(
            value: widget.selectedCategorySlug,
            decoration: InputDecoration(
              labelText: 'Categoria',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.category),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            items: allCategories.map((category) {
              return DropdownMenuItem<String>(
                value: category.slug.isEmpty ? null : category.slug,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        category.name,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    if (category.recipeCount > 0 && category.id != 'all')
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color:
                              theme.colorScheme.primary.withValues(alpha: 0.1),
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
            }).toList(),
            onChanged: (value) {
              // 👈 Evita chiamate multiple
              if (value == widget.selectedCategorySlug) return;

              AppLogger.debug('🎯 Categoria selezionata: $value');
              widget.onCategorySelected?.call(value);
            },
            // Stile del dropdown quando aperto
            dropdownColor: theme.colorScheme.surface,
            icon: Icon(Icons.arrow_drop_down, color: theme.colorScheme.primary),
            isExpanded: true,
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
