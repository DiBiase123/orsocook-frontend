import 'package:flutter/material.dart';
import 'package:orsocook/models/recipe.dart';
import 'package:orsocook/utils/responsive_values.dart';

class DetailInfoSection extends StatelessWidget {
  final Recipe recipe;

  const DetailInfoSection({super.key, required this.recipe});

  Widget _buildInfoItem(IconData icon, String text, BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.orange),
        SizedBox(height: ResponsiveValues.gapSmall(context)),
        Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: ResponsiveValues.bodySize(context),
          ),
        ),
      ],
    );
  }

  String _getDifficultyString(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return 'Facile';
      case Difficulty.medium:
        return 'Media';
      case Difficulty.hard:
        return 'Difficile';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: ResponsiveValues.screenPadding(context),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildInfoItem(Icons.timer,
                '${recipe.prepTime + recipe.cookTime} min', context),
            _buildInfoItem(Icons.people, '${recipe.servings} pers.', context),
            _buildInfoItem(Icons.bar_chart,
                _getDifficultyString(recipe.difficulty), context),
            _buildInfoItem(
                Icons.visibility, '${recipe.views} visual.', context),
          ],
        ),
      ),
    );
  }
}
