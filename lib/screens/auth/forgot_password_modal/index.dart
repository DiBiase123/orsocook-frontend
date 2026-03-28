import 'package:flutter/material.dart';
import 'package:orsocook/screens/auth/forgot_password_modal/style.dart';
import 'package:orsocook/screens/auth/forgot_password_modal/content.dart';

class ForgotPasswordModal extends StatelessWidget {
  final VoidCallback? onNavigateToLogin;
  final VoidCallback? onClose;

  const ForgotPasswordModal({
    super.key,
    this.onNavigateToLogin,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    final closeCallback = onClose ?? () => Navigator.of(context).pop();

    if (isMobile) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Password Dimenticata'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: onNavigateToLogin ?? closeCallback,
          ),
        ),
        body: ForgotPasswordModalContent(
          onClose: closeCallback,
          showCloseButton: false,
          onNavigateToLogin: onNavigateToLogin,
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
            onClose: closeCallback,
            showCloseButton: true,
            onNavigateToLogin: onNavigateToLogin,
          ),
        ),
      ),
    );
  }
}
