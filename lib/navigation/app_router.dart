import 'package:flutter/material.dart';
import 'package:orsocook/screens/auth/login_screen.dart';
import 'package:orsocook/screens/auth/register_screen.dart';
import 'package:orsocook/screens/auth/verify_email_screen.dart';
import 'package:orsocook/screens/auth/forgot_password_screen.dart';
import 'package:orsocook/screens/auth/reset_password_screen.dart';
import 'package:orsocook/screens/home/home_screen.dart';
import 'package:orsocook/screens/profile/profile_screen.dart';
import 'package:orsocook/screens/recipe/detail_recipe/detail_recipe_screen.dart';
import 'package:orsocook/screens/recipe/create_recipe/create_recipe_screen.dart';
import 'package:orsocook/screens/recipe/edit_recipe_screen.dart';
import 'package:orsocook/screens/legal/privacy_policy_screen.dart';
import 'package:orsocook/screens/legal/cookie_policy_screen.dart';
import 'package:orsocook/models/recipe.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // Estrai query parameters per verificare token
    final uri = Uri.parse(settings.name ?? '/');
    final token = uri.queryParameters['token'];

    // Route normale senza controllo dimensioni
    return MaterialPageRoute(
      builder: (context) {
        return _buildScreenForRoute(settings, token, context);
      },
      settings: settings,
    );
  }

  // Metodo per costruire lo screen in base alla route
  static Widget _buildScreenForRoute(
    RouteSettings settings,
    String? token,
    BuildContext context,
  ) {
    switch (settings.name?.split('?')[0]) {
      case '/':
        return const LoginScreen();

      case '/login':
        return const LoginScreen();

      case '/register':
        return const RegisterScreen();

      case '/verify-email':
        return VerifyEmailScreen(token: token);

      case '/forgot-password':
        return const ForgotPasswordScreen();

      case '/reset-password':
        if (token == null || token.isEmpty) {
          return _buildErrorScreen('Token di reset mancante', settings);
        }
        return ResetPasswordScreen(token: token);

      case '/home':
        return const HomeScreen();

      case '/profile':
        return const ProfileScreen();

      case '/recipe/detail':
        final args = settings.arguments;
        if (args is String) {
          return DetailRecipeScreen(recipeId: args);
        }
        return _buildErrorScreen('Recipe ID mancante', settings);

      case '/create-recipe':
        return const CreateRecipeScreen();

      case '/recipe/edit':
        final args = settings.arguments;
        if (args is Recipe) {
          return EditRecipeScreen(recipe: args);
        }
        return _buildErrorScreen('Devi passare una Recipe', settings);

      case '/privacy-policy':
        return const PrivacyPolicyScreen();

      case '/cookie-policy':
        return const CookiePolicyScreen();

      default:
        return _buildErrorScreen('Route non trovata', settings);
    }
  }

  // Metodo per errori
  static Widget _buildErrorScreen(String message, RouteSettings settings) {
    return Builder(
      builder: (context) {
        return Scaffold(
          appBar: AppBar(title: const Text('Errore')),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Errore di navigazione',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  style: TextStyle(color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Route: ${settings.name}',
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    if (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    } else {
                      Navigator.of(context).pushReplacementNamed('/');
                    }
                  },
                  child: const Text('TORNA ALLA HOME'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Metodi di navigazione
  static Future<dynamic> goToEditRecipe(BuildContext context, Recipe recipe) {
    return Navigator.of(context).pushNamed(
      '/recipe/edit',
      arguments: recipe,
    );
  }

  static Future<dynamic> goToVerifyEmail(BuildContext context,
      {String? token}) {
    final route =
        token != null ? '/verify-email?token=$token' : '/verify-email';
    return Navigator.of(context).pushNamed(route);
  }

  static Future<dynamic> goToForgotPassword(BuildContext context) {
    return Navigator.of(context).pushNamed('/forgot-password');
  }

  static Future<dynamic> goToResetPassword(BuildContext context, String token) {
    return Navigator.of(context).pushNamed('/reset-password?token=$token');
  }

  // Metodi per legal pages
  static Future<dynamic> goToPrivacyPolicy(BuildContext context) {
    return Navigator.of(context).pushNamed('/privacy-policy');
  }

  static Future<dynamic> goToCookiePolicy(BuildContext context) {
    return Navigator.of(context).pushNamed('/cookie-policy');
  }
}
