import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import 'package:orsocook/services/auth_service.dart';
import 'package:orsocook/services/activity_tracker.dart';
import 'package:orsocook/services/recipe_service.dart';
import 'package:orsocook/services/comment_service.dart';
import 'package:orsocook/services/profile/profile_service.dart';
import 'package:orsocook/services/avatar_service.dart';
import 'package:orsocook/services/profile/profile_controller.dart';
import 'package:orsocook/services/like_service.dart';
import 'package:orsocook/services/favorite_service.dart';
import 'package:orsocook/services/category_service.dart';
import 'package:orsocook/navigation/go_router.dart';
import 'package:orsocook/utils/app_theme.dart';
import 'package:orsocook/utils/logger.dart';

final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
        PointerDeviceKind.invertedStylus,
      };
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb) {
    SystemChrome.setApplicationSwitcherDescription(
      const ApplicationSwitcherDescription(
        label: 'OrsoCook',
        primaryColor: 0xFF6750A4,
      ),
    );
  }

  if (kReleaseMode) {
    AppLogger.setProductionMode();
  }

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
        ChangeNotifierProvider<ActivityTracker>(
          create: (context) => ActivityTracker(
            context.read<AuthService>(),
            _navigatorKey,
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
              scrollBehavior: MyCustomScrollBehavior(),
            ),
          );
        },
      ),
    );
  }
}
