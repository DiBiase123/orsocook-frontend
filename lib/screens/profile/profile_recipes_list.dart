import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:orsocook/models/recipe.dart';
import 'package:orsocook/services/profile_service.dart';
import 'package:orsocook/services/favorite_service.dart';
import 'package:orsocook/services/profile_controller.dart'; // 👈 IMPORT AGGIUNTO
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
    AppLogger.debug(
        '📋 [INIT] ProfileRecipesList - isUserRecipes: ${widget.isUserRecipes}');
    _loadedRecipes = List.from(widget.recipes);
    _favoriteService = Provider.of<FavoriteService>(context, listen: false);
    _favoriteService.addListener(_onFavoriteChanged);
    _preloadFavoriteStatus();
  }

  Future<void> _preloadFavoriteStatus() async {
    AppLogger.debug(
        '📦 [PRELOAD] Inizio precaricamento ${_loadedRecipes.length} ricette');
    for (final recipe in _loadedRecipes) {
      await _favoriteService.isFavorite(recipe.id);
    }
    AppLogger.debug('✅ [PRELOAD] Completato');
  }

  @override
  void didUpdateWidget(ProfileRecipesList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.recipes != widget.recipes) {
      AppLogger.debug(
          '🔄 [UPDATE] Widget aggiornato - nuove ricette: ${widget.recipes.length}');
      setState(() {
        _loadedRecipes = List.from(widget.recipes);
      });
      _preloadFavoriteStatus();
    }
  }

  @override
  void dispose() {
    AppLogger.debug(
        '🗑️ [DISPOSE] ProfileRecipesList - isUserRecipes: ${widget.isUserRecipes}');
    _favoriteService.removeListener(_onFavoriteChanged);
    super.dispose();
  }

  void _onFavoriteChanged() {
    if (!mounted) return;

    // Se non siamo nella tab corrente, ignora
    final profileController =
        Provider.of<ProfileController>(context, listen: false);
    final currentTab = profileController.selectedTabIndex;
    final expectedTab = widget.isUserRecipes ? 0 : 1;

    if (currentTab != expectedTab) {
      AppLogger.debug(
          '⏭️ [LISTENER] Ignoro notifica - tab corrente: $currentTab, attesa: $expectedTab');
      return;
    }

    AppLogger.debug(
        '🔔 [LISTENER] _onFavoriteChanged - isUserRecipes: ${widget.isUserRecipes}');

    if (widget.isUserRecipes) {
      AppLogger.debug(
          '🔄 [LISTENER] Caso "Le Mie Ricette" - aggiorno solo colori');
      _refreshFavoriteStatus();
    } else {
      AppLogger.debug(
          '🔄 [LISTENER] Caso "Preferiti" - ricarico lista completa');
      _refreshList();
    }
  }

  Future<void> _refreshFavoriteStatus() async {
    AppLogger.debug('🎨 [REFRESH] Aggiornamento stati preferiti');
    try {
      final updatedRecipes = <Recipe>[];
      for (final recipe in _loadedRecipes) {
        final isFavorite = await _favoriteService.isFavorite(recipe.id);
        if (recipe.isFavorite != isFavorite) {
          AppLogger.debug(
              '   📌 ${recipe.title}: ${recipe.isFavorite} -> $isFavorite');
          updatedRecipes.add(recipe.copyWith(isFavorite: isFavorite));
        } else {
          updatedRecipes.add(recipe);
        }
      }

      if (mounted) {
        setState(() {
          _loadedRecipes = updatedRecipes;
        });
        AppLogger.debug('✅ [REFRESH] Completato');
      }
    } catch (e) {
      AppLogger.error('❌ [REFRESH] Errore: $e');
    }
  }

  Future<void> _refreshList() async {
    AppLogger.debug('🔄 [REFRESH] Ricarico lista preferiti');
    try {
      final profileService =
          Provider.of<ProfileService>(context, listen: false);

      _currentPage = 1;

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

      AppLogger.debug('📥 [REFRESH] Caricate ${freshRecipes.length} ricette');

      if (mounted) {
        setState(() {
          _loadedRecipes = freshRecipes;
        });

        for (final recipe in freshRecipes) {
          _favoriteService.isFavorite(recipe.id);
        }
        AppLogger.debug('✅ [REFRESH] Lista aggiornata');
      }
    } catch (e) {
      AppLogger.error('❌ [REFRESH] Errore: $e');
    }
  }

  Future<void> _loadMoreRecipes() async {
    if (_isLoadingMore) return;

    try {
      setState(() => _isLoadingMore = true);
      AppLogger.debug('📦 [LOAD MORE] Caricamento pagina $_currentPage + 1');

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

        for (final recipe in newRecipes) {
          _favoriteService.isFavorite(recipe.id);
        }
        AppLogger.debug('✅ [LOAD MORE] Caricate ${newRecipes.length} ricette');
      }
    } catch (e) {
      AppLogger.error('❌ [LOAD MORE] Errore: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoadingMore = false);
      }
    }
  }

  void _handleRecipeTap(Recipe recipe) {
    AppLogger.debug('👆 [TAP] Apertura ricetta ${recipe.id}');
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
