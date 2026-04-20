import 'package:flutter/material.dart';
import 'package:orsocook/models/recipe.dart';
import 'package:orsocook/utils/responsive_utils.dart';

class DetailInstructionsSection extends StatelessWidget {
  final Recipe recipe;

  const DetailInstructionsSection({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Procedimento',
          style: TextStyle(
            fontSize: ResponsiveValues.titleSize(context),
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: ResponsiveValues.gapMedium(context)),
        ...recipe.instructions.map((instruction) => Card(
              margin:
                  EdgeInsets.only(bottom: ResponsiveValues.gapMedium(context)),
              child: Padding(
                padding: ResponsiveValues.screenPadding(context),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: colorScheme.tertiary,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Center(
                        child: Text(
                          '${instruction.step}',
                          style: TextStyle(
                            color: colorScheme.onTertiary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        instruction.description,
                        style: TextStyle(
                          fontSize: ResponsiveValues.bodySize(context),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )),
      ],
    );
  }
}
