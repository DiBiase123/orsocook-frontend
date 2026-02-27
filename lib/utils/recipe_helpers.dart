import 'package:orsocook/models/recipe.dart';
import 'package:orsocook/services/auth_service.dart';

/// Utility per operazioni comuni sulle ricette
class RecipeHelpers {
  /// Garantisce che una ricetta abbia l'oggetto author completo
  /// USO: RecipeHelpers.ensureRecipeHasAuthor(recipe, authService)
  static Recipe ensureRecipeHasAuthor(
    Recipe recipe,
    AuthService authService,
  ) {
    // Se la ricetta ha già un autore con ID valido, non fare nulla
    if (recipe.author.id.isNotEmpty) {
      return recipe;
    }

    // Solo se abbiamo un userId valido
    final currentUserId = authService.userId;
    if (currentUserId == null || currentUserId.isEmpty) {
      return recipe;
    }

    // Ottieni username per visualizzazione
    final username = authService.username ?? 'Utente';

    // Crea nuovo autore UserAuthor
    final author = UserAuthor(
      id: currentUserId,
      username: username,
      displayName: username,
      avatarUrl: authService.avatarUrl,
    );

    return recipe.copyWith(author: author);
  }

  /// Verifica se l'utente corrente è il proprietario della ricetta
  /// USO: RecipeHelpers.isRecipeOwner(recipe, userId)
  static bool isRecipeOwner(Recipe? recipe, String? userId) {
    if (recipe == null || userId == null) {
      return false;
    }

    final authorId = recipe.author.id;
    if (authorId.isEmpty) return false;

    // Normalizza entrambi gli ID per confronto case-insensitive
    return _normalizeId(userId) == _normalizeId(authorId);
  }

  /// Normalizza un ID per confronto (trim + lowercase)
  static String _normalizeId(String id) {
    return id.trim().toLowerCase();
  }

  /// Ottieni il nome visualizzato dell'autore
  static String getAuthorDisplayName(Recipe recipe) {
    return recipe.author.displayName ?? recipe.author.username;
  }

  /// Ottieni l'URL dell'avatar dell'autore
  static String? getAuthorAvatarUrl(Recipe recipe) {
    return recipe.author.avatarUrl;
  }

  /// Crea una ricetta placeholder per loading states
  static Recipe createPlaceholderRecipe(String id) {
    return Recipe(
      id: id,
      title: 'Caricamento...',
      description: '',
      slug: '',
      imageUrl: null,
      prepTime: 0,
      cookTime: 0,
      servings: 0,
      difficulty: Difficulty.medium, // ← CORRETTO: medium invece di MEDIUM
      isPublic: true,
      views: 0,
      favoriteCount: 0,
      likeCount: 0,
      commentCount: 0,
      isFavorite: false,
      isLiked: false,
      author: UserAuthor(
        id: '',
        username: '',
        displayName: null,
        avatarUrl: null,
      ),
      category: null,
      ingredients: [],
      instructions: [],
      tags: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}
