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
  AppLogger.setProductionMode();

  final authService = AuthService();
  await authService.initialize();

  runApp(MyApp(authService: authService));
}

class MyApp extends StatelessWidget {
  final AuthService authService;
  const MyApp({super.key, required this.authService});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthService>.value(value: authService),
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
            context.read<CategoryService>(),
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
        // 👇 MODIFICATO - aggiunto favoriteService
        ChangeNotifierProvider<ProfileController>(
          create: (context) => ProfileController(
            authService: context.read<AuthService>(),
            profileService: context.read<ProfileService>(),
            avatarService: context.read<AvatarService>(),
            commentService: context.read<CommentService>(),
            favoriteService: context.read<FavoriteService>(),
          ),
        ),
      ],
      child: _CacheInitializer(
        child: MaterialApp.router(
          title: 'OrsoCook',
          theme: AppTheme.lightTheme,
          routerConfig: goRouter,
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}

class _CacheInitializer extends StatefulWidget {
  final Widget child;
  const _CacheInitializer({required this.child});

  @override
  State<_CacheInitializer> createState() => __CacheInitializerState();
}

class __CacheInitializerState extends State<_CacheInitializer> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _preloadFavorites());
  }

  void _preloadFavorites() {
    try {
      final favoriteService = context.read<FavoriteService>();
      final recipeService = context.read<RecipeService>();

      for (final recipe in recipeService.cachedRecipes.take(20)) {
        favoriteService.isFavorite(recipe.id);
      }
    } catch (_) {
      // Ignora errori - non critico
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
