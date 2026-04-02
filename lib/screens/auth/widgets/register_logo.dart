import 'package:flutter/material.dart';

class RegisterLogo extends StatelessWidget {
  const RegisterLogo({super.key});

  @override
  Widget build(BuildContext context) {
    // Calcola le dimensioni in base alla larghezza dello schermo
    final screenWidth = MediaQuery.of(context).size.width;

    // Dimensioni responsive (identiche al login)
    double logoSize;
    double titleFontSize;
    double subtitleFontSize;
    double iconSize;

    if (screenWidth > 1200) {
      logoSize = 120;
      titleFontSize = 32;
      subtitleFontSize = 16;
      iconSize = 26;
    } else if (screenWidth > 800) {
      logoSize = 100;
      titleFontSize = 28;
      subtitleFontSize = 15;
      iconSize = 24;
    } else if (screenWidth > 600) {
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
        // Logo con immagine
        ClipOval(
          child: Image.asset(
            'assets/images/OrsoCooK.png',
            width: logoSize,
            height: logoSize,
            fit: BoxFit.cover,
          ),
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
