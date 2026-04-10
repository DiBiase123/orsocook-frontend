import 'package:flutter/material.dart';
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
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Login'),
          leading: IconButton(
            icon: const Icon(Icons.home),
            onPressed: closeCallback,
          ),
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Center(
                  child: LoginModalContent(
                    onClose: closeCallback,
                    showCloseButton: false,
                    onNavigateToRegister: onNavigateToRegister,
                    onNavigateToForgotPassword: onNavigateToForgotPassword,
                  ),
                ),
              ),
            );
          },
        ),
      );
    }

    // Tablet e Desktop
    return Center(
      child: Material(
        color: Colors.transparent,
        child: LoginModalContent(
          onClose: closeCallback,
          showCloseButton: true,
          onNavigateToRegister: onNavigateToRegister,
          onNavigateToForgotPassword: onNavigateToForgotPassword,
        ),
      ),
    );
  }
}
