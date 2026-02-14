import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:orsocook/models/recipe.dart';
import 'package:orsocook/services/recipe_service.dart';
import 'package:orsocook/services/cloudinary_upload_service.dart';
import 'package:orsocook/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:orsocook/utils/logger.dart';

// IMPORT CORRETTI
import 'edit_recipe/edit_header.dart';
import 'edit_recipe/edit_basic_info.dart';
import 'edit_recipe/edit_image_section.dart';
import 'edit_recipe/edit_ingredients.dart';
import 'edit_recipe/edit_instructions.dart';
import 'edit_recipe/edit_tags.dart';

class EditRecipeScreen extends StatefulWidget {
  final Recipe recipe;

  const EditRecipeScreen({
    super.key,
    required this.recipe,
  });

  @override
  State<EditRecipeScreen> createState() => _EditRecipeScreenState();
}

class _EditRecipeScreenState extends State<EditRecipeScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _prepTimeController;
  late final TextEditingController _cookTimeController;
  late final TextEditingController _servingsController;

  // Controllers per ingredienti
  final _ingredientNameController = TextEditingController();
  final _ingredientQuantityController = TextEditingController();
  final _ingredientUnitController = TextEditingController();

  // Controller per istruzioni
  final _instructionController = TextEditingController();

  // Controller per tags
  final _tagController = TextEditingController();

  late String _selectedDifficulty;
  late String _selectedCategory;
  late bool _isPublic;
  late List<Map<String, dynamic>> _ingredients;
  late List<Map<String, dynamic>> _instructions;
  late List<String> _tags;

  // Image handling
  Uint8List? _imageBytes;
  XFile? _selectedImageXFile;
  String? _currentImageUrl;
  bool _isUploading = false;
  bool _isLoading = false;
  bool _removeImage = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _titleController = TextEditingController(text: widget.recipe.title);
    _descriptionController =
        TextEditingController(text: widget.recipe.description);
    _prepTimeController =
        TextEditingController(text: widget.recipe.prepTime.toString());
    _cookTimeController =
        TextEditingController(text: widget.recipe.cookTime.toString());
    _servingsController =
        TextEditingController(text: widget.recipe.servings.toString());

    _selectedDifficulty = widget.recipe.difficulty.value;
    _selectedCategory = widget.recipe.category?.name ?? '';
    _isPublic = widget.recipe.isPublic;
    _ingredients = widget.recipe.ingredients.map((i) => i.toJson()).toList();
    _instructions = widget.recipe.instructions.map((i) => i.toJson()).toList();
    _tags = widget.recipe.tags.map((t) => t.name).toList();
    _currentImageUrl = widget.recipe.imageUrl;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _prepTimeController.dispose();
    _cookTimeController.dispose();
    _servingsController.dispose();
    _ingredientNameController.dispose();
    _ingredientQuantityController.dispose();
    _ingredientUnitController.dispose();
    _instructionController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1200,
    );

    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _selectedImageXFile = image;
        _imageBytes = bytes;
        _removeImage = false;
      });
    }
  }

  void _removeCurrentImage() {
    setState(() {
      _selectedImageXFile = null;
      _imageBytes = null;
      _currentImageUrl = null;
      _removeImage = true;
    });
  }

  void _addIngredient() {
    if (_ingredientNameController.text.trim().isEmpty) return;

    setState(() {
      _ingredients.add({
        'name': _ingredientNameController.text.trim(),
        'quantity': _ingredientQuantityController.text.trim().isEmpty
            ? null
            : _ingredientQuantityController.text.trim(),
        'unit': _ingredientUnitController.text.trim().isEmpty
            ? null
            : _ingredientUnitController.text.trim(),
      });

      _ingredientNameController.clear();
      _ingredientQuantityController.clear();
      _ingredientUnitController.clear();
    });
  }

  void _removeIngredient(int index) {
    setState(() {
      _ingredients.removeAt(index);
    });
  }

  void _addInstruction() {
    if (_instructionController.text.trim().isEmpty) return;

    setState(() {
      _instructions.add({
        'step': _instructions.length + 1,
        'description': _instructionController.text.trim(),
      });
      _instructionController.clear();
    });
  }

  void _removeInstruction(int index) {
    setState(() {
      _instructions.removeAt(index);
      // Rinumera gli step
      for (var i = 0; i < _instructions.length; i++) {
        _instructions[i]['step'] = i + 1;
      }
    });
  }

  void _addTag() {
    if (_tagController.text.trim().isEmpty) return;

    final newTag = _tagController.text.trim().toLowerCase();
    if (!_tags.contains(newTag)) {
      setState(() {
        _tags.add(newTag);
        _tagController.clear();
      });
    } else {
      _tagController.clear();
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  Future<void> _saveRecipe() async {
    setState(() => _isLoading = true);

    try {
      String? imageUrl = _currentImageUrl;

      // 1. Upload nuova immagine su Cloudinary (se presente)
      if (_selectedImageXFile != null && _imageBytes != null) {
        setState(() => _isUploading = true);

        final authService = Provider.of<AuthService>(context, listen: false);
        final uploadService = CloudinaryUploadService(authService);

        imageUrl = await uploadService.uploadImage(
          imageBytes: _imageBytes!,
          fileName: _selectedImageXFile!.name,
          folder: 'orsocook/recipes',
        );

        AppLogger.debug('✅ Nuova immagine caricata: $imageUrl');
        setState(() => _isUploading = false);
      }

      // 2. Se richiesta rimozione immagine
      if (_removeImage) {
        imageUrl = null;
      }

      // 3. Ottieni l'utente corrente
      final authService = Provider.of<AuthService>(context, listen: false);
      final currentUserId = authService.userId ?? '';
      final currentUsername = authService.username ?? '';

      // 4. Crea oggetto ricetta aggiornato
      final updatedRecipe = Recipe(
        id: widget.recipe.id,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        slug: widget.recipe.slug,
        imageUrl: imageUrl,
        prepTime: int.tryParse(_prepTimeController.text) ?? 0,
        cookTime: int.tryParse(_cookTimeController.text) ?? 0,
        servings: int.tryParse(_servingsController.text) ?? 1,
        difficulty: Difficulty.fromString(_selectedDifficulty),
        isPublic: _isPublic,
        views: widget.recipe.views,
        favoriteCount: widget.recipe.favoriteCount,
        likeCount: widget.recipe.likeCount,
        commentCount: widget.recipe.commentCount,
        isFavorite: widget.recipe.isFavorite,
        isLiked: widget.recipe.isLiked,
        author: UserAuthor(
          id: currentUserId,
          username: currentUsername,
          displayName: currentUsername,
          avatarUrl: authService.avatarUrl,
        ),
        category: _selectedCategory.isNotEmpty
            ? Category(
                id: '',
                name: _selectedCategory,
                slug: _selectedCategory.toLowerCase().replaceAll(' ', '-'),
              )
            : null,
        ingredients: _ingredients
            .map((i) => Ingredient(
                  name: i['name'] ?? '',
                  quantity: i['quantity']?.toString(),
                  unit: i['unit']?.toString(),
                ))
            .toList(),
        instructions: _instructions
            .map((i) => Instruction(
                  step: i['step'] ?? 0,
                  description: i['description'] ?? '',
                ))
            .toList(),
        tags: _tags
            .map((tagName) => Tag(
                  id: '',
                  name: tagName,
                  slug: '',
                ))
            .toList(),
        createdAt: widget.recipe.createdAt,
        updatedAt: DateTime.now(),
      );

      // 5. Aggiorna ricetta nel backend
      final recipeService = Provider.of<RecipeService>(context, listen: false);
      final result = await recipeService.updateRecipe(
        widget.recipe.id,
        updatedRecipe,
      );

      if (result != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ricetta aggiornata con successo!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        throw Exception('Errore nell\'aggiornamento della ricetta');
      }
    } catch (e) {
      AppLogger.error('❌ Errore aggiornamento ricetta', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Errore: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifica Ricetta'),
        actions: [
          if (_isLoading || _isUploading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            TextButton.icon(
              onPressed: _saveRecipe,
              icon: const Icon(Icons.save, color: Colors.white),
              label: const Text(
                'Salva',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      body: _isUploading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Caricamento immagine in corso...'),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  EditHeader(recipeTitle: widget.recipe.title),
                  const SizedBox(height: 16),
                  EditBasicInfo(
                    titleController: _titleController,
                    descriptionController: _descriptionController,
                    prepTimeController: _prepTimeController,
                    cookTimeController: _cookTimeController,
                    servingsController: _servingsController,
                    difficulty: _selectedDifficulty,
                    category: _selectedCategory,
                    isPublic: _isPublic,
                    onDifficultyChanged: (value) {
                      setState(() => _selectedDifficulty = value);
                    },
                    onCategoryChanged: (value) {
                      setState(() => _selectedCategory = value);
                    },
                    onIsPublicChanged: (value) {
                      setState(() => _isPublic = value);
                    },
                  ),
                  const SizedBox(height: 16),
                  EditImageSection(
                    imageBytes: _imageBytes,
                    selectedImageXFile: _selectedImageXFile,
                    imageUrl: _currentImageUrl ?? '',
                    onImageSelected: (image) async {
                      if (image != null) {
                        final bytes = await image.readAsBytes();
                        setState(() {
                          _selectedImageXFile = image;
                          _imageBytes = bytes;
                          _removeImage = false;
                        });
                      }
                    },
                    onImageRemoved: _removeCurrentImage,
                    pickImage: _pickImage,
                  ),
                  const SizedBox(height: 16),
                  EditIngredients(
                    ingredients: _ingredients,
                    nameController: _ingredientNameController,
                    quantityController: _ingredientQuantityController,
                    unitController: _ingredientUnitController,
                    onAddIngredient: _addIngredient,
                    onRemoveIngredient: _removeIngredient,
                  ),
                  const SizedBox(height: 16),
                  EditInstructions(
                    instructions: _instructions,
                    instructionController: _instructionController,
                    onAddInstruction: _addInstruction,
                    onRemoveInstruction: _removeInstruction,
                  ),
                  const SizedBox(height: 16),
                  EditTags(
                    tags: _tags,
                    tagController: _tagController,
                    onAddTag: _addTag,
                    onRemoveTag: _removeTag,
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }
}
