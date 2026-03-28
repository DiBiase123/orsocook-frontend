import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:orsocook/screens/auth/register_modal/style.dart';
import 'package:orsocook/screens/auth/register_modal/content.dart';

class RegisterModal extends StatelessWidget {
  final VoidCallback? onNavigateToLogin;
  final VoidCallback? onClose;

  const RegisterModal({
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
          title: const Text('Registrazione'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: onNavigateToLogin ?? closeCallback,
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: closeCallback,
              tooltip: 'Chiudi',
            ),
          ],
        ),
        body: RegisterModalContent(
          onClose: closeCallback,
          showCloseButton: false,
          onNavigateToLogin: onNavigateToLogin,
        ),
      );
    }

    // Desktop: modal con effetto glass
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              color: Colors.black.withAlpha(60),
              width: double.infinity,
              height: double.infinity,
            ),
          ),
          Center(
            child: Container(
              width: RegisterModalStyle.cardWidth,
              constraints: RegisterModalStyle.constraints,
              margin: const EdgeInsets.symmetric(vertical: 40),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(RegisterModalStyle.borderRadius),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(40),
                    blurRadius: 40,
                    offset: const Offset(0, 20),
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
                    BorderRadius.circular(RegisterModalStyle.borderRadius),
                child: RegisterModalContent(
                  onClose: closeCallback,
                  showCloseButton: true,
                  onNavigateToLogin: onNavigateToLogin,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
