import 'package:flutter/material.dart';
import 'package:orsocook/screens/auth/login_modal/style.dart';
import 'package:orsocook/screens/auth/login_modal/content.dart';

class LoginModal extends StatelessWidget {
  const LoginModal({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    if (isMobile) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Login'),
          leading: IconButton(
            icon: const Icon(Icons.home),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: LoginModalContent(
          onClose: () => Navigator.of(context).pop(),
          showCloseButton: false,
        ),
      );
    }

    return Center(
      child: Container(
        width: LoginModalStyle.cardWidth,
        constraints: LoginModalStyle.constraints,
        margin: const EdgeInsets.symmetric(vertical: 40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(LoginModalStyle.borderRadius),
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
          borderRadius: BorderRadius.circular(LoginModalStyle.borderRadius),
          child: LoginModalContent(
            onClose: () => Navigator.of(context).pop(),
            showCloseButton: true,
          ),
        ),
      ),
    );
  }
}
