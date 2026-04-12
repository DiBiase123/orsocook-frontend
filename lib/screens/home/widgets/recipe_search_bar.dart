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
    final colorScheme = Theme.of(context).colorScheme;

    // Usa il tema per i colori di default
    final defaultFillColor = compact
        ? colorScheme.surfaceContainerHighest
        : colorScheme.surfaceContainerHigh;

    final fillColor = backgroundColor ?? defaultFillColor;

    // Colore del testo in base al tema
    final textColor = colorScheme.onSurface;
    final hintColor = colorScheme.onSurfaceVariant;

    if (compact) {
      return TextField(
        controller: controller,
        onChanged: onSearchChanged,
        style: TextStyle(fontSize: 14, color: textColor),
        decoration: InputDecoration(
          hintText: 'Cerca...',
          hintStyle: TextStyle(color: hintColor),
          prefixIcon: Icon(Icons.search, size: 18, color: hintColor),
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
      );
    }

    return TextField(
      controller: controller,
      onChanged: onSearchChanged,
      style: TextStyle(fontSize: 14, color: textColor),
      decoration: InputDecoration(
        hintText: 'Cerca ricette, ingredienti...',
        hintStyle: TextStyle(color: hintColor),
        prefixIcon: Icon(Icons.search, color: hintColor),
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
