import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:orsocook/screens/recipe/create_recipe/viewmodels/create_recipe_viewmodel.dart';
import 'package:orsocook/screens/recipe/create_recipe/create_basic_info.dart';
import 'package:orsocook/screens/recipe/create_recipe/create_image_section.dart';
import 'package:orsocook/screens/recipe/create_recipe/create_ingredients.dart';
import 'package:orsocook/screens/recipe/create_recipe/create_instructions.dart';
import 'package:orsocook/screens/recipe/create_recipe/create_tags.dart';

class RecipeForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;

  const RecipeForm({super.key, required this.formKey});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<CreateRecipeViewModel>(context);

    return Form(
      key: formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          CreateBasicInfo(
            titleController: viewModel.titleController,
            descriptionController: viewModel.descriptionController,
            prepTimeController: viewModel.prepTimeController,
            cookTimeController: viewModel.cookTimeController,
            servingsController: viewModel.servingsController,
            difficulty: viewModel.selectedDifficulty,
            category: viewModel.selectedCategory,
            isPublic: viewModel.isPublic,
            onDifficultyChanged: viewModel.updateDifficulty,
            onCategoryChanged: viewModel.updateCategory,
            onIsPublicChanged: viewModel.updateIsPublic,
          ),
          const SizedBox(height: 16),
          CreateImageSection(
            imageBytes: viewModel.imageBytes,
            selectedImageXFile: viewModel.selectedImageXFile,
            onImageSelected: (image) async {
              if (image != null) {
                final bytes = await image.readAsBytes();
                // Usa il metodo del ViewModel invece di chiamare notifyListeners direttamente
                viewModel.setImageData(image, bytes);
              }
            },
            onImageRemoved: viewModel.removeImage,
            pickImage: viewModel.pickImage,
          ),
          const SizedBox(height: 16),
          CreateIngredients(
            ingredients: viewModel.ingredients,
            nameController: viewModel.ingredientNameController,
            quantityController: viewModel.ingredientQuantityController,
            unitController: viewModel.ingredientUnitController,
            onAddIngredient: viewModel.addIngredient,
            onRemoveIngredient: viewModel.removeIngredient,
          ),
          const SizedBox(height: 16),
          CreateInstructions(
            instructions: viewModel.instructions,
            instructionController: viewModel.instructionController,
            onAddInstruction: viewModel.addInstruction,
            onRemoveInstruction: viewModel.removeInstruction,
          ),
          const SizedBox(height: 16),
          CreateTags(
            tags: viewModel.tags,
            tagController: viewModel.tagController,
            onAddTag: viewModel.addTag,
            onRemoveTag: viewModel.removeTag,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
