import 'package:flutter/material.dart';
import 'package:responsive_adaptive_ui/responsive_adaptive_ui.dart';
import 'package:orsocook/models/user_profile.dart';

class ProfileStatsWidget extends StatelessWidget {
  final UserStats stats;
  final bool compact;

  const ProfileStatsWidget({
    super.key,
    required this.stats,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenWidth <= 400;

    final double iconSize = isSmallScreen ? 28 : 32;
    final double valueFontSize = isSmallScreen ? 18 : 20;
    final double labelFontSize = isSmallScreen ? 10 : 12;
    final double containerPadding = isSmallScreen ? 10 : 12;

    final valueStyle = TextStyle(
      fontSize: valueFontSize,
      fontWeight: FontWeight.bold,
    );

    final labelStyle = TextStyle(
      fontSize: labelFontSize,
      fontWeight: FontWeight.w600,
      color: Colors.grey[700],
    );

    return Container(
      height: double.infinity,
      constraints: const BoxConstraints(minHeight: 200),
      child: InputDecorator(
        decoration: InputDecoration(
          label: ResponsiveText(
            'Statistiche',
            min: 28,
            max: 48,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Colors.grey[300]!,
              width: 2,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Colors.grey[300]!,
              width: 2,
            ),
          ),
          filled: true,
          fillColor: Colors.grey[50],
          contentPadding: const EdgeInsets.all(16),
        ),
        child: Center(
          child: Row(
            children: [
              _buildStatItem(
                icon: Icons.restaurant_menu,
                value: stats.recipesCount.toString(),
                label: isSmallScreen ? 'Ric.' : 'Ricette',
                color: primaryColor,
                iconSize: iconSize,
                containerPadding: containerPadding,
                valueStyle: valueStyle,
                labelStyle: labelStyle,
              ),
              _buildStatItem(
                icon: Icons.favorite,
                value: stats.favoritesCount.toString(),
                label: isSmallScreen ? 'Pref.' : 'Preferiti',
                color: Colors.red,
                iconSize: iconSize,
                containerPadding: containerPadding,
                valueStyle: valueStyle,
                labelStyle: labelStyle,
              ),
              _buildStatItem(
                icon: Icons.visibility,
                value: stats.totalViews.toString(),
                label: isSmallScreen ? 'Vis.' : 'Visualizzazioni',
                color: Colors.green,
                iconSize: iconSize,
                containerPadding: containerPadding,
                valueStyle: valueStyle,
                labelStyle: labelStyle,
              ),
              _buildStatItem(
                icon: Icons.trending_up,
                value: '${stats.averageViewsPerRecipe}',
                label: isSmallScreen ? 'Med.' : 'Media',
                color: Colors.orange,
                iconSize: iconSize,
                containerPadding: containerPadding,
                valueStyle: valueStyle,
                labelStyle: labelStyle,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    required double iconSize,
    required double containerPadding,
    required TextStyle valueStyle,
    required TextStyle labelStyle,
  }) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(containerPadding),
            decoration: BoxDecoration(
              color: color.withAlpha(26),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: iconSize,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: valueStyle,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: labelStyle,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
