import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:orsocook/models/recipe.dart';
import 'package:orsocook/services/recipe_service.dart';
import 'package:orsocook/services/cloudinary_upload_service.dart';
import 'package:orsocook/services/auth_service.dart';
import 'package:orsocook/services/category_service.dart';
import 'package:orsocook/utils/logger.dart';

class CreateRecipeViewModel extends ChangeNotifier {
  final AuthService _authService;
  final RecipeService _recipeService;
  final CategoryService _categoryService;
  final ImagePicker _picker = ImagePicker();

  // Controllers
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final prepTimeController = TextEditingController();
  final cookTimeController = TextEditingController();
  final servingsController = TextEditingController();
  final ingredientNameController = TextEditingController();
  final ingredientQuantityController = TextEditingController();
  final ingredientUnitController = TextEditingController();
  final instructionController = TextEditingController();
  final tagController = TextEditingController();

  // State
  String selectedDifficulty = 'MEDIUM';
  String selectedCategory = '';
  bool isPublic = true;
  final List<Map<String, dynamic>> ingredients = [];
  final List<Map<String, dynamic>> instructions = [];
  final List<String> tags = [];

  // Image handling
  Uint8List? imageBytes;
  XFile? selectedImageXFile;
  bool isUploading = false;
  bool isLoading = false;

  CreateRecipeViewModel({
    required AuthService authService,
    required RecipeService recipeService,
    required CategoryService categoryService,
  })  : _authService = authService,
        _recipeService = recipeService,
        _categoryService = categoryService;

  // Getter per categorie - USA CategoryModel
  List<CategoryModel> get availableCategories => _categoryService.categories;

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    prepTimeController.dispose();
    cookTimeController.dispose();
    servingsController.dispose();
    ingredientNameController.dispose();
    ingredientQuantityController.dispose();
    ingredientUnitController.dispose();
    instructionController.dispose();
    tagController.dispose();
    super.dispose();
  }

  // ==================== METODI IMMAGINE ====================
  Future<void> pickImage() async {
    try {
      final image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1200,
      );

      if (image != null) {
        final bytes = await image.readAsBytes();
        selectedImageXFile = image;
        imageBytes = bytes;
        notifyListeners();
      }
    } catch (e) {
      AppLogger.error('Errore selezione immagine', e);
    }
  }

  void setImageData(XFile image, Uint8List bytes) {
    selectedImageXFile = image;
    imageBytes = bytes;
    notifyListeners();
  }

  void removeImage() {
    selectedImageXFile = null;
    imageBytes = null;
    notifyListeners();
  }

  // ==================== METODI INGREDIENTI ====================
  void addIngredient() {
    if (ingredientNameController.text.trim().isEmpty) return;

    ingredients.add({
      'name': ingredientNameController.text.trim(),
      'quantity': ingredientQuantityController.text.trim().isEmpty
          ? null
          : ingredientQuantityController.text.trim(),
      'unit': ingredientUnitController.text.trim().isEmpty
          ? null
          : ingredientUnitController.text.trim(),
    });

    ingredientNameController.clear();
    ingredientQuantityController.clear();
    ingredientUnitController.clear();
    notifyListeners();
  }

  void removeIngredient(int index) {
    ingredients.removeAt(index);
    notifyListeners();
  }

  // ==================== METODI ISTRUZIONI ====================
  void addInstruction() {
    if (instructionController.text.trim().isEmpty) return;

    instructions.add({
      'step': instructions.length + 1,
      'description': instructionController.text.trim(),
    });
    instructionController.clear();
    notifyListeners();
  }

  void removeInstruction(int index) {
    instructions.removeAt(index);
    // Rinumera gli step
    for (var i = 0; i < instructions.length; i++) {
      instructions[i]['step'] = i + 1;
    }
    notifyListeners();
  }

  // ==================== METODI TAG ====================
  void addTag() {
    if (tagController.text.trim().isEmpty) return;

    final newTag = tagController.text.trim().toLowerCase();
    if (!tags.contains(newTag)) {
      tags.add(newTag);
    }
    tagController.clear();
    notifyListeners();
  }

  void removeTag(String tag) {
    tags.remove(tag);
    notifyListeners();
  }

  // ==================== METODI CAMPI BASE ====================
  void updateDifficulty(String value) {
    selectedDifficulty = value;
    notifyListeners();
  }

  void updateCategory(String value) {
    selectedCategory = value;
    notifyListeners();
  }

  void updateIsPublic(bool value) {
    isPublic = value;
    notifyListeners();
  }

  // ==================== METODI PRIVATI ====================
  Difficulty _getDifficultyFromString(String value) {
    switch (value) {
      case 'EASY':
        return Difficulty.easy;
      case 'HARD':
        return Difficulty.hard;
      default:
        return Difficulty.medium;
    }
  }

  Future<String?> _uploadImageIfNeeded() async {
    if (selectedImageXFile == null || imageBytes == null) return null;

    isUploading = true;
    notifyListeners();

    try {
      final uploadService = CloudinaryUploadService(_authService);
      final imageUrl = await uploadService.uploadImage(
        imageBytes: imageBytes!,
        fileName: selectedImageXFile!.name,
        folder: 'orsocook/recipes',
      );
      return imageUrl;
    } finally {
      isUploading = false;
      notifyListeners();
    }
  }

  Recipe _buildRecipe(String? imageUrl) {
    final currentUserId = _authService.userId ?? '';
    final currentUsername = _authService.username ?? '';

    CategoryModel? selectedCategoryObj;
    if (selectedCategory.isNotEmpty) {
      try {
        selectedCategoryObj =
            _categoryService.getCategoryBySlug(selectedCategory);
      } catch (e) {
        AppLogger.error('Errore nel trovare categoria', e);
      }
    }
    // RIMOSSI I PRINT
    return Recipe(
      id: '',
      title: titleController.text.trim(),
      description: descriptionController.text.trim(),
      slug: '',
      imageUrl: imageUrl,
      prepTime: int.tryParse(prepTimeController.text) ?? 0,
      cookTime: int.tryParse(cookTimeController.text) ?? 0,
      servings: int.tryParse(servingsController.text) ?? 1,
      difficulty: _getDifficultyFromString(selectedDifficulty),
      isPublic: isPublic,
      views: 0,
      favoriteCount: 0,
      likeCount: 0,
      commentCount: 0,
      isFavorite: false,
      isLiked: false,
      author: UserAuthor(
        id: currentUserId,
        username: currentUsername,
        displayName: currentUsername,
        avatarUrl: _authService.avatarUrl,
      ),
      category: selectedCategoryObj != null
          ? Category(
              id: selectedCategoryObj.id,
              name: selectedCategoryObj.name,
              slug: selectedCategoryObj.slug,
            )
          : null,
      ingredients: ingredients
          .map((i) => Ingredient(
                name: i['name'] ?? '',
                quantity: i['quantity']?.toString(),
                unit: i['unit']?.toString(),
              ))
          .toList(),
      instructions: instructions
          .map((i) => Instruction(
                step: i['step'] ?? 0,
                description: i['description'] ?? '',
              ))
          .toList(),
      tags: tags
          .map((tagName) => Tag(
                id: '',
                name: tagName,
                slug: '',
              ))
          .toList(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  // ==================== METODO PRINCIPALE ====================
  Future<Recipe?> saveRecipe() async {
    isLoading = true;
    notifyListeners();

    try {
      final imageUrl = await _uploadImageIfNeeded();
      final recipe = _buildRecipe(imageUrl);
      final createdRecipe = await _recipeService.createRecipe(recipe);
      return createdRecipe;
    } catch (e) {
      AppLogger.error('❌ Errore salvataggio ricetta', e);
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  bool validate(GlobalKey<FormState> formKey) {
    return formKey.currentState?.validate() ?? false;
  }
}
