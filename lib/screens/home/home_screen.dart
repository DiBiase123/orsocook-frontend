import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:orsocook/models/recipe.dart';
import 'package:orsocook/services/recipe_service.dart';
import 'package:orsocook/services/auth_service.dart';
import 'package:orsocook/services/like_service.dart';
import 'package:orsocook/services/category_service.dart';
import 'package:orsocook/utils/logger.dart';
import 'package:orsocook/screens/recipe/detail_recipe_screen.dart';
import 'package:orsocook/screens/home/widgets/welcome_header.dart';
import 'package:orsocook/screens/home/widgets/recipe_search_bar.dart';
import 'package:orsocook/screens/home/widgets/categories_bar.dart';
import 'package:orsocook/screens/home/widgets/empty_state.dart';
import 'package:orsocook/screens/home/widgets/recipe_list.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _searchQuery;
  String? _selectedCategory;
  bool _isLoadingFilters = false;

  static const String _prefKeySelectedCategory = 'selected_category';
  final Duration _animationDuration = const Duration(milliseconds: 300);

  @override
  void initState() {
    super.initState();
    _loadSavedCategory();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialRecipes().catchError((e) {
        AppLogger.error('Errore nel caricamento iniziale', e);
      });
    });
  }

  // Carica categoria salvata
  Future<void> _loadSavedCategory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedCategory = prefs.getString(_prefKeySelectedCategory);
      if (savedCategory != null && savedCategory.isNotEmpty) {
        setState(() => _selectedCategory = savedCategory);
        WidgetsBinding.instance
            .addPostFrameCallback((_) => _loadRecipesWithFilters());
      }
    } catch (e) {
      AppLogger.error('Errore nel caricamento categoria salvata', e);
    }
  }

  Future<void> _loadInitialRecipes() async {
    if (!mounted) return;

    try {
      final recipeService = context.read<RecipeService>();
      final likeService = context.read<LikeService>();
      final categoryService = context.read<CategoryService>();

      await categoryService.fetchCategories(forceRefresh: true);

      if (_selectedCategory == null) {
        await recipeService.fetchRecipes(forceRefresh: true, page: 1);
      }

      if (!mounted) return;

      final recipeIds = recipeService.cachedRecipes.map((r) => r.id).toList();
      likeService.preloadLikesCount(recipeIds);
    } catch (e) {
      if (mounted) AppLogger.error('Errore caricamento ricette iniziali', e);
    }
  }

  void _onCategorySelected(String? categorySlug) async {
    if (_selectedCategory == categorySlug) return;

    setState(() => _selectedCategory = categorySlug);

    try {
      final prefs = await SharedPreferences.getInstance();
      if (categorySlug == null) {
        await prefs.remove(_prefKeySelectedCategory);
      } else {
        await prefs.setString(_prefKeySelectedCategory, categorySlug);
      }
    } catch (e) {
      AppLogger.error('Errore nel salvare categoria', e);
    }

    _loadRecipesWithFilters();
  }

  Future<void> _loadRecipesWithFilters() async {
    print('🔍 CHIAMATA A _loadRecipesWithFilters - inizio');

    if (_isLoadingFilters || !mounted) return;
    print('🔍 CHIAMATA A _loadRecipesWithFilters - procedo');

    _isLoadingFilters = true;

    try {
      final recipeService = context.read<RecipeService>();
      final likeService = context.read<LikeService>();
      final categoryService = context.read<CategoryService>();

      await Future.wait([
        categoryService.fetchCategories(forceRefresh: true),
        recipeService.fetchRecipes(
          forceRefresh: true,
          page: 1,
          category: _selectedCategory,
          search: _searchQuery,
        ),
      ]);

      if (!mounted) return;

      final recipeIds = recipeService.cachedRecipes.map((r) => r.id).toList();
      likeService.preloadLikesCount(recipeIds);
    } catch (e) {
      AppLogger.error('Errore nel caricamento filtri', e);
    } finally {
      _isLoadingFilters = false;
    }
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
    Navigator.pushNamed(context, '/create-recipe');
  }

  void _navigateToProfile() {
    final authService = context.read<AuthService>();
    if (!authService.isLoggedIn) {
      _showLoginRequiredDialog(
        title: 'Accesso richiesto',
        content: 'Devi effettuare il login per accedere al profilo.',
      );
      return;
    }
    Navigator.pushNamed(context, '/profile');
  }

  void _showLoginRequiredDialog(
      {required String title, required String content}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ANNULLA')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/login');
            },
            child: const Text('LOGIN'),
          ),
        ],
      ),
    );
  }

  void _onRecipeTap(Recipe recipe) {
    if (recipe.id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Errore: ID ricetta non valido')),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => DetailRecipeScreen(recipeId: recipe.id)),
    );
  }

  void _onSearchChanged(String query) {
    setState(() => _searchQuery = query.isEmpty ? null : query);
    _loadRecipesWithFilters();
  }

  Widget _buildAvatarButton(AuthService authService) {
    if (!authService.isLoggedIn) {
      return const _AvatarIconButton(
          icon: Icons.account_circle, tooltip: 'Accedi al profilo');
    }

    final tooltip = authService.username != null
        ? 'Profilo di ${authService.username}'
        : 'Profilo';

    if (authService.avatarUrl?.isNotEmpty ?? false) {
      return _AvatarImageButton(
          avatarUrl: authService.avatarUrl!, tooltip: tooltip);
    }
    return const _AvatarIconButton(
        icon: Icons.account_circle, tooltip: 'Profilo');
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<RecipeService, AuthService>(
      builder: (context, recipeService, authService, _) {
        final recipes = recipeService.cachedRecipes;

        return Scaffold(
          appBar: AppBar(
            title: const Text('OrsoCook',
                style: TextStyle(fontWeight: FontWeight.bold)),
            actions: [
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: _navigateToCreateRecipe,
                tooltip: 'Crea ricetta',
              ),
              GestureDetector(
                  onTap: _navigateToProfile,
                  child: _buildAvatarButton(authService)),
            ],
          ),
          body: Column(
            children: [
              const WelcomeHeader(),
              RecipeSearchBar(onSearchChanged: _onSearchChanged),
              CategoriesBar(
                onCategorySelected: _onCategorySelected,
                selectedCategorySlug: _selectedCategory,
              ),
              const SizedBox(height: 8),
              Expanded(
                child: AnimatedSwitcher(
                  duration: _animationDuration,
                  transitionBuilder: (child, animation) =>
                      FadeTransition(opacity: animation, child: child),
                  child: recipes.isNotEmpty
                      ? RecipeList(
                          key: ValueKey('$_selectedCategory$_searchQuery'),
                          onRecipeTap: _onRecipeTap,
                        )
                      : EmptyState(
                          key: ValueKey('empty$_selectedCategory$_searchQuery'),
                          searchQuery: _searchQuery,
                          onRetry: _loadRecipesWithFilters,
                          onCreateRecipe: _navigateToCreateRecipe,
                        ),
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: _navigateToCreateRecipe,
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            child: const Icon(Icons.add, size: 28),
          ),
        );
      },
    );
  }
}

// ==================== WIDGETS HELPER ====================
class _AvatarIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;

  const _AvatarIconButton({
    required this.icon,
    required this.tooltip,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon),
      onPressed: onTap,
      tooltip: tooltip,
    );
  }
}

class _AvatarImageButton extends StatelessWidget {
  final String avatarUrl;
  final String tooltip;
  final VoidCallback? onTap;

  const _AvatarImageButton({
    required this.avatarUrl,
    required this.tooltip,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundImage: NetworkImage(avatarUrl),
            radius: 18,
            backgroundColor: Colors.grey[200],
          ),
        ),
      ),
    );
  }
}
