import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:orsocook/services/auth_service.dart';
import 'package:orsocook/screens/home/widgets/avatar_buttons.dart';
import 'package:orsocook/screens/home/widgets/recipe_search_bar.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onProfileTap;
  final VoidCallback onCreateRecipeTap;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;

  const HomeAppBar({
    super.key,
    required this.onProfileTap,
    required this.onCreateRecipeTap,
    required this.searchController,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        return AppBar(
          titleSpacing: 0,
          toolbarHeight: 64,
          flexibleSpace: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  // Titolo
                  const Text(
                    'OrsoCook',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 32),
                  // Search bar che occupa tutto lo spazio disponibile
                  Expanded(
                    child: RecipeSearchBar(
                      controller: searchController,
                      onSearchChanged: onSearchChanged,
                      compact: true,
                    ),
                  ),
                  const SizedBox(width: 24),
                  // Pulsante aggiungi
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: onCreateRecipeTap,
                    tooltip: 'Crea ricetta',
                    padding: const EdgeInsets.all(8),
                  ),
                  // Avatar profilo
                  GestureDetector(
                    onTap: onProfileTap,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8, right: 4),
                      child:
                          AvatarBuilder.buildAvatar(authService, onProfileTap),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(64);
}
