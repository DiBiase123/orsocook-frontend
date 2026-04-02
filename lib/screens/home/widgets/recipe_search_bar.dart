import 'package:flutter/material.dart';
import 'package:orsocook/utils/logger.dart';

class RecipeSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onSearchChanged;
  final bool compact;
  final Color? backgroundColor;
  final double? height;

  const RecipeSearchBar({
    super.key,
    required this.controller,
    required this.onSearchChanged,
    this.compact = false,
    this.backgroundColor,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    AppLogger.debug('🔍 Building RecipeSearchBar');

    final searchBar = TextField(
      controller: controller,
      onChanged: onSearchChanged,
      decoration: InputDecoration(
        hintText: compact ? 'Cerca...' : 'Cerca ricette, ingredienti...',
        prefixIcon: Icon(Icons.search, size: compact ? 18 : 24),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(compact ? 20 : 12),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor:
            backgroundColor ?? (compact ? Colors.grey[200] : Colors.grey[100]),
        contentPadding: compact
            ? const EdgeInsets.symmetric(vertical: 0, horizontal: 12)
            : const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
        isDense: true,
      ),
      style: TextStyle(fontSize: compact ? 14 : 16),
    );

    if (height != null) {
      return SizedBox(height: height, child: searchBar);
    }

    if (compact) {
      return searchBar;
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: searchBar,
    );
  }
}
