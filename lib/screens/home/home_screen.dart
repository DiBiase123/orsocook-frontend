import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:orsocook/models/recipe.dart';
import 'package:orsocook/screens/auth/login.dart';
import 'package:orsocook/screens/home/viewmodels/home_viewmodel.dart';
import 'package:orsocook/screens/home/components/home_loading_screen.dart';
import 'package:orsocook/screens/home/components/home_carousel_section.dart';
import 'package:orsocook/screens/home/widgets/index.dart';
import 'package:orsocook/services/recipe_service.dart';
import 'package:orsocook/services/like_service.dart';
import 'package:orsocook/services/category_service.dart';
import 'package:orsocook/services/auth_service.dart';
import 'package:orsocook/utils/logger.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late HomeViewModel _viewModel;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initializeViewModel();
  }

  void _initializeViewModel() {
    _viewModel = HomeViewModel(
      recipeService: context.read<RecipeService>(),
      likeService: context.read<LikeService>(),
      categoryService: context.read<CategoryService>(),
    );

    _viewModel.addListener(() {
      if (mounted) setState(() {});
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.loadInitialRecipes().catchError((e) {
        AppLogger.error('Errore nel caricamento iniziale', e);
      });
    });
  }

  void _navigateToCreateRecipe() {
    final authService = context.read<AuthService>();
    if (!authService.isLoggedIn) {
      _showLoginRequiredDialog(
        title: 'Accesso richiesto',
        content: 'Devi effettuare il login per creare una ricetta.',
      );
      return;
    }
    context.go('/create-recipe');
  }

  void _navigateToProfile() {
    final authService = context.read<AuthService>();
    if (!authService.isLoggedIn) {
      AppLogger.debug('🔍 [HOME] Chiamo showLoginModal');
      showLoginModal(context);
      return;
    }
    context.go('/profile');
  }

  void _navigateToRecipeDetail(Recipe recipe) {
    if (recipe.id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Errore: ID ricetta non valido')),
      );
      return;
    }
    context.push('/recipe/detail/${recipe.id}', extra: recipe);
  }

  void _showLoginRequiredDialog({
    required String title,
    required String content,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ANNULLA'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              showLoginModal(context);
            },
            child: const Text('LOGIN'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _viewModel.disposeViewModel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<HomeViewModel>.value(
      value: _viewModel,
      child: Consumer2<HomeViewModel, AuthService>(
        builder: (context, viewModel, authService, child) {
          if (viewModel.shouldShowLoading(viewModel.recipes.isEmpty)) {
            return HomeLoadingScreen(
              authService: authService,
              searchController: _searchController,
              onCreateRecipe: _navigateToCreateRecipe,
              onProfileTap: _navigateToProfile,
              onSearchChanged: viewModel.onSearchChanged,
            );
          }

          final carouselRecipes = viewModel.recipes.take(6).toList();
          final screenWidth = MediaQuery.of(context).size.width;
          final isDesktop = screenWidth > 768;

          return Scaffold(
            appBar: AppBar(
              titleSpacing: 0,
              toolbarHeight: 64,
              flexibleSpace: SafeArea(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      // Logo placeholder temporaneo
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(50),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.restaurant,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'OrsoCook',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 32),
                      Expanded(
                        child: RecipeSearchBar(
                          controller: _searchController,
                          onSearchChanged: viewModel.onSearchChanged,
                          compact: true,
                        ),
                      ),
                      const SizedBox(width: 24),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: _navigateToCreateRecipe,
                        tooltip: 'Crea ricetta',
                        padding: const EdgeInsets.all(8),
                      ),
                      GestureDetector(
                        onTap: _navigateToProfile,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8, right: 4),
                          child: AvatarBuilder.buildAvatar(
                              authService, _navigateToProfile),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                ),
              ),
            ),
            body: ListView(
              controller: _scrollController,
              children: [
                if (isDesktop) const SizedBox(height: 32),
                isDesktop
                    ? SizedBox(
                        height: MediaQuery.of(context).size.height - 64,
                        child: HomeCarouselSection(
                          recipes: carouselRecipes,
                          onRecipeTap: _navigateToRecipeDetail,
                        ),
                      )
                    : SizedBox(
                        height: 400,
                        child: HomeCarouselSection(
                          recipes: carouselRecipes,
                          onRecipeTap: _navigateToRecipeDetail,
                        ),
                      ),
                CategoriesScrollBar(
                  onCategorySelected: (slug) {
                    if (slug != null) context.push('/category/$slug');
                  },
                  selectedCategorySlug: null,
                ),
                HomeBody(
                  onCreateRecipeTap: _navigateToCreateRecipe,
                  searchController: _searchController,
                  onRecipeTap: _navigateToRecipeDetail,
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
}
