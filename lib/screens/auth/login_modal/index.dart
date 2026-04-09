import 'package:flutter/material.dart';
import 'package:orsocook/screens/auth/login_modal/style.dart';
import 'package:orsocook/screens/auth/login_modal/content.dart';
import 'package:orsocook/utils/device_classifier.dart';

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
    final isMobile = DeviceClassifier.isMobile(context);
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
        body: SizedBox(
          height: availableHeight,
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
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: LoginModalStyle.cardWidth,
          constraints: LoginModalStyle.constraints,
          margin: const EdgeInsets.symmetric(vertical: 40),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(30),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Material(
              color: Colors.white,
              child: LoginModalContent(
                onClose: closeCallback,
                showCloseButton: true,
                onNavigateToRegister: onNavigateToRegister,
                onNavigateToForgotPassword: onNavigateToForgotPassword,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
