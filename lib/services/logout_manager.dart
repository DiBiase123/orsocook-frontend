import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:orsocook/services/auth_service.dart';
import 'package:orsocook/services/profile/profile_service.dart';
import 'package:orsocook/services/recipe_service.dart';
import 'package:orsocook/services/favorite_service.dart';
import 'package:orsocook/utils/logger.dart';

class LogoutManager {
  static void performLogout(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final profileService = Provider.of<ProfileService>(context, listen: false);
    final recipeService = Provider.of<RecipeService>(context, listen: false);
    final favoriteService =
        Provider.of<FavoriteService>(context, listen: false);

    AppLogger.warning('🚪 Logout completo - pulizia cache service');

    // 1. Prima pulisci le cache
    profileService.clearProfile();
    recipeService.clearCache();
    favoriteService.reset(); // reset() in FavoriteService

    // 2. Poi fai logout vero e proprio
    authService.logout();

    // 3. Naviga al login
    context.go('/login');
  }
}
