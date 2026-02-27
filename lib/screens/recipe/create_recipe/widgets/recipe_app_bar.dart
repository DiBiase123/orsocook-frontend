import 'package:flutter/material.dart';

class RecipeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isLoading;
  final VoidCallback onSave;
  final VoidCallback onBack;

  const RecipeAppBar({
    super.key,
    required this.isLoading,
    required this.onSave,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('Crea Nuova Ricetta'),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: onBack,
      ),
      actions: [
        if (isLoading)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          )
        else
          TextButton.icon(
            onPressed: onSave,
            icon: const Icon(Icons.save, color: Colors.white),
            label: const Text('Salva', style: TextStyle(color: Colors.white)),
          ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
