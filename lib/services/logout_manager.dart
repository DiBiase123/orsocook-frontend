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

    // Salva il contesto prima dell'async
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

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

      // 3. Chiudi eventuali dialog aperti e torna alla home
      if (context.mounted) {
        navigator.popUntil((route) => route.isFirst);
        context.go('/home');

        // 4. Mostra il modal login dopo un breve delay
        Future.delayed(const Duration(milliseconds: 100), () {
          if (context.mounted) {
            showLoginModal(context);
          }
        });
      }
    } catch (e) {
      AppLogger.error('Errore durante logout', e);
      if (context.mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text('Errore durante il logout: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
