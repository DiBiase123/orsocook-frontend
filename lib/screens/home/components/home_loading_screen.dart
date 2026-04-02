import 'package:flutter/material.dart';
import 'package:orsocook/screens/home/widgets/home_app_bar.dart';
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
      body: Column(
        children: [
          HomeAppBar(
            onProfileTap: onProfileTap,
            onCreateRecipeTap: onCreateRecipe,
            searchController: searchController,
            onSearchChanged: onSearchChanged,
          ),
          const Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Caricamento ricette...'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
