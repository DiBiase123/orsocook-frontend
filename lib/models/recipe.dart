import '../utils/logger.dart';

class Recipe {
  final String id;
  final String title;
  final String description;
  final String slug;
  final String? imageUrl;
  final int prepTime;
  final int cookTime;
  final int servings;
  final Difficulty difficulty;
  final bool isPublic;
  final int views;
  final int favoriteCount;
  final int likeCount;
  final int commentCount;
  final bool isFavorite;
  final bool isLiked;
  final UserAuthor author;
  final Category? category;
  final List<Ingredient> ingredients;
  final List<Instruction> instructions;
  final List<Tag> tags;
  final DateTime createdAt;
  final DateTime updatedAt;

  Recipe({
    required this.id,
    required this.title,
    required this.description,
    required this.slug,
    this.imageUrl,
    required this.prepTime,
    required this.cookTime,
    required this.servings,
    required this.difficulty,
    required this.isPublic,
    required this.views,
    required this.favoriteCount,
    required this.likeCount,
    required this.commentCount,
    required this.isFavorite,
    required this.isLiked,
    required this.author,
    this.category,
    required this.ingredients,
    required this.instructions,
    required this.tags,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    try {
      return Recipe(
        id: _parseString(json['id']),
        title: _parseString(json['title'], 'Senza titolo'),
        description: _parseString(json['description']),
        slug: _parseString(json['slug']),
        imageUrl: _parseString(json['imageUrl'], null),
        prepTime: _parseInt(json['prepTime']),
        cookTime: _parseInt(json['cookTime']),
        servings: _parseInt(json['servings'], 1),
        difficulty:
            Difficulty.fromString(_parseString(json['difficulty'], 'MEDIUM')),
        isPublic: _parseBool(json['isPublic'], true),
        views: _parseInt(json['views']),
        favoriteCount: _parseInt(json['favoriteCount']),
        likeCount: _parseInt(json['likeCount']),
        commentCount: _parseInt(json['commentCount']),
        isFavorite: _parseBool(json['isFavorite']),
        isLiked: _parseBool(json['isLiked']),
        author: UserAuthor.fromJson(_parseMap(json['author'])),
        category: json['category'] != null
            ? Category.fromJson(_parseMap(json['category']))
            : null,
        ingredients: _parseList<Ingredient>(
          json['ingredients'],
          (item) => Ingredient.fromJson(item as Map<String, dynamic>),
        ),
        instructions: _parseList<Instruction>(
          json['instructions'],
          (item) => Instruction.fromJson(item as Map<String, dynamic>),
        ),
        tags: _parseList<Tag>(
          json['tags'],
          (item) {
            if (item is Map && item.containsKey('tag')) {
              return Tag.fromJson(item['tag'] as Map<String, dynamic>);
            }
            return Tag.fromJson(item as Map<String, dynamic>);
          },
        ),
        createdAt: _parseDateTime(json['createdAt']),
        updatedAt: _parseDateTime(json['updatedAt']),
      );
    } catch (e, stackTrace) {
      AppLogger.error('ERRORE CRITICO in Recipe.fromJson: $e');
      AppLogger.error('Stack trace: $stackTrace');
      AppLogger.error('JSON ricevuto: $json');
      rethrow;
    }
  }

  static String _parseString(dynamic value, [String? defaultValue = '']) {
    if (value == null) return defaultValue ?? '';
    return value.toString();
  }

  static int _parseInt(dynamic value, [int defaultValue = 0]) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? defaultValue;
    if (value is double) return value.toInt();
    return defaultValue;
  }

  static bool _parseBool(dynamic value, [bool defaultValue = false]) {
    if (value == null) return defaultValue;
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    if (value is int) return value != 0;
    return defaultValue;
  }

  static Map<String, dynamic> _parseMap(dynamic value) {
    if (value == null) return {};
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return {};
  }

  static List<T> _parseList<T>(dynamic value, T Function(dynamic) fromJson) {
    if (value == null) return [];
    if (value is List) {
      return value.map((item) => fromJson(item)).toList();
    }
    return [];
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    try {
      if (value is DateTime) return value;
      if (value is String) return DateTime.parse(value);
      if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
      return DateTime.now();
    } catch (e) {
      return DateTime.now();
    }
  }

  String get authorName => author.displayName ?? author.username;
  String get categoryName => category?.name ?? 'Senza categoria';
  int get totalTime => prepTime + cookTime;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'slug': slug,
      'imageUrl': imageUrl,
      'prepTime': prepTime,
      'cookTime': cookTime,
      'servings': servings,
      'difficulty': difficulty.value,
      'isPublic': isPublic,
      'views': views,
      'favoriteCount': favoriteCount,
      'likeCount': likeCount,
      'commentCount': commentCount,
      'isFavorite': isFavorite,
      'isLiked': isLiked,
      'author': author.toJson(),
      'category': category?.toJson(),
      'ingredients': ingredients.map((i) => i.toJson()).toList(),
      'instructions': instructions.map((i) => i.toJson()).toList(),
      'tags': tags.map((t) => t.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Recipe copyWith({
    String? id,
    String? title,
    String? description,
    String? slug,
    String? imageUrl,
    int? prepTime,
    int? cookTime,
    int? servings,
    Difficulty? difficulty,
    bool? isPublic,
    int? views,
    int? favoriteCount,
    int? likeCount,
    int? commentCount,
    bool? isFavorite,
    bool? isLiked,
    UserAuthor? author,
    Category? category,
    List<Ingredient>? ingredients,
    List<Instruction>? instructions,
    List<Tag>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Recipe(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      slug: slug ?? this.slug,
      imageUrl: imageUrl ?? this.imageUrl,
      prepTime: prepTime ?? this.prepTime,
      cookTime: cookTime ?? this.cookTime,
      servings: servings ?? this.servings,
      difficulty: difficulty ?? this.difficulty,
      isPublic: isPublic ?? this.isPublic,
      views: views ?? this.views,
      favoriteCount: favoriteCount ?? this.favoriteCount,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      isFavorite: isFavorite ?? this.isFavorite,
      isLiked: isLiked ?? this.isLiked,
      author: author ?? this.author,
      category: category ?? this.category,
      ingredients: ingredients ?? this.ingredients,
      instructions: instructions ?? this.instructions,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Recipe(id: $id, title: $title, difficulty: $difficulty)';
  }
}

enum Difficulty {
  easy('EASY'),
  medium('MEDIUM'),
  hard('HARD');

  final String value;
  const Difficulty(this.value);

  static Difficulty fromString(String value) {
    return values.firstWhere(
      (d) => d.value == value,
      orElse: () => medium, // Aggiornato anche qui
    );
  }
}

class UserAuthor {
  final String id;
  final String username;
  final String? displayName;
  final String? avatarUrl;

  UserAuthor({
    required this.id,
    required this.username,
    this.displayName,
    this.avatarUrl,
  });

  factory UserAuthor.fromJson(Map<String, dynamic> json) {
    return UserAuthor(
      id: json['id']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      displayName: json['displayName']?.toString(),
      avatarUrl: json['avatarUrl']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'displayName': displayName,
      'avatarUrl': avatarUrl,
    };
  }
}

class Category {
  final String id;
  final String name;
  final String slug;
  final String? description;
  final String? icon;

  Category({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.icon,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      description: json['description']?.toString(),
      icon: json['icon']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'description': description,
      'icon': icon,
    };
  }
}

class Tag {
  final String id;
  final String name;
  final String slug;

  Tag({
    required this.id,
    required this.name,
    required this.slug,
  });

  factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
    };
  }
}

class Ingredient {
  final String name;
  final String? quantity;
  final String? unit;

  Ingredient({
    required this.name,
    this.quantity,
    this.unit,
  });

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      name: json['name']?.toString() ?? '',
      quantity: json['quantity']?.toString(),
      unit: json['unit']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'quantity': quantity,
      'unit': unit,
    };
  }
}

class Instruction {
  final int step;
  final String description;
  final String? imageUrl;

  Instruction({
    required this.step,
    required this.description,
    this.imageUrl,
  });

  factory Instruction.fromJson(Map<String, dynamic> json) {
    return Instruction(
      step: json['step'] is int
          ? json['step']
          : int.tryParse(json['step']?.toString() ?? '0') ?? 0,
      description: json['description']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'step': step,
      'description': description,
      'imageUrl': imageUrl,
    };
  }
}
