import 'package:flutter/material.dart';

class LoginLogo extends StatelessWidget {
  const LoginLogo({super.key});

  @override
  Widget build(BuildContext context) {
    // Calcola le dimensioni in base alla larghezza dello schermo
    final screenWidth = MediaQuery.of(context).size.width;

    // Dimensioni responsive
    double logoSize;
    double titleFontSize;
    double subtitleFontSize;
    double iconSize;

    if (screenWidth > 1200) {
      // Desktop grande: aumentato del 15% (da 165 a 190)
      logoSize = 190;
      titleFontSize = 32;
      subtitleFontSize = 16;
      iconSize = 26;
    } else if (screenWidth > 800) {
      // Desktop medio: aumentato del 15% (da 150 a 172)
      logoSize = 172;
      titleFontSize = 28;
      subtitleFontSize = 15;
      iconSize = 24;
    } else if (screenWidth > 600) {
      // Tablet: invariato
      logoSize = 165;
      titleFontSize = 32;
      subtitleFontSize = 15;
      iconSize = 26;
    } else {
      // Mobile: invariato
      logoSize = 165;
      titleFontSize = 35;
      subtitleFontSize = 16;
      iconSize = 28;
    }

    return Column(
      children: [
        // Logo responsive
        Image.asset(
          'assets/images/OrsoCooK.png',
          height: logoSize,
          width: logoSize,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 16),
        // Titolo con icona responsive
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.restaurant_menu,
              size: iconSize,
              color: Colors.deepOrange,
            ),
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
            Icon(
              Icons.restaurant_menu,
              size: iconSize,
              color: Colors.deepOrange,
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Sottotitolo responsive
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
