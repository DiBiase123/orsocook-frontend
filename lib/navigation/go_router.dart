import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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

final goRouter = GoRouter(
  initialLocation: '/',
  routes: [
    // Root redirects to login
    GoRoute(
      path: '/',
      redirect: (context, state) => '/login',
    ),
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      name: 'register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/verify-email',
      name: 'verify-email',
      builder: (context, state) {
        final token = state.uri.queryParameters['token'];
        return VerifyEmailScreen(token: token);
      },
    ),
    GoRoute(
      path: '/forgot-password',
      name: 'forgot-password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
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
    GoRoute(
      path: '/home',
      name: 'home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/profile',
      name: 'profile',
      builder: (context, state) => const ProfileScreen(),
    ),
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
    GoRoute(
      path: '/create-recipe',
      name: 'create-recipe',
      builder: (context, state) => const CreateRecipeScreen(),
    ),
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
