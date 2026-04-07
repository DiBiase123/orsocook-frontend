import 'package:flutter/material.dart';
import 'package:orsocook/models/user_profile.dart';
import 'package:orsocook/utils/responsive_breakpoints.dart';
import 'package:orsocook/utils/responsive_values.dart';

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
    final bool isSmallScreen = ResponsiveBreakpoints.isMobile(context) &&
        ResponsiveBreakpoints.getWidth(context) <= 400;
    final bool isDesktop = ResponsiveBreakpoints.isDesktop(context);

    final double iconSize = isSmallScreen ? 28 : (isDesktop ? 36 : 32);
    final double valueFontSize = isSmallScreen ? 18 : (isDesktop ? 24 : 20);
    final double labelFontSize = isSmallScreen ? 10 : (isDesktop ? 14 : 12);
    final double containerPadding = isSmallScreen ? 10 : (isDesktop ? 16 : 12);
    final double gapValue = ResponsiveValues.gapSmall(context);

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
          label: Text(
            'Statistiche',
            style: TextStyle(
              fontSize: ResponsiveValues.titleSize(context),
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!, width: 2),
          ),
          filled: true,
          fillColor: Colors.grey[50],
          contentPadding: ResponsiveValues.screenPadding(context),
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
                gap: gapValue,
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
                gap: gapValue,
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
                gap: gapValue,
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
                gap: gapValue,
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
    required double gap,
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
            child: Icon(icon, color: color, size: iconSize),
          ),
          SizedBox(height: gap),
          Text(value, style: valueStyle),
          SizedBox(height: gap),
          Text(label, style: labelStyle, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
