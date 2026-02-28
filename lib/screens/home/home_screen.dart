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
        setState(() {
          _selectedCategory = savedCategory;
        });
        // Carica ricette con categoria salvata dopo che il widget è montato
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _loadRecipesWithFilters();
        });
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

      if (categoryService.categories.isEmpty) {
        categoryService.fetchCategories();
      }

      // Se non c'è categoria salvata, carica tutte
      if (_selectedCategory == null) {
        await recipeService.fetchRecipes(forceRefresh: true, page: 1);
      }

      if (!mounted) return;

      final recipeIds = recipeService.cachedRecipes.map((r) => r.id).toList();
      likeService.preloadLikesCount(recipeIds);
    } catch (e) {
      if (!mounted) return;
      AppLogger.error('Errore caricamento ricette iniziali', e);
    }
  }

  void _onCategorySelected(String? categorySlug) async {
    setState(() {
      _selectedCategory = categorySlug;
    });

    // Salva la preferenza
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
    if (!mounted) return;

    final recipeService = context.read<RecipeService>();
    final likeService = context.read<LikeService>();

    await recipeService.fetchRecipes(
      forceRefresh: true,
      page: 1,
      category: _selectedCategory,
    );

    if (!mounted) return;

    final recipeIds = recipeService.cachedRecipes.map((r) => r.id).toList();
    likeService.preloadLikesCount(recipeIds);
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
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('ANNULLA'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
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
        builder: (context) => DetailRecipeScreen(recipeId: recipe.id),
      ),
    );
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query.isEmpty ? null : query;
    });
  }

  List<Recipe> _getFilteredRecipes(List<Recipe> recipes) {
    if (_searchQuery == null || _searchQuery!.isEmpty) {
      return recipes;
    }

    final query = _searchQuery!.toLowerCase();
    final filtered = recipes.where((recipe) {
      if (recipe.title.toLowerCase().contains(query)) return true;
      if (recipe.description.toLowerCase().contains(query)) return true;
      for (var ingredient in recipe.ingredients) {
        if (ingredient.name.toLowerCase().contains(query)) return true;
      }
      return false;
    }).toList();

    if (filtered.isEmpty) {
      AppLogger.debug(
          '🔍 Nessuna ricetta trovata per: "$query" in categoria: ${_selectedCategory ?? "tutte"}');
    }

    return filtered;
  }

  Widget _buildAvatarButton(AuthService authService) {
    if (!authService.isLoggedIn) {
      return const _AvatarIconButton(
        icon: Icons.account_circle,
        tooltip: 'Accedi al profilo',
        onTap: null,
      );
    }

    final tooltipMessage = authService.username != null
        ? 'Profilo di ${authService.username!}'
        : 'Profilo';

    if (authService.avatarUrl != null && authService.avatarUrl!.isNotEmpty) {
      return _AvatarImageButton(
        avatarUrl: authService.avatarUrl!,
        tooltip: tooltipMessage,
        onTap: null,
      );
    }

    return const _AvatarIconButton(
      icon: Icons.account_circle,
      tooltip: 'Profilo',
      onTap: null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<RecipeService, AuthService>(
      builder: (context, recipeService, authService, child) {
        final recipes = recipeService.cachedRecipes;
        final filteredRecipes = _getFilteredRecipes(recipes);

        return Scaffold(
          appBar: _buildAppBar(authService),
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
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: child,
                    );
                  },
                  child: filteredRecipes.isNotEmpty
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
          floatingActionButton: _buildFloatingActionButton(context),
        );
      },
    );
  }

  AppBar _buildAppBar(AuthService authService) {
    return AppBar(
      title: const Text(
        'OrsoCook',
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.add_circle_outline),
          onPressed: _navigateToCreateRecipe,
          tooltip: 'Crea ricetta',
        ),
        GestureDetector(
          onTap: _navigateToProfile,
          child: _buildAvatarButton(authService),
        ),
      ],
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    final theme = Theme.of(context);

    return FloatingActionButton(
      onPressed: _navigateToCreateRecipe,
      backgroundColor: theme.colorScheme.primary,
      foregroundColor: theme.colorScheme.onPrimary,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primary,
              Color.lerp(theme.colorScheme.primary, Colors.white, 0.2)!,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }
}

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
