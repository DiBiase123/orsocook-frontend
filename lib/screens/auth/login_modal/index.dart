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
    final shortestSide = mediaQuery.size.shortestSide;
    final isMobile = shortestSide < 600;

    final closeCallback = onClose ?? () => Navigator.of(context).pop();

    if (isMobile) {
      final screenHeight = MediaQuery.of(context).size.height;
      final appBarHeight = kToolbarHeight;
      final topPadding = MediaQuery.of(context).padding.top;
      final availableHeight = screenHeight - appBarHeight - topPadding;

      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Login'),
          leading: IconButton(
            icon: const Icon(Icons.home),
            onPressed: closeCallback,
          ),
        ),
        body: SingleChildScrollView(
          child: SizedBox(
            height: availableHeight,
            child: Center(
              child: LoginModalContent(
                onClose: closeCallback,
                showCloseButton: false,
                onNavigateToRegister: onNavigateToRegister,
                onNavigateToForgotPassword: onNavigateToForgotPassword,
              ),
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
