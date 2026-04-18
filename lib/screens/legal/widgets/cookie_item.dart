import 'package:flutter/material.dart';
import 'package:orsocook/utils/responsive_values.dart';
import 'package:orsocook/screens/legal/colors/section_colors.dart';
import 'package:orsocook/screens/legal/data/cookie_data.dart';

class CookieItemWidget extends StatelessWidget {
  final CookieData cookie;
  final int index;
  final bool isDarkMode;
  final BuildContext context;

  const CookieItemWidget({
    super.key,
    required this.cookie,
    required this.index,
    required this.isDarkMode,
    required this.context,
  });

  @override
  Widget build(BuildContext context) {
    final color = SectionColors.getColor(index, isDarkMode);
    final bgColor = isDarkMode ? color.withAlpha(15) : color.withAlpha(12);
    final borderColor = isDarkMode ? color.withAlpha(40) : color.withAlpha(30);

    return Container(
      padding: ResponsiveValues.screenPadding(context),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  cookie.type.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  cookie.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '🎯 Scopo: ${cookie.purpose}',
            style: TextStyle(
              fontSize: ResponsiveValues.bodySize(context),
              color: isDarkMode ? Colors.white70 : Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '⏱️ Durata: ${cookie.duration}',
            style: TextStyle(
              fontSize: ResponsiveValues.bodySize(context),
              color: isDarkMode ? Colors.white70 : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
