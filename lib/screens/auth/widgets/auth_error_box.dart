import 'package:flutter/material.dart';
import 'package:orsocook/utils/responsive_utils.dart';

class AuthErrorBox extends StatelessWidget {
  final String message;
  final Color color;
  final IconData icon;

  const AuthErrorBox({
    super.key,
    required this.message,
    this.color = Colors.red,
    this.icon = Icons.error_outline,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: ResponsiveValues.screenPadding(context),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha(40)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: color,
                fontSize: ResponsiveValues.bodySize(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
