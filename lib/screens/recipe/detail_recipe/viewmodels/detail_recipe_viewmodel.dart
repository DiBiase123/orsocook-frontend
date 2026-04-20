import 'package:flutter/material.dart';
import 'package:orsocook/models/recipe.dart';
import 'package:orsocook/services/recipe_service.dart';
import 'package:orsocook/services/like_service.dart';
import 'package:orsocook/services/auth_service.dart';
import 'package:orsocook/utils/logger.dart';
import 'package:go_router/go_router.dart';

class DetailRecipeViewModel extends ChangeNotifier {
  final RecipeService _recipeService;
  final LikeService _likeService;
  final AuthService _authService;
  final String? recipeId;
  final Recipe? initialRecipe;

  Recipe? _recipe;
  bool _isLoading = true;
  String? _error;
  bool? _isFavorite;
  int _likeCount = 0;
  bool _isOwner = false;

  Recipe? get recipe => _recipe;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool? get isFavorite => _isFavorite;
  int get likeCount => _likeCount;
  bool get isOwner => _isOwner;

  DetailRecipeViewModel({
    required RecipeService recipeService,
    required LikeService likeService,
    required AuthService authService,
    this.recipeId,
    this.initialRecipe,
  })  : _recipeService = recipeService,
        _likeService = likeService,
        _authService = authService {
    _initialize();
  }

  Future<void> _initialize() async {
    AppLogger.debug('🎬 ViewModel inizializzato');

    if (initialRecipe != null) {
      _recipe = initialRecipe;
      _isLoading = false;
      notifyListeners();

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadExtraDetails();
      });
    } else if (recipeId != null && recipeId!.isNotEmpty) {
      await loadRecipeById(recipeId!);
    } else {
      _error = 'Ricetta non valida';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadRecipeById(String id) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final recipe = await _recipeService.getRecipeById(id);

      if (recipe == null) {
        _error = 'Ricetta non trovata';
      } else {
        _recipe = recipe;
      }
    } catch (e) {
      AppLogger.error('❌ Errore caricamento dettaglio ricetta', e);
      _error = 'Errore: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }

    if (_recipe != null) {
      await _loadExtraDetails();
    }
  }

  Future<void> _loadExtraDetails() async {
    if (_recipe == null) return;

    try {
      final likes = _likeService.getLikesCount(_recipe!.id);
      final favorite = _recipe!.isFavorite;

      final currentUserId = _authService.userId;
      final authorId = _recipe!.author.id;

      AppLogger.debug('🔍 currentUserId: $currentUserId');
      AppLogger.debug('🔍 authorId: $authorId');

      final isOwner = currentUserId != null &&
          currentUserId.trim().toLowerCase() == authorId.trim().toLowerCase();

      AppLogger.debug('🔍 isOwner: $isOwner');

      if (isOwner) {
        AppLogger.debug('👑 Utente è proprietario della ricetta');
      }

      _likeCount = likes;
      _isFavorite = favorite;
      _isOwner = isOwner;

      notifyListeners();
    } catch (e) {
      AppLogger.error('❌ Errore caricamento dettagli extra: $e');
      _isFavorite = _recipe?.isFavorite ?? false;
      notifyListeners();
    }
  }

  Future<void> refreshRecipe() async {
    if (_recipe?.id != null) {
      await loadRecipeById(_recipe!.id);
    } else if (recipeId != null) {
      await loadRecipeById(recipeId!);
    }
  }

  Future<void> deleteRecipe(BuildContext context) async {
    if (_recipe == null) return;

    AppLogger.api('🗑️ Eliminazione ricetta: ${_recipe!.title}');

    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final goRouter = GoRouter.of(context);
    final recipeTitle = _recipe!.title;

    try {
      final success = await _recipeService.deleteRecipe(_recipe!.id);

      if (success) {
        AppLogger.success('✅ Ricetta eliminata: $recipeTitle');

        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('"$recipeTitle" eliminata con successo'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );

        goRouter.pop();
      } else {
        _showErrorSnackbar(scaffoldMessenger, 'Errore durante l\'eliminazione');
      }
    } catch (e) {
      AppLogger.error('❌ Errore eliminazione', e);
      _showErrorSnackbar(scaffoldMessenger, e.toString());
    }
  }

  void _showErrorSnackbar(
      ScaffoldMessengerState scaffoldMessenger, String message) {
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void showDeleteConfirmationDialog(BuildContext context) {
    if (_recipe == null) return;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Conferma eliminazione'),
        content: Text(
          'Sei sicuro di voler eliminare la ricetta "${_recipe!.title}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('ANNULLA'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              deleteRecipe(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('ELIMINA'),
          ),
        ],
      ),
    );
  }

  void navigateToEditScreen(BuildContext context) {
    if (_recipe == null) return;
    AppLogger.debug('✏️ Navigazione a EditRecipeScreen per: ${_recipe!.title}');

    GoRouter.of(context)
        .push('/recipe/edit', extra: _recipe!)
        .then((_) => refreshRecipe());
  }
}
