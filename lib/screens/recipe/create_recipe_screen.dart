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
import 'create_recipe/create_header.dart';
import 'create_recipe/create_basic_info.dart';
import 'create_recipe/create_image_section.dart';
import 'create_recipe/create_ingredients.dart';
import 'create_recipe/create_instructions.dart';
import 'create_recipe/create_tags.dart';

class CreateRecipeScreen extends StatefulWidget {
  const CreateRecipeScreen({super.key});

  @override
  State<CreateRecipeScreen> createState() => _CreateRecipeScreenState();
}

class _CreateRecipeScreenState extends State<CreateRecipeScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _prepTimeController = TextEditingController();
  final _cookTimeController = TextEditingController();
  final _servingsController = TextEditingController();

  // Controllers per ingredienti
  final _ingredientNameController = TextEditingController();
  final _ingredientQuantityController = TextEditingController();
  final _ingredientUnitController = TextEditingController();

  // Controller per istruzioni
  final _instructionController = TextEditingController();

  // Controller per tags
  final _tagController = TextEditingController();

  // State
  String _selectedDifficulty = 'MEDIUM';
  String _selectedCategory = '';
  bool _isPublic = true;
  List<Map<String, dynamic>> _ingredients = [];
  List<Map<String, dynamic>> _instructions = [];
  List<String> _tags = [];

  // Image handling
  Uint8List? _imageBytes;
  XFile? _selectedImageXFile;
  bool _isUploading = false;
  bool _isLoading = false;

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
      });
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImageXFile = null;
      _imageBytes = null;
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

  void _handleBackPressed() {
    Navigator.pop(context);
  }

  Future<void> _saveRecipe() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // 1. Upload immagine su Cloudinary (se presente)
      String? imageUrl;
      if (_selectedImageXFile != null && _imageBytes != null) {
        setState(() => _isUploading = true);

        final authService = Provider.of<AuthService>(context, listen: false);
        final uploadService = CloudinaryUploadService(authService);

        imageUrl = await uploadService.uploadImage(
          imageBytes: _imageBytes!,
          fileName: _selectedImageXFile!.name,
          folder: 'orsocook/recipes',
        );

        AppLogger.debug('✅ Immagine caricata: $imageUrl');
        setState(() => _isUploading = false);
      }

      // 2. Ottieni l'utente corrente
      final authService = Provider.of<AuthService>(context, listen: false);
      final currentUserId = authService.userId ?? '';
      final currentUsername = authService.username ?? '';

      // 3. Crea oggetto ricetta
      final recipe = Recipe(
        id: '',
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        slug: '',
        imageUrl: imageUrl,
        prepTime: int.tryParse(_prepTimeController.text) ?? 0,
        cookTime: int.tryParse(_cookTimeController.text) ?? 0,
        servings: int.tryParse(_servingsController.text) ?? 1,
        difficulty: _selectedDifficulty == 'EASY'
            ? Difficulty.EASY
            : _selectedDifficulty == 'HARD'
                ? Difficulty.HARD
                : Difficulty.MEDIUM,
        isPublic: _isPublic,
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
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // 4. Crea ricetta nel backend
      final recipeService = Provider.of<RecipeService>(context, listen: false);
      final createdRecipe = await recipeService.createRecipe(recipe);

      if (createdRecipe != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ricetta creata con successo!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        throw Exception('Errore nella creazione della ricetta');
      }
    } catch (e) {
      AppLogger.error('❌ Errore salvataggio ricetta', e);
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
        title: const Text('Crea Nuova Ricetta'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _handleBackPressed,
        ),
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
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  CreateBasicInfo(
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
                  CreateImageSection(
                    imageBytes: _imageBytes,
                    selectedImageXFile: _selectedImageXFile,
                    onImageSelected: (image) async {
                      if (image != null) {
                        final bytes = await image.readAsBytes();
                        setState(() {
                          _selectedImageXFile = image;
                          _imageBytes = bytes;
                        });
                      }
                    },
                    onImageRemoved: _removeImage,
                    pickImage: _pickImage,
                  ),
                  const SizedBox(height: 16),
                  CreateIngredients(
                    ingredients: _ingredients,
                    nameController: _ingredientNameController,
                    quantityController: _ingredientQuantityController,
                    unitController: _ingredientUnitController,
                    onAddIngredient: _addIngredient,
                    onRemoveIngredient: _removeIngredient,
                  ),
                  const SizedBox(height: 16),
                  CreateInstructions(
                    instructions: _instructions,
                    instructionController: _instructionController,
                    onAddInstruction: _addInstruction,
                    onRemoveInstruction: _removeInstruction,
                  ),
                  const SizedBox(height: 16),
                  CreateTags(
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
