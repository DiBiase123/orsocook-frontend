import 'package:flutter/material.dart';
import 'package:orsocook/models/recipe.dart';
import 'package:orsocook/screens/recipe/detail_recipe/widgets/detail_image_section.dart';
import 'package:orsocook/screens/recipe/detail_recipe/widgets/detail_header_section.dart';
import 'package:orsocook/screens/recipe/detail_recipe/widgets/detail_info_section.dart';
import 'package:orsocook/screens/recipe/detail_recipe/widgets/detail_ingredients_section.dart';
import 'package:orsocook/screens/recipe/detail_recipe/widgets/detail_instructions_section.dart';
import 'package:orsocook/screens/recipe/detail_recipe/widgets/detail_tags_section.dart';
import 'package:orsocook/screens/recipe/detail_recipe/widgets/detail_comments_section.dart';
import 'package:orsocook/utils/responsive_values.dart';

class DetailBody extends StatelessWidget {
  final Recipe recipe;
  final int likeCount;
  final bool? isFavorite;

  const DetailBody({
    super.key,
    required this.recipe,
    required this.likeCount,
    this.isFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final updatedRecipe = recipe.copyWith(
      likeCount: likeCount,
      isFavorite: isFavorite ?? false,
    );

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveValues.screenPadding(context).horizontal,
        vertical: ResponsiveValues.gapLarge(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DetailHeaderSection(recipe: updatedRecipe),
          if (updatedRecipe.imageUrl != null &&
              updatedRecipe.imageUrl!.isNotEmpty)
            DetailImageSection(recipe: updatedRecipe),
          DetailInfoSection(recipe: updatedRecipe),
          SizedBox(height: ResponsiveValues.gapExtraLarge(context)),
          DetailIngredientsSection(recipe: updatedRecipe),
          SizedBox(height: ResponsiveValues.gapLarge(context)),
          DetailInstructionsSection(recipe: updatedRecipe),
          DetailTagsSection(recipe: updatedRecipe),
          SizedBox(height: ResponsiveValues.gapExtraLarge(context)),
          DetailCommentsSection(recipeId: updatedRecipe.id),
          SizedBox(height: ResponsiveValues.gapExtraLarge(context)),
        ],
      ),
    );
  }
}
