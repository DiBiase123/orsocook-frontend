import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:orsocook/services/auth_service.dart';
import 'package:orsocook/services/profile/profile_service.dart';
import 'package:orsocook/services/recipe_service.dart';
import 'package:orsocook/services/favorite_service.dart';
import 'package:orsocook/utils/logger.dart';
import 'package:orsocook/screens/auth/login.dart';

class LogoutManager {
  static Future<void> performLogout(BuildContext context) async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final profileService = Provider.of<ProfileService>(context, listen: false);
    final recipeService = Provider.of<RecipeService>(context, listen: false);
    final favoriteService =
        Provider.of<FavoriteService>(context, listen: false);

    AppLogger.warning('🚪 Logout completo - pulizia cache service');

    // 1. Prima pulisci le cache
    profileService.clearProfile();
    recipeService.clearCache();
    favoriteService.reset();

    // 2. Poi fai logout vero e proprio
    await authService.logout();

    // 3. Vai alla home (non al login)
    if (context.mounted) {
      context.go('/home');

      // 4. Dopo un breve delay, mostra il modal login
      Future.delayed(const Duration(milliseconds: 100), () {
        if (context.mounted) {
          showLoginModal(context);
        }
      });
    }
  }
}
