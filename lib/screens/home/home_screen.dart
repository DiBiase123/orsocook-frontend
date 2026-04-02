import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:orsocook/models/recipe.dart';
import 'package:orsocook/screens/auth/login.dart';
import 'package:orsocook/screens/home/viewmodels/home_viewmodel.dart';
import 'package:orsocook/screens/home/components/home_loading_screen.dart';
import 'package:orsocook/screens/home/components/home_carousel_section.dart';
import 'package:orsocook/screens/home/widgets/home_app_bar.dart';
import 'package:orsocook/screens/home/widgets/home_body.dart';
import 'package:orsocook/screens/home/widgets/categories_scroll_bar.dart';
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
          final isDesktop = screenWidth >= 900;

          // Desktop: AppBar fissa, niente scroll hide
          if (isDesktop) {
            return Scaffold(
              body: Column(
                children: [
                  HomeAppBar(
                    onProfileTap: _navigateToProfile,
                    onCreateRecipeTap: _navigateToCreateRecipe,
                    searchController: _searchController,
                    onSearchChanged: viewModel.onSearchChanged,
                  ),
                  Expanded(
                    child: ListView(
                      controller: _scrollController,
                      children: [
                        const SizedBox(height: 32),
                        SizedBox(
                          height: MediaQuery.of(context).size.height - 64,
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
                  ),
                ],
              ),
            );
          }

          // Mobile/Tablet: scroll hide con SliverAppBar
          return Scaffold(
            body: CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverAppBar(
                  automaticallyImplyLeading: false,
                  backgroundColor: const Color(0xFF6750A4),
                  elevation: 0,
                  floating: true,
                  snap: false,
                  pinned: false,
                  expandedHeight: screenWidth < 600 ? 130 : 135,
                  flexibleSpace: FlexibleSpaceBar(
                    background: HomeAppBar(
                      onProfileTap: _navigateToProfile,
                      onCreateRecipeTap: _navigateToCreateRecipe,
                      searchController: _searchController,
                      onSearchChanged: viewModel.onSearchChanged,
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      SizedBox(
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
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
