import 'package:flutter/foundation.dart';
import 'package:orsocook/services/recipe_service.dart';
import 'package:orsocook/services/like_service.dart';
import 'package:orsocook/services/comment_service.dart';

class ServiceCoordinator {
  // Singleton pattern
  static final ServiceCoordinator _instance = ServiceCoordinator._internal();
  factory ServiceCoordinator() => _instance;
  ServiceCoordinator._internal();

  RecipeService? _recipeService;
  LikeService? _likeService;

  // Registra RecipeService
  void registerRecipeService(RecipeService service) {
    _recipeService = service;
    _setupCommunication();
    debugPrint('✅ ServiceCoordinator: RecipeService registrato');
  }

  // Registra LikeService
  void registerLikeService(LikeService service) {
    _likeService = service;
    _setupCommunication();
    debugPrint('✅ ServiceCoordinator: LikeService registrato');
  }

  // Registra CommentService
  void registerCommentService(CommentService service) {
    _setupCommentCommunication(service);
    debugPrint('✅ ServiceCoordinator: CommentService registrato');
  }

  // Configura la comunicazione tra servizi
  void _setupCommunication() {
    if (_recipeService != null && _likeService != null) {
      _likeService!.addLikeUpdateListener((recipeId, isLiked) {
        debugPrint(
            '🔗 ServiceCoordinator: Ricevuto like update per $recipeId -> $isLiked');
        _recipeService!.updateRecipeLikedStatus(recipeId, isLiked);
      });
      debugPrint('✅ ServiceCoordinator: RecipeService ↔ LikeService collegati');
    }
  }

  // Configura comunicazione per commenti
  void _setupCommentCommunication(CommentService commentService) {
    commentService.addCommentUpdateListener((recipeId, commentCount) {
      debugPrint(
          '🔗 ServiceCoordinator: Ricevuto comment update per $recipeId -> $commentCount commenti');
      _recipeService?.updateRecipeCommentCount(recipeId, commentCount);
    });
    debugPrint(
        '✅ ServiceCoordinator: RecipeService ↔ CommentService collegati');
  }

  // Metodo pubblico per notificare aggiornamenti like
  void notifyLikeUpdate(String recipeId, bool isLiked) {
    debugPrint('🔗 ServiceCoordinator: Notifica like update per $recipeId');
    _recipeService?.updateRecipeLikedStatus(recipeId, isLiked);
  }
}
