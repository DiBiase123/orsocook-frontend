import 'package:flutter/material.dart';
import 'package:orsocook/utils/logger.dart';

class RecipeSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onSearchChanged;
  final bool compact;
  final Color? backgroundColor;

  const RecipeSearchBar({
    super.key,
    required this.controller,
    required this.onSearchChanged,
    this.compact = false,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    AppLogger.debug('🔍 Building RecipeSearchBar');

    final fillColor =
        backgroundColor ?? (compact ? Colors.grey[200] : Colors.grey[100]);

    if (compact) {
      return TextField(
        controller: controller,
        onChanged: onSearchChanged,
        decoration: InputDecoration(
          hintText: 'Cerca...',
          prefixIcon: const Icon(Icons.search, size: 18),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: fillColor,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
          isDense: true,
        ),
        style: const TextStyle(fontSize: 14),
      );
    }

    return TextField(
      controller: controller,
      onChanged: onSearchChanged,
      decoration: InputDecoration(
        hintText: 'Cerca ricette, ingredienti...',
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: fillColor,
        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
        isDense: true,
      ),
    );
  }
}
