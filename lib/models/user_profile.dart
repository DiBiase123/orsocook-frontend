class UserProfile {
  final String id;
  final String username;
  final String email;
  final String? avatarUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserProfile({
    required this.id,
    required this.username,
    required this.email,
    this.avatarUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      avatarUrl: json['avatarUrl'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  UserProfile copyWith({String? avatarUrl}) {
    return UserProfile(
      id: id,
      username: username,
      email: email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

class UserStats {
  final int recipesCount;
  final int favoritesCount;
  final int totalViews;
  final int averageViewsPerRecipe;

  UserStats({
    required this.recipesCount,
    required this.favoritesCount,
    required this.totalViews,
    required this.averageViewsPerRecipe,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      recipesCount: json['recipesCount'] ?? 0,
      favoritesCount: json['favoritesCount'] ?? 0,
      totalViews: json['totalViews'] ?? 0,
      averageViewsPerRecipe: json['averageViewsPerRecipe'] ?? 0,
    );
  }
}
