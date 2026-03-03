import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:orsocook/services/auth_service.dart';
import 'package:orsocook/services/activity_tracker.dart';
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

// 👈 DICHIARAZIONE GLOBALE DELLA KEY
final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configura logger
  if (kDebugMode) {
    AppLogger.setVerboseMode(); // Log dettagliati in sviluppo
  } else {
    AppLogger.setProductionMode(); // Nessun log in produzione
  }

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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthService>.value(value: authService),

        // Activity Tracker con navigatorKey
        ChangeNotifierProvider<ActivityTracker>(
          create: (context) => ActivityTracker(
            context.read<AuthService>(),
            _navigatorKey, // 👈 PASSA LA KEY
          ),
        ),

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
      child: Consumer<ActivityTracker>(
        builder: (context, activityTracker, child) {
          return Listener(
            onPointerDown: (_) => activityTracker.reportUserActivity(),
            onPointerMove: (_) => activityTracker.reportUserActivity(),
            onPointerUp: (_) => activityTracker.reportUserActivity(),
            child: MaterialApp.router(
              title: 'OrsoCook',
              theme: AppTheme.lightTheme,
              routerConfig: goRouter,
              debugShowCheckedModeBanner: false,
            ),
          );
        },
      ),
    );
  }
}
