import 'package:flutter/material.dart';
import 'package:orsocook/screens/home/widgets/index.dart';
import 'package:orsocook/services/auth_service.dart';

class HomeLoadingScreen extends StatelessWidget {
  final AuthService authService;
  final TextEditingController searchController;
  final VoidCallback onCreateRecipe;
  final VoidCallback onProfileTap;
  final Function(String) onSearchChanged;

  const HomeLoadingScreen({
    super.key,
    required this.authService,
    required this.searchController,
    required this.onCreateRecipe,
    required this.onProfileTap,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        toolbarHeight: 64,
        flexibleSpace: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Text(
                  'OrsoCook',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 32),
                Expanded(
                  child: RecipeSearchBar(
                    controller: searchController,
                    onSearchChanged: onSearchChanged,
                    compact: true,
                  ),
                ),
                const SizedBox(width: 24),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: onCreateRecipe,
                  tooltip: 'Crea ricetta',
                  padding: const EdgeInsets.all(8),
                ),
                GestureDetector(
                  onTap: onProfileTap,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8, right: 4),
                    child: AvatarBuilder.buildAvatar(authService, onProfileTap),
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
        ),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Caricamento ricette...'),
          ],
        ),
      ),
    );
  }
}
