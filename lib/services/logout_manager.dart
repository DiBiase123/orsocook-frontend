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
    AppLogger.warning('🚪 Logout completo - pulizia cache service');

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final profileService =
          Provider.of<ProfileService>(context, listen: false);
      final recipeService = Provider.of<RecipeService>(context, listen: false);
      final favoriteService =
          Provider.of<FavoriteService>(context, listen: false);

      // 1. Pulisci le cache
      profileService.clearProfile();
      recipeService.clearCache();
      favoriteService.reset();

      // 2. Logout
      await authService.logout();

      // 3. Verifica che il contesto sia ancora valido
      if (!context.mounted) return;

      // 4. Torna alla home
      context.go('/home');

      // 5. Mostra il modal login dopo un breve delay
      Future.delayed(const Duration(milliseconds: 100), () {
        if (context.mounted) {
          showLoginModal(context);
        }
      });
    } catch (e) {
      AppLogger.error('Errore durante logout', e);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Errore durante il logout: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
