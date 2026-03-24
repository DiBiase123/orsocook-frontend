import 'package:flutter/material.dart';
import 'style.dart';
import 'content.dart';

class ForgotPasswordModal extends StatelessWidget {
  const ForgotPasswordModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: ForgotPasswordModalStyle.cardWidth,
        constraints: ForgotPasswordModalStyle.constraints,
        margin: const EdgeInsets.symmetric(vertical: 40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(ForgotPasswordModalStyle.borderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(40),
              blurRadius: ForgotPasswordModalStyle.shadowBlur,
              offset: Offset(0, ForgotPasswordModalStyle.shadowOffsetY),
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
          borderRadius:
              BorderRadius.circular(ForgotPasswordModalStyle.borderRadius),
          child: ForgotPasswordModalContent(
            onClose: () => Navigator.of(context).pop(),
          ),
        ),
      ),
    );
  }
}
