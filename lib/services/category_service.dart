import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:orsocook/utils/logger.dart';
import 'package:orsocook/config.dart';
import 'package:orsocook/services/auth_service.dart';

class CategoryService extends ChangeNotifier {
  final Dio _dio = Dio();
  final AuthService _authService;

  List<CategoryModel> _categories = [];
  bool _isLoading = false;
  String? _lastError;

  CategoryService(this._authService) {
    _dio.options.baseUrl = Config.buildUrl('');
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);
  }

  // Getters
  List<CategoryModel> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get lastError => _lastError;

  // Headers
  Future<Map<String, String>> _getAuthHeaders() =>
      _authService.getAuthHeaders();

  // Fetch categories
  Future<List<CategoryModel>> fetchCategories(
      {bool forceRefresh = false}) async {
    if (!forceRefresh && _categories.isNotEmpty) return _categories;

    _setLoading(true);

    try {
      final response = await _dio.get(
        '/api/categories',
        options: Options(headers: await _getAuthHeaders()),
      );

      if (response.data['success'] != true) {
        throw Exception(
            response.data['message'] ?? 'Errore nel caricamento categorie');
      }

      final List<dynamic> categoriesData = response.data['data'];
      _categories = categoriesData
          .map(
              (json) => CategoryModel.fromJson(Map<String, dynamic>.from(json)))
          .toList();

      AppLogger.debug('✅ Categorie caricate: ${_categories.length}');
      _lastError = null;
    } catch (e) {
      AppLogger.error('❌ Errore caricamento categorie', e);
      _lastError = e.toString();
      _categories = [];
    } finally {
      _setLoading(false);
    }

    return _categories;
  }

  // NUOVO METODO: refreshCategories
  Future<void> refreshCategories() async {
    await fetchCategories(forceRefresh: true);
  }

  // Get category by slug
  CategoryModel? getCategoryBySlug(String slug) {
    try {
      return _categories.firstWhere((c) => c.slug == slug);
    } catch (_) {
      return null;
    }
  }

  // Get category by id
  CategoryModel? getCategoryById(String id) {
    try {
      return _categories.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    scheduleMicrotask(() {
      if (hasListeners) {
        notifyListeners();
      }
    });
  }

  void clearCache() {
    _categories.clear();
    _lastError = null;
    scheduleMicrotask(() {
      if (hasListeners) {
        notifyListeners();
      }
    });
  }
}

// Modello Category
class CategoryModel {
  final String id;
  final String name;
  final String slug;
  final String? description;
  final String? icon;
  final int recipeCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  CategoryModel({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.icon,
    required this.recipeCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String,
      description: json['description'] as String?,
      icon: json['icon'] as String?,
      recipeCount: json['recipeCount'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'slug': slug,
        'description': description,
        'icon': icon,
        'recipeCount': recipeCount,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  @override
  String toString() =>
      'CategoryModel(name: $name, slug: $slug, recipes: $recipeCount)';
}
