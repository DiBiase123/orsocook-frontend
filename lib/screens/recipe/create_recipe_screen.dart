import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../models/recipe.dart';
import '../../services/recipe_service.dart';
import '../../utils/logger.dart';
import 'create_recipe/create_image_section.dart';
import 'create_recipe/create_basic_info.dart';
import 'create_recipe/create_ingredients.dart';
import 'create_recipe/create_instructions.dart';
import 'create_recipe/create_tags.dart';
import 'create_recipe/create_header.dart';

class CreateRecipeScreen extends StatefulWidget {
  const CreateRecipeScreen({super.key});

  @override
  State<CreateRecipeScreen> createState() => _CreateRecipeScreenState();
}

class _CreateRecipeScreenState extends State<CreateRecipeScreen> {
  // ✅ CONTROLLER E VARIABILI
  late final GlobalKey<FormState> formKey;
  late final TextEditingController titleController;
  late final TextEditingController descriptionController;
  late final TextEditingController prepTimeController;
  late final TextEditingController cookTimeController;
  late final TextEditingController servingsController;

  final List<Map<String, dynamic>> ingredients = [];
  final List<Map<String, dynamic>> instructions = [];
  final List<String> tags = [];

  String difficulty = 'MEDIUM';
  String category = 'Primi';
  bool isPublic = true;
  bool isLoading = false;
  File? selectedImage;

  late final TextEditingController ingredientNameController;
  late final TextEditingController ingredientQuantityController;
  late final TextEditingController ingredientUnitController;
  late final TextEditingController instructionController;
  late final TextEditingController tagController;

  @override
  void initState() {
    super.initState();

    // ✅ INIZIALIZZAZIONE CONTROLLER
    formKey = GlobalKey<FormState>();
    titleController = TextEditingController();
    descriptionController = TextEditingController();
    prepTimeController = TextEditingController();
    cookTimeController = TextEditingController();
    servingsController = TextEditingController(text: '4');
    ingredientNameController = TextEditingController();
    ingredientQuantityController = TextEditingController();
    ingredientUnitController = TextEditingController();
    instructionController = TextEditingController();
    tagController = TextEditingController();

    AppLogger.recipe('➕ CreateRecipeScreen inizializzata');

    // ✅ DATI DI ESEMPIO (rimuovere in produzione)
    ingredients.add({'name': 'Farina', 'quantity': '200', 'unit': 'g'});
    ingredients.add({'name': 'Uova', 'quantity': '2', 'unit': ''});
    instructions
        .add({'step': 1, 'description': 'Mescolare gli ingredienti secchi'});
    instructions
        .add({'step': 2, 'description': 'Aggiungere le uova e mescolare'});
    tags.addAll(['facile', 'veloce', 'italiano']);
  }

  @override
  void dispose() {
    // ✅ DISPOSE CONTROLLER
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
    AppLogger.debug('♻️ CreateRecipeScreen disposed');
  }

  // ==================== METODI IMMAGINE ====================
  Future<void> _pickImage() async {
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galleria'),
              onTap: () async {
                Navigator.pop(context);
                await _selectImageFromGallery();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Fotocamera'),
              onTap: () async {
                Navigator.pop(context);
                await _selectImageFromCamera();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectImageFromGallery() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1200,
    );
    if (image != null && mounted) {
      setState(() {
        selectedImage = File(image.path);
      });
    }
  }

  Future<void> _selectImageFromCamera() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
      maxWidth: 1200,
    );
    if (image != null && mounted) {
      setState(() {
        selectedImage = File(image.path);
      });
    }
  }

  void _removeImage() {
    if (!mounted) return;
    setState(() => selectedImage = null);
  }

  // ==================== METODI INGREDIENTI ====================
  void _addIngredient() {
    if (ingredientNameController.text.isEmpty) return;
    ingredients.add({
      'name': ingredientNameController.text,
      'quantity': ingredientQuantityController.text.isNotEmpty
          ? ingredientQuantityController.text
          : '1',
      'unit': ingredientUnitController.text,
    });
    ingredientNameController.clear();
    ingredientQuantityController.clear();
    ingredientUnitController.clear();
    if (mounted) setState(() {});
  }

  void _removeIngredient(int index) {
    if (index >= 0 && index < ingredients.length) {
      ingredients.removeAt(index);
      if (mounted) setState(() {});
    }
  }

  // ==================== METODI ISTRUZIONI ====================
  void _addInstruction() {
    if (instructionController.text.isEmpty) return;
    instructions.add({
      'step': instructions.length + 1,
      'description': instructionController.text,
    });
    instructionController.clear();
    if (mounted) setState(() {});
  }

  void _removeInstruction(int index) {
    if (index >= 0 && index < instructions.length) {
      instructions.removeAt(index);
      // Riorganizza i numeri dei passi
      for (var i = 0; i < instructions.length; i++) {
        instructions[i]['step'] = i + 1;
      }
      if (mounted) setState(() {});
    }
  }

  // ==================== METODI TAG ====================
  void _addTag() {
    final tag = tagController.text.trim().toLowerCase();
    if (tag.isEmpty || tags.contains(tag)) return;
    tags.add(tag);
    tagController.clear();
    if (mounted) setState(() {});
  }

  void _removeTag(String tag) {
    tags.remove(tag);
    if (mounted) setState(() {});
  }

  // ==================== GESTIONE USCITA ====================
  void _showExitConfirmation() {
    if (_hasUnsavedChanges()) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Annullare?'),
          content: const Text(
              'Le modifiche non salvate andranno perse. Continuare?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('NO'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                if (mounted) Navigator.pop(context);
              },
              child: const Text('SÌ'),
            ),
          ],
        ),
      );
    } else {
      if (mounted) Navigator.pop(context);
    }
  }

  bool _hasUnsavedChanges() {
    return titleController.text.isNotEmpty ||
        descriptionController.text.isNotEmpty ||
        ingredients.isNotEmpty ||
        selectedImage != null;
  }

  // ==================== SUBMIT RICETTA ====================
  Future<void> _submitRecipe() async {
    if (!formKey.currentState!.validate()) return;
    if (ingredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Aggiungi almeno un ingrediente'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    if (instructions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Aggiungi almeno un passaggio'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final recipeService = Provider.of<RecipeService>(context, listen: false);

      final recipeToCreate = Recipe.fromJson({
        'id': '',
        'title': titleController.text.trim(),
        'description': descriptionController.text.trim(),
        'slug': titleController.text.trim().toLowerCase().replaceAll(' ', '-'),
        'imageUrl': '',
        'prepTime': int.tryParse(prepTimeController.text) ?? 0,
        'cookTime': int.tryParse(cookTimeController.text) ?? 0,
        'servings': int.tryParse(servingsController.text) ?? 4,
        'difficulty': difficulty,
        'isPublic': isPublic,
        'views': 0,
        'authorId': '',
        'author': {},
        'categoryId': '',
        'category': {'name': category},
        'ingredients': ingredients,
        'instructions': instructions,
        'tags': tags,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
        'commentCount': 0,
      });

      // ✅ CHIAMA createRecipe CON L'IMMAGINE
      final createdRecipe = await recipeService.createRecipe(
        recipeToCreate,
        imageFile: selectedImage, // PASSA L'IMMAGINE!
      );

      if (mounted) {
        setState(() => isLoading = false);

        if (createdRecipe != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('"${createdRecipe.title}" creata con successo!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop(true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Errore durante la creazione della ricetta'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      AppLogger.error('Errore creazione ricetta', e);
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Errore: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CreateHeader(
        isLoading: isLoading,
        onBackPressed: _showExitConfirmation,
      ),
      body: Form(
        key: formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // ✅ SEZIONE IMMAGINE
              CreateImageSection(
                selectedImage: selectedImage,
                onImageSelected: (image) {
                  if (mounted) setState(() => selectedImage = image);
                },
                onImageRemoved: _removeImage,
                pickImage: _pickImage,
              ),
              const SizedBox(height: 16),

              // ✅ SEZIONE INFO BASE
              CreateBasicInfo(
                titleController: titleController,
                descriptionController: descriptionController,
                prepTimeController: prepTimeController,
                cookTimeController: cookTimeController,
                servingsController: servingsController,
                difficulty: difficulty,
                category: category,
                isPublic: isPublic,
                onDifficultyChanged: (value) {
                  if (mounted) setState(() => difficulty = value);
                },
                onCategoryChanged: (value) {
                  if (mounted) setState(() => category = value);
                },
                onIsPublicChanged: (value) {
                  if (mounted) setState(() => isPublic = value);
                },
              ),
              const SizedBox(height: 16),

              // ✅ SEZIONE INGREDIENTI
              CreateIngredients(
                ingredients: ingredients,
                nameController: ingredientNameController,
                quantityController: ingredientQuantityController,
                unitController: ingredientUnitController,
                onAddIngredient: _addIngredient,
                onRemoveIngredient: _removeIngredient,
              ),
              const SizedBox(height: 16),

              // ✅ SEZIONE ISTRUZIONI
              CreateInstructions(
                instructions: instructions,
                instructionController: instructionController,
                onAddInstruction: _addInstruction,
                onRemoveInstruction: _removeInstruction,
              ),
              const SizedBox(height: 16),

              // ✅ SEZIONE TAG
              CreateTags(
                tags: tags,
                tagController: tagController,
                onAddTag: _addTag,
                onRemoveTag: _removeTag,
              ),
              const SizedBox(height: 32),

              // ✅ BOTTONE PUBBLICA
              ElevatedButton(
                onPressed: isLoading ? null : _submitRecipe,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.deepOrange,
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'PUBBLICA RICETTA',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              const SizedBox(height: 20),
              const Text(
                '* Campi obbligatori',
                style: TextStyle(
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
