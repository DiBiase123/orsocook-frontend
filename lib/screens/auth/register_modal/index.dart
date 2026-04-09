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
        body: Center(
          child: SingleChildScrollView(
            child: RegisterModalContent(
              onClose: closeCallback,
              showCloseButton: false,
              onNavigateToLogin: onNavigateToLogin,
            ),
          ),
        ),
      );
    }

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
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxHeight: double.infinity,
              ),
              child: Container(
                width: RegisterModalStyle.cardWidth,
                constraints: RegisterModalStyle.constraints,
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
