import 'package:flutter/material.dart';
import 'package:orsocook/utils/responsive_breakpoints.dart';
import 'package:orsocook/utils/responsive_values.dart';

class RegisterLogo extends StatelessWidget {
  const RegisterLogo({super.key});

  @override
  Widget build(BuildContext context) {
    // Dimensioni responsive usando i breakpoint centralizzati
    double logoSize;
    double titleFontSize;
    double subtitleFontSize;
    double iconSize;

    if (ResponsiveBreakpoints.isLargeDesktop(context)) {
      logoSize = 120;
      titleFontSize = 32;
      subtitleFontSize = 16;
      iconSize = 26;
    } else if (ResponsiveBreakpoints.isDesktop(context)) {
      logoSize = 100;
      titleFontSize = 28;
      subtitleFontSize = 15;
      iconSize = 24;
    } else if (ResponsiveBreakpoints.isTablet(context)) {
      logoSize = 90;
      titleFontSize = 32;
      subtitleFontSize = 15;
      iconSize = 26;
    } else {
      logoSize = 80;
      titleFontSize = 35;
      subtitleFontSize = 16;
      iconSize = 28;
    }

    return Column(
      children: [
        ClipOval(
          child: Image.asset(
            'assets/images/OrsoCooK.png',
            width: logoSize,
            height: logoSize,
            fit: BoxFit.cover,
          ),
        ),
        SizedBox(height: ResponsiveValues.gapMedium(context)),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.restaurant_menu,
                size: iconSize, color: Colors.deepOrange),
            const SizedBox(width: 8),
            Text(
              'OrsoCook',
              style: TextStyle(
                fontSize: titleFontSize,
                fontWeight: FontWeight.bold,
                color: Colors.deepOrange,
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.restaurant_menu,
                size: iconSize, color: Colors.deepOrange),
          ],
        ),
        SizedBox(height: ResponsiveValues.gapSmall(context)),
        Text(
          'Crea il tuo account',
          style: TextStyle(
            fontSize: subtitleFontSize,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}
