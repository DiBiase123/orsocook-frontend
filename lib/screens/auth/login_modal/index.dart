import 'dart:ui';
import 'package:flutter/material.dart';
import 'style.dart';
import 'content.dart';

class LoginModal extends StatelessWidget {
  const LoginModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Center(
        child: Container(
          width: LoginModalStyle.cardWidth,
          constraints: LoginModalStyle.constraints,
          margin: const EdgeInsets.symmetric(vertical: 40),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(LoginModalStyle.borderRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(40),
                blurRadius: 40,
                offset: const Offset(0, 20),
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
            borderRadius: BorderRadius.circular(LoginModalStyle.borderRadius),
            child: LoginModalContent(
              onClose: () => Navigator.of(context).pop(),
            ),
          ),
        ),
      ),
    );
  }
}
