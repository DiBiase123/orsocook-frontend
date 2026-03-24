import 'package:flutter/material.dart';
import 'style.dart';
import 'content.dart';

class RegisterModal extends StatelessWidget {
  const RegisterModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: RegisterModalStyle.cardWidth,
        constraints: RegisterModalStyle.constraints,
        margin: const EdgeInsets.symmetric(vertical: 40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(RegisterModalStyle.borderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(40),
              blurRadius: RegisterModalStyle.shadowBlur,
              offset: Offset(0, RegisterModalStyle.shadowOffsetY),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: Colors.black.withAlpha(20),
              blurRadius: 20,
              offset: const Offset(0, 8),
              spreadRadius: 0,
            ),
          ],
          border: Border.all(
            color: Colors.grey.withAlpha(50),
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(RegisterModalStyle.borderRadius),
          child: RegisterModalContent(
            onClose: () => Navigator.of(context).pop(),
          ),
        ),
      ),
    );
  }
}
