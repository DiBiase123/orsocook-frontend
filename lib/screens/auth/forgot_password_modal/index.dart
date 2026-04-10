import 'package:flutter/material.dart';
import 'package:orsocook/screens/auth/forgot_password_modal/style.dart';
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
        body: Center(
          child: SingleChildScrollView(
            child: ForgotPasswordModalContent(
              onClose: closeCallback,
              showCloseButton: false,
              onNavigateToLogin: onNavigateToLogin,
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
      ),
    );
  }
}
