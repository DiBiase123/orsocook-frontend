import 'package:orsocook/models/recipe.dart';
import 'package:orsocook/models/user_profile.dart';
import 'package:orsocook/utils/logger.dart';

class ProfileResponse {
  final UserProfile user;
  final UserStats stats;
  final List<Recipe> recentRecipes;
  final List<Recipe> recentFavorites;

  ProfileResponse({
    required this.user,
    required this.stats,
    required this.recentRecipes,
    required this.recentFavorites,
  });

  factory ProfileResponse.fromJson(Map<String, dynamic> json) {
    AppLogger.debug('📦 Parsing ProfileResponse');

    final user = UserProfile.fromJson(json['user']);
    final stats = UserStats.fromJson(json['stats']);

    final recentRecipes = (json['recentRecipes'] as List)
        .map((r) {
          try {
            return Recipe.fromJson(r);
          } catch (e) {
            AppLogger.error('Errore parsing ricetta recente', e);
            return null;
          }
        })
        .whereType<Recipe>()
        .toList();

    final recentFavorites = (json['recentFavorites'] as List)
        .map((r) {
          try {
            return Recipe.fromJson(r);
          } catch (e) {
            AppLogger.error('Errore parsing preferito', e);
            return null;
          }
        })
        .whereType<Recipe>()
        .toList();

    return ProfileResponse(
      user: user,
      stats: stats,
      recentRecipes: recentRecipes,
      recentFavorites: recentFavorites,
    );
  }

  ProfileResponse copyWith({UserProfile? user}) {
    return ProfileResponse(
      user: user ?? this.user,
      stats: stats,
      recentRecipes: recentRecipes,
      recentFavorites: recentFavorites,
    );
  }
}
