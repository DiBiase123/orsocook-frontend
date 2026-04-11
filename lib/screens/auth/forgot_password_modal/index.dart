import 'package:flutter/material.dart';
import 'package:orsocook/screens/auth/forgot_password_modal/content.dart';
import 'package:orsocook/utils/device_classifier.dart';

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
    final isMobile = DeviceClassifier.isMobile(context);
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
        body: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Center(
                  child: ForgotPasswordModalContent(
                    onClose: closeCallback,
                    showCloseButton: false,
                    onNavigateToLogin: onNavigateToLogin,
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
        child: ForgotPasswordModalContent(
          onClose: closeCallback,
          showCloseButton: true,
          onNavigateToLogin: onNavigateToLogin,
        ),
      ),
    );
  }
}
