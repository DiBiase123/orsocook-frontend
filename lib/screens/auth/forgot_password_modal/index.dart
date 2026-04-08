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
    final mediaQuery = MediaQuery.of(context);
    final orientation = mediaQuery.orientation;
    final shortestSide = mediaQuery.size.shortestSide;
    final isLandscapeMobile =
        orientation == Orientation.landscape && shortestSide < 600;
    final isMobile = mediaQuery.size.width < 768 || isLandscapeMobile;

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
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(30),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ForgotPasswordModalContent(
          onClose: closeCallback,
          showCloseButton: true,
          onNavigateToLogin: onNavigateToLogin,
        ),
      ),
    );
  }
}
