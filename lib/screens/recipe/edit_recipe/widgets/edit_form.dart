import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:orsocook/screens/recipe/edit_recipe/viewmodels/edit_recipe_viewmodel.dart';
import 'package:orsocook/screens/recipe/edit_recipe/edit_header.dart';
import 'package:orsocook/screens/recipe/edit_recipe/edit_basic_info.dart';
import 'package:orsocook/screens/recipe/edit_recipe/edit_image_section.dart';
import 'package:orsocook/screens/recipe/edit_recipe/edit_ingredients.dart';
import 'package:orsocook/screens/recipe/edit_recipe/edit_instructions.dart';
import 'package:orsocook/screens/recipe/edit_recipe/edit_tags.dart';

class EditForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;

  const EditForm({super.key, required this.formKey});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<EditRecipeViewModel>(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: formKey, // ← AGGIUNTO!
        child: Column(
          children: [
            EditHeader(recipeTitle: viewModel.originalRecipe.title),
            const SizedBox(height: 16),
            EditBasicInfo(
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
            EditImageSection(
              imageBytes: viewModel.imageBytes,
              selectedImageXFile: viewModel.selectedImageXFile,
              imageUrl: viewModel.currentImageUrl ?? '',
              onImageSelected: (image) async {
                if (image != null) {
                  final bytes = await image.readAsBytes();
                  viewModel.setImageData(image, bytes);
                }
              },
              onImageRemoved: viewModel.removeCurrentImage,
            ),
            const SizedBox(height: 16),
            EditIngredients(
              ingredients: viewModel.ingredients,
              nameController: viewModel.ingredientNameController,
              quantityController: viewModel.ingredientQuantityController,
              unitController: viewModel.ingredientUnitController,
              onAddIngredient: viewModel.addIngredient,
              onRemoveIngredient: viewModel.removeIngredient,
            ),
            const SizedBox(height: 16),
            EditInstructions(
              instructions: viewModel.instructions,
              instructionController: viewModel.instructionController,
              onAddInstruction: viewModel.addInstruction,
              onRemoveInstruction: viewModel.removeInstruction,
            ),
            const SizedBox(height: 16),
            EditTags(
              tags: viewModel.tags,
              tagController: viewModel.tagController,
              onAddTag: viewModel.addTag,
              onRemoveTag: viewModel.removeTag,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
