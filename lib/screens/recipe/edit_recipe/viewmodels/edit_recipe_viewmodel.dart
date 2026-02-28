import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:orsocook/models/recipe.dart';
import 'package:orsocook/services/recipe_service.dart';
import 'package:orsocook/services/cloudinary_upload_service.dart';
import 'package:orsocook/services/auth_service.dart';
import 'package:orsocook/services/category_service.dart';
import 'package:orsocook/utils/logger.dart';

class EditRecipeViewModel extends ChangeNotifier {
  final AuthService _authService;
  final RecipeService _recipeService;
  final CategoryService _categoryService;
  final ImagePicker _picker = ImagePicker();
  final Recipe originalRecipe;

  // Controllers
  late final TextEditingController titleController;
  late final TextEditingController descriptionController;
  late final TextEditingController prepTimeController;
  late final TextEditingController cookTimeController;
  late final TextEditingController servingsController;
  final ingredientNameController = TextEditingController();
  final ingredientQuantityController = TextEditingController();
  final ingredientUnitController = TextEditingController();
  final instructionController = TextEditingController();
  final tagController = TextEditingController();

  // State
  late String selectedDifficulty;
  late String selectedCategory;
  late bool isPublic;
  late List<Map<String, dynamic>> ingredients;
  late List<Map<String, dynamic>> instructions;
  late List<String> tags;

  // Image handling
  Uint8List? imageBytes;
  XFile? selectedImageXFile;
  String? currentImageUrl;
  bool isUploading = false;
  bool isLoading = false;
  bool removeImage = false;

  EditRecipeViewModel({
    required AuthService authService,
    required RecipeService recipeService,
    required CategoryService categoryService,
    required this.originalRecipe,
  })  : _authService = authService,
        _recipeService = recipeService,
        _categoryService = categoryService {
    _initializeControllers();
  }

  // Getter per categorie - ORA USA CategoryModel
  List<CategoryModel> get availableCategories => _categoryService.categories;

  void _initializeControllers() {
    titleController = TextEditingController(text: originalRecipe.title);
    descriptionController =
        TextEditingController(text: originalRecipe.description);
    prepTimeController =
        TextEditingController(text: originalRecipe.prepTime.toString());
    cookTimeController =
        TextEditingController(text: originalRecipe.cookTime.toString());
    servingsController =
        TextEditingController(text: originalRecipe.servings.toString());

    selectedDifficulty = originalRecipe.difficulty.value;
    selectedCategory = originalRecipe.category?.slug ?? '';
    isPublic = originalRecipe.isPublic;
    ingredients = originalRecipe.ingredients.map((i) => i.toJson()).toList();
    instructions = originalRecipe.instructions.map((i) => i.toJson()).toList();
    tags = originalRecipe.tags.map((t) => t.name).toList();
    currentImageUrl = originalRecipe.imageUrl;
  }

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
        removeImage = false;
        notifyListeners();
      }
    } catch (e) {
      AppLogger.error('Errore selezione immagine', e);
    }
  }

  void setImageData(XFile image, Uint8List bytes) {
    selectedImageXFile = image;
    imageBytes = bytes;
    removeImage = false;
    notifyListeners();
  }

  void removeCurrentImage() {
    selectedImageXFile = null;
    imageBytes = null;
    currentImageUrl = null;
    removeImage = true;
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
  Future<String?> _uploadImageIfNeeded() async {
    if (selectedImageXFile == null || imageBytes == null) {
      return currentImageUrl;
    }

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

  Recipe _buildUpdatedRecipe(String? imageUrl) {
    final currentUserId = _authService.userId ?? '';
    final currentUsername = _authService.username ?? '';

    // Se richiesta rimozione immagine
    final finalImageUrl = removeImage ? null : (imageUrl ?? currentImageUrl);

    CategoryModel? selectedCategoryObj; // ORA CategoryModel
    if (selectedCategory.isNotEmpty) {
      try {
        selectedCategoryObj =
            _categoryService.getCategoryBySlug(selectedCategory);
      } catch (e) {
        AppLogger.error('Errore nel trovare categoria', e);
      }
    }
    print('🔍 MODIFICA - selectedCategory: $selectedCategory');
    print('🔍 MODIFICA - selectedCategoryObj: $selectedCategoryObj');
    return Recipe(
      id: originalRecipe.id,
      title: titleController.text.trim(),
      description: descriptionController.text.trim(),
      slug: originalRecipe.slug,
      imageUrl: finalImageUrl,
      prepTime: int.tryParse(prepTimeController.text) ?? 0,
      cookTime: int.tryParse(cookTimeController.text) ?? 0,
      servings: int.tryParse(servingsController.text) ?? 1,
      difficulty: Difficulty.fromString(selectedDifficulty),
      isPublic: isPublic,
      views: originalRecipe.views,
      favoriteCount: originalRecipe.favoriteCount,
      likeCount: originalRecipe.likeCount,
      commentCount: originalRecipe.commentCount,
      isFavorite: originalRecipe.isFavorite,
      isLiked: originalRecipe.isLiked,
      author: UserAuthor(
        id: currentUserId,
        username: currentUsername,
        displayName: currentUsername,
        avatarUrl: _authService.avatarUrl,
      ),
      category: selectedCategoryObj != null
          ? Category(
              // QUESTA È Category di recipe.dart
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
      createdAt: originalRecipe.createdAt,
      updatedAt: DateTime.now(),
    );
  }

  // ==================== METODO PRINCIPALE ====================
  Future<Recipe?> saveRecipe() async {
    isLoading = true;
    notifyListeners();

    try {
      final imageUrl = await _uploadImageIfNeeded();
      final updatedRecipe = _buildUpdatedRecipe(imageUrl);

      // 👈 LOG PER VEDERE COSA VIENE INVIATO
      print('🔍 INVIO AL BACKEND - recipe.toJson(): ${updatedRecipe.toJson()}');

      final result =
          await _recipeService.updateRecipe(originalRecipe.id, updatedRecipe);
      return result;
    } catch (e) {
      AppLogger.error('❌ Errore aggiornamento ricetta', e);
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
