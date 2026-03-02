import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:orsocook/services/auth_service.dart';
import 'package:orsocook/services/recipe_service.dart';
import 'package:orsocook/services/comment_service.dart';
import 'package:orsocook/services/profile_service.dart';
import 'package:orsocook/services/avatar_service.dart';
import 'package:orsocook/services/profile_controller.dart';
import 'package:orsocook/services/like_service.dart';
import 'package:orsocook/services/favorite_service.dart';
import 'package:orsocook/services/category_service.dart';
import 'package:orsocook/navigation/go_router.dart';
import 'package:orsocook/utils/app_theme.dart';
import 'package:orsocook/utils/logger.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configura logger
  AppLogger.setProductionMode();

  // Inizializza Auth Service
  final authService = AuthService();
  await authService.initialize();

  runApp(MyApp(authService: authService));
}

class MyApp extends StatelessWidget {
  final AuthService authService;

  const MyApp({super.key, required this.authService});

  @override
  Widget build(BuildContext context) {
    // 🔍 DEBUG VISIBILE SU PAGINA BIANCA
    debugPrint('🚀 MAIN DART: build iniziato');
    debugPrint('📍 Path corrente: ${Uri.base.path}');
    debugPrint('📍 Query: ${Uri.base.query}');

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthService>.value(value: authService),

        // 👇 NUOVO PROVIDER
        ChangeNotifierProvider<CategoryService>(
          create: (context) => CategoryService(context.read<AuthService>()),
        ),

        ChangeNotifierProvider<LikeService>(
          create: (context) => LikeService(context.read<AuthService>()),
        ),
        ChangeNotifierProvider<FavoriteService>(
          create: (context) => FavoriteService(context.read<AuthService>()),
        ),
        ChangeNotifierProvider<RecipeService>(
          create: (context) => RecipeService(
            context.read<AuthService>(),
            context.read<CategoryService>(), // 👈 AGGIUNTO
          ),
        ),
        ChangeNotifierProvider<ProfileService>(
          create: (context) => ProfileService(context.read<AuthService>()),
        ),
        ChangeNotifierProvider<AvatarService>(
          create: (context) => AvatarService(),
        ),
        ChangeNotifierProvider<CommentService>(
          create: (context) => CommentService(context.read<AuthService>()),
        ),
        ChangeNotifierProvider<ProfileController>(
          create: (context) => ProfileController(
            authService: context.read<AuthService>(),
            profileService: context.read<ProfileService>(),
            avatarService: context.read<AvatarService>(),
            commentService: context.read<CommentService>(),
          ),
        ),
      ],
      child: MaterialApp.router(
        title: 'OrsoCook',
        theme: AppTheme.lightTheme,
        routerConfig: goRouter,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
