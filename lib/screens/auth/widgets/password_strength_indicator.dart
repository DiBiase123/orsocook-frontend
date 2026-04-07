import 'package:flutter/material.dart';
import 'package:orsocook/utils/responsive_values.dart';

class PasswordStrengthIndicator extends StatelessWidget {
  final String password;

  const PasswordStrengthIndicator({
    super.key,
    required this.password,
  });

  @override
  Widget build(BuildContext context) {
    if (password.isEmpty) return const SizedBox.shrink();

    int strength = 0;

    if (password.length >= 8) strength++;
    if (RegExp(r'[A-Z]').hasMatch(password)) strength++;
    if (RegExp(r'[0-9]').hasMatch(password)) strength++;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) strength++;

    Color color;
    String text;

    switch (strength) {
      case 0:
      case 1:
        color = Colors.red;
        text = 'Debole';
        break;
      case 2:
        color = Colors.orange;
        text = 'Media';
        break;
      case 3:
        color = Colors.lightGreen;
        text = 'Buona';
        break;
      case 4:
        color = Colors.green;
        text = 'Forte';
        break;
      default:
        color = Colors.grey;
        text = '';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: ResponsiveValues.gapSmall(context)),
        Text(
          'Forza password: $text',
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: ResponsiveValues.gapSmall(context)),
        LinearProgressIndicator(
          value: strength / 4,
          backgroundColor: Colors.grey[300],
          color: color,
        ),
      ],
    );
  }
}
