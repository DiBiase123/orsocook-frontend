import 'package:flutter/material.dart';
import 'package:orsocook/screens/auth/login.dart';
import 'package:orsocook/screens/auth/forgot_password_modal/style.dart';
import 'package:orsocook/screens/auth/forgot_password_modal/content.dart';

class ForgotPasswordModal extends StatelessWidget {
  const ForgotPasswordModal({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    if (isMobile) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Password Dimenticata'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
              showLoginModal(context);
            },
          ),
        ),
        body: ForgotPasswordModalContent(
          onClose: () => Navigator.of(context).pop(),
          showCloseButton: false,
        ),
      );
    }

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
            ),
            BoxShadow(
              color: Colors.black.withAlpha(20),
              blurRadius: 20,
              offset: const Offset(0, 8),
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
            showCloseButton: true,
          ),
        ),
      ),
    );
  }
}
