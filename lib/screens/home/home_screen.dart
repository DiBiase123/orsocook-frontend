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
import 'package:orsocook/screens/home/widgets/category_section/index.dart';
import 'package:orsocook/services/recipe_service.dart';
import 'package:orsocook/services/like_service.dart';
import 'package:orsocook/services/category_service.dart';
import 'package:orsocook/services/auth_service.dart';
import 'package:orsocook/utils/logger.dart';
import 'package:orsocook/widgets/shimmer_effect.dart';

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

  @override
  void dispose() {
    _viewModel.disposeViewModel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
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

  String _formatSlugToTitle(String slug) {
    return slug
        .replaceAll('-', ' ')
        .split(' ')
        .map((word) => word.isNotEmpty
            ? '${word[0].toUpperCase()}${word.substring(1)}'
            : word)
        .join(' ');
  }

  Widget _buildSections(HomeViewModel viewModel, bool isDesktop) {
    if (viewModel.isLoadingSections) {
      return ShimmerCategorySection(isDesktop: isDesktop);
    }

    if (viewModel.sectionRecipes.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: viewModel.sectionRecipes.entries.map((entry) {
        final categoryName =
            entry.value.isNotEmpty && entry.value.first.category != null
                ? entry.value.first.category!.name
                : _formatSlugToTitle(entry.key);

        return CategorySection(
          title: categoryName,
          categorySlug: entry.key,
          recipes: entry.value,
        );
      }).toList(),
    );
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

          final screenWidth = MediaQuery.of(context).size.width;
          final isDesktop = screenWidth >= 900;
          final carouselRecipes = viewModel.recipes.take(6).toList();

          final appBar = HomeAppBar(
            onProfileTap: _navigateToProfile,
            onCreateRecipeTap: _navigateToCreateRecipe,
            searchController: _searchController,
            onSearchChanged: viewModel.onSearchChanged,
          );

          final categoriesBar = CategoriesScrollBar(
            onCategorySelected: (slug) => viewModel.onCategorySelected(slug),
            selectedCategorySlug: viewModel.selectedCategory,
          );

          final mainContent = viewModel.hasActiveFilter
              ? HomeBody(
                  onCreateRecipeTap: _navigateToCreateRecipe,
                  searchController: _searchController,
                  onRecipeTap: _navigateToRecipeDetail,
                )
              : Column(
                  children: [
                    if (carouselRecipes.isNotEmpty)
                      SizedBox(
                        height: isDesktop ? 500 : 350,
                        child: HomeCarouselSection(
                          recipes: carouselRecipes,
                          onRecipeTap: _navigateToRecipeDetail,
                        ),
                      ),
                    const SizedBox(height: 16),
                    _buildSections(viewModel, isDesktop),
                  ],
                );

          if (isDesktop) {
            return Scaffold(
              body: Column(
                children: [
                  appBar,
                  Expanded(
                    child: ListView(
                      controller: _scrollController,
                      children: [
                        const SizedBox(height: 16),
                        categoriesBar,
                        const SizedBox(height: 16),
                        mainContent,
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }

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
                  flexibleSpace: FlexibleSpaceBar(background: appBar),
                ),
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      categoriesBar,
                      const SizedBox(height: 16),
                      mainContent,
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
