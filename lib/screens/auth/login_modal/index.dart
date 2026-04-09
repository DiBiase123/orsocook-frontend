import 'package:flutter/material.dart';
import 'package:orsocook/screens/auth/login_modal/style.dart';
import 'package:orsocook/screens/auth/login_modal/content.dart';

class LoginModal extends StatelessWidget {
  final VoidCallback? onNavigateToRegister;
  final VoidCallback? onNavigateToForgotPassword;
  final VoidCallback? onClose;

  const LoginModal({
    super.key,
    this.onNavigateToRegister,
    this.onNavigateToForgotPassword,
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
          title: const Text('Login'),
          leading: IconButton(
            icon: const Icon(Icons.home),
            onPressed: closeCallback,
          ),
        ),
        body: Center(
          child: SingleChildScrollView(
            child: LoginModalContent(
              onClose: closeCallback,
              showCloseButton: false,
              onNavigateToRegister: onNavigateToRegister,
              onNavigateToForgotPassword: onNavigateToForgotPassword,
            ),
          ),
        ),
      );
    }

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxHeight: double.infinity,
        ),
        child: Container(
          width: LoginModalStyle.cardWidth,
          constraints: LoginModalStyle.constraints,
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
          child: LoginModalContent(
            onClose: closeCallback,
            showCloseButton: true,
            onNavigateToRegister: onNavigateToRegister,
            onNavigateToForgotPassword: onNavigateToForgotPassword,
          ),
        ),
      ),
    );
  }
}
