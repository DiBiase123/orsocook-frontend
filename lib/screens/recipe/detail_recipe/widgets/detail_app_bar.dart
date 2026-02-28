import 'package:flutter/material.dart';
import 'package:orsocook/models/recipe.dart';

class DetailAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Recipe? recipe;
  final bool isOwner;
  final VoidCallback onBackPressed;
  final VoidCallback? onEditPressed;
  final VoidCallback? onDeletePressed;

  const DetailAppBar({
    super.key,
    this.recipe,
    required this.isOwner,
    required this.onBackPressed,
    this.onEditPressed,
    this.onDeletePressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(recipe?.title ?? 'Dettaglio Ricetta'),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: onBackPressed,
      ),
      actions: [
        if (isOwner && recipe != null) ...[
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.black87),
            onPressed: onEditPressed,
            tooltip: 'Modifica ricetta',
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.black87),
            onPressed: onDeletePressed,
            tooltip: 'Elimina ricetta',
          ),
        ],
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
