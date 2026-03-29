import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:orsocook/screens/auth/reset_password_screen.dart';
import 'package:orsocook/screens/auth/verify_email_screen.dart';
import 'package:orsocook/screens/home/home_screen.dart';
import 'package:orsocook/screens/profile/profile_screen.dart';
import 'package:orsocook/screens/recipe/detail_recipe/detail_recipe_screen.dart';
import 'package:orsocook/screens/recipe/create_recipe/create_recipe_screen.dart';
import 'package:orsocook/screens/recipe/edit_recipe_screen.dart';
import 'package:orsocook/screens/category/category_recipes_screen.dart';
import 'package:orsocook/screens/legal/privacy_policy_screen.dart';
import 'package:orsocook/screens/legal/cookie_policy_screen.dart';
import 'package:orsocook/models/recipe.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final goRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      redirect: (context, state) => '/home',
    ),
    // Reset password - screen (arriva da email)
    GoRoute(
      path: '/reset-password',
      name: 'reset-password',
      builder: (context, state) {
        final token = state.uri.queryParameters['token'];
        if (token == null || token.isEmpty) {
          return const Scaffold(
            body: Center(child: Text('Token di reset mancante')),
          );
        }
        return ResetPasswordScreen(token: token);
      },
    ),
    // Verify email - screen (arriva da email)
    GoRoute(
      path: '/verify-email',
      name: 'verify-email',
      builder: (context, state) {
        final token = state.uri.queryParameters['token'];
        return VerifyEmailScreen(token: token);
      },
    ),
    // Home
    GoRoute(
      path: '/home',
      name: 'home',
      builder: (context, state) => const HomeScreen(),
    ),
    // Profile
    GoRoute(
      path: '/profile',
      name: 'profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    // Recipe detail
    GoRoute(
      path: '/recipe/detail/:id',
      name: 'recipe-detail',
      builder: (context, state) {
        final id = state.pathParameters['id'];
        if (id == null) {
          return const Scaffold(
            body: Center(child: Text('ID ricetta mancante')),
          );
        }
        return DetailRecipeScreen(recipeId: id);
      },
    ),
    // Create recipe
    GoRoute(
      path: '/create-recipe',
      name: 'create-recipe',
      builder: (context, state) => const CreateRecipeScreen(),
    ),
    // Edit recipe
    GoRoute(
      path: '/recipe/edit',
      name: 'recipe-edit',
      builder: (context, state) {
        final recipe = state.extra as Recipe?;
        if (recipe == null) {
          return const Scaffold(
            body: Center(child: Text('Ricetta mancante')),
          );
        }
        return EditRecipeScreen(recipe: recipe);
      },
    ),
    // Category
    GoRoute(
      path: '/category/:categorySlug',
      name: 'category',
      builder: (context, state) {
        final categorySlug = state.pathParameters['categorySlug'];
        if (categorySlug == null || categorySlug.isEmpty) {
          return const Scaffold(
            body: Center(child: Text('Categoria non valida')),
          );
        }
        return CategoryRecipesScreen(categorySlug: categorySlug);
      },
    ),
    // Legal
    GoRoute(
      path: '/privacy-policy',
      name: 'privacy-policy',
      builder: (context, state) => const PrivacyPolicyScreen(),
    ),
    GoRoute(
      path: '/cookie-policy',
      name: 'cookie-policy',
      builder: (context, state) => const CookiePolicyScreen(),
    ),
  ],
);
