import 'package:flutter/material.dart';
import 'package:orsocook/utils/responsive_utils.dart';

class LoginLogo extends StatelessWidget {
  const LoginLogo({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    // Logo variabile tra 120 e 150 in base all'altezza
    double logoSize = (screenHeight * 0.12).clamp(120.0, 150.0);

    const double titleFontSize = 28;
    const double subtitleFontSize = 15;
    const double iconSize = 24;

    return Column(
      mainAxisSize: MainAxisSize.min,
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
          'Accedi al tuo account',
          style: TextStyle(
            fontSize: subtitleFontSize,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}
