import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:orsocook/screens/auth/login_modal/index.dart';
import 'package:orsocook/screens/auth/register_modal/index.dart';
import 'package:orsocook/screens/auth/forgot_password_modal/index.dart';

class AuthDialog extends StatefulWidget {
  const AuthDialog({super.key});

  @override
  State<AuthDialog> createState() => _AuthDialogState();
}

class _AuthDialogState extends State<AuthDialog> {
  late Widget _currentScreen;

  @override
  void initState() {
    super.initState();
    _currentScreen = LoginModal(
      onNavigateToRegister: () => _navigateToRegister(),
      onNavigateToForgotPassword: () => _navigateToForgotPassword(),
      onClose: () => _closeDialog(),
    );
  }

  void _navigateToRegister() {
    setState(() {
      _currentScreen = RegisterModal(
        onNavigateToLogin: () => _navigateToLogin(),
        onClose: () => _closeDialog(),
      );
    });
  }

  void _navigateToForgotPassword() {
    setState(() {
      _currentScreen = ForgotPasswordModal(
        onNavigateToLogin: () => _navigateToLogin(),
        onClose: () => _closeDialog(),
      );
    });
  }

  void _navigateToLogin() {
    setState(() {
      _currentScreen = LoginModal(
        onNavigateToRegister: () => _navigateToRegister(),
        onNavigateToForgotPassword: () => _navigateToForgotPassword(),
        onClose: () => _closeDialog(),
      );
    });
  }

  void _closeDialog() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Scegli il colore dello sfondo in base al tema
    final backgroundColor = isDarkMode
        ? Colors.black.withAlpha(230) // Discord style: quasi nero solido
        : Colors.black.withAlpha(60); // Light mode: trasparente come prima

    return Stack(
      children: [
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            color: backgroundColor,
            width: double.infinity,
            height: double.infinity,
          ),
        ),
        if (isMobile)
          Center(
            child: _currentScreen,
          )
        else
          Center(
            child: SingleChildScrollView(
              child: _currentScreen,
            ),
          ),
      ],
    );
  }
}

Future<void> showLoginModal(BuildContext context) {
  return showDialog(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.transparent,
    useSafeArea: false,
    builder: (context) => const AuthDialog(),
  );
}
