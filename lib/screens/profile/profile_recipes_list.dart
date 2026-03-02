import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:orsocook/models/recipe.dart';
import 'package:orsocook/services/profile_service.dart';
import 'package:orsocook/services/favorite_service.dart';
import 'package:orsocook/widgets/recipe_card.dart';
import 'package:orsocook/utils/logger.dart';

class ProfileRecipesList extends StatefulWidget {
  final List<Recipe> recipes;
  final String userId;
  final String emptyMessage;
  final IconData emptyIcon;
  final bool isUserRecipes;

  const ProfileRecipesList({
    super.key,
    required this.recipes,
    required this.userId,
    required this.emptyMessage,
    required this.emptyIcon,
    this.isUserRecipes = false,
  });

  @override
  State<ProfileRecipesList> createState() => _ProfileRecipesListState();
}

class _ProfileRecipesListState extends State<ProfileRecipesList> {
  bool _isLoadingMore = false;
  int _currentPage = 1;
  late List<Recipe> _loadedRecipes;
  late FavoriteService _favoriteService;

  @override
  void initState() {
    super.initState();
    _loadedRecipes = List.from(widget.recipes);
    _favoriteService = Provider.of<FavoriteService>(context, listen: false);

    // Ascoltiamo i cambiamenti dei preferiti
    _favoriteService.addListener(_onFavoriteChanged);
  }

  @override
  void didUpdateWidget(ProfileRecipesList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.recipes != widget.recipes) {
      setState(() {
        _loadedRecipes = List.from(widget.recipes);
      });
    }
  }

  @override
  void dispose() {
    _favoriteService.removeListener(_onFavoriteChanged);
    super.dispose();
  }

  void _onFavoriteChanged() {
    AppLogger.debug(
        '🔔 _onFavoriteChanged chiamato - isUserRecipes: ${widget.isUserRecipes}');

    if (widget.isUserRecipes) {
      AppLogger.debug('🔄 Aggiorno solo stato cuoricini');
      _refreshFavoriteStatus();
    } else {
      AppLogger.debug('🔄 Ricarico lista preferiti');
      _refreshList();
    }
  }

  Future<void> _refreshFavoriteStatus() async {
    try {
      final updatedRecipes = <Recipe>[];
      for (final recipe in _loadedRecipes) {
        final isFavorite = await _favoriteService.isFavorite(recipe.id);
        updatedRecipes.add(recipe.copyWith(isFavorite: isFavorite));
      }

      if (mounted) {
        setState(() {
          _loadedRecipes = updatedRecipes;
        });
      }
    } catch (e) {
      AppLogger.error('Errore aggiornamento stato preferiti: $e');
    }
  }

  Future<void> _refreshList() async {
    try {
      final profileService =
          Provider.of<ProfileService>(context, listen: false);

      // Reset alla prima pagina
      _currentPage = 1;

      // Ricarica i dati dal servizio profilo
      final freshRecipes = widget.isUserRecipes
          ? await profileService.fetchUserRecipes(
              widget.userId,
              page: 1,
              limit: 10,
            )
          : await profileService.fetchUserFavorites(
              widget.userId,
              page: 1,
              limit: 10,
            );

      if (mounted) {
        setState(() {
          _loadedRecipes = freshRecipes;
        });
        AppLogger.success(
            'Lista preferiti aggiornata: ${freshRecipes.length} ricette');
      }
    } catch (e) {
      AppLogger.error('Errore aggiornamento lista: $e');
    }
  }

  Future<void> _loadMoreRecipes() async {
    if (_isLoadingMore) return;

    try {
      setState(() {
        _isLoadingMore = true;
      });

      final profileService =
          Provider.of<ProfileService>(context, listen: false);
      final nextPage = _currentPage + 1;

      final newRecipes = widget.isUserRecipes
          ? await profileService.fetchUserRecipes(
              widget.userId,
              page: nextPage,
              limit: 10,
            )
          : await profileService.fetchUserFavorites(
              widget.userId,
              page: nextPage,
              limit: 10,
            );

      if (newRecipes.isNotEmpty && mounted) {
        setState(() {
          _loadedRecipes.addAll(newRecipes);
          _currentPage = nextPage;
        });
        AppLogger.success('Caricate ${newRecipes.length} ricette aggiuntive');
      }
    } catch (e) {
      AppLogger.error('Errore caricamento ricette aggiuntive: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    }
  }

  void _handleRecipeTap(Recipe recipe) {
    context.push('/recipe/detail/${recipe.id}', extra: recipe);
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(widget.emptyIcon, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              widget.emptyMessage,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            if (widget.isUserRecipes)
              ElevatedButton(
                onPressed: () => context.go('/create-recipe'),
                child: const Text('Crea la tua prima ricetta'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipeItem(Recipe recipe) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: RecipeCard(
        recipe: recipe,
        onTap: () => _handleRecipeTap(recipe),
        showAuthor: !widget.isUserRecipes,
      ),
    );
  }

  Widget _buildLoadMoreIndicator() {
    if (_isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton(
        onPressed: _loadMoreRecipes,
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 48),
        ),
        child: const Text('Carica altre ricette'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loadedRecipes.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: _refreshList,
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
              itemCount: _loadedRecipes.length,
              itemBuilder: (context, index) {
                return _buildRecipeItem(_loadedRecipes[index]);
              },
            ),
          ),
        ),
        if (_loadedRecipes.length >= 10) _buildLoadMoreIndicator(),
      ],
    );
  }
}
