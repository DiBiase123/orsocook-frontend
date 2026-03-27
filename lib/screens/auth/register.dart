import 'dart:ui';
import 'package:flutter/material.dart';
import 'register_modal/index.dart';
import 'register_mobile.dart';

class RegisterDynamic extends StatelessWidget {
  const RegisterDynamic({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 1024;

    if (isMobile) {
      return const RegisterMobile();
    } else {
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
            const Center(
              child: RegisterModal(),
            ),
          ],
        ),
      );
    }
  }
}

Future<void> showRegisterModal(BuildContext context) {
  final isMobile = MediaQuery.of(context).size.width < 1024;

  if (isMobile) {
    return Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const RegisterMobile()),
    );
  } else {
    return showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.transparent,
      builder: (context) {
        return const RegisterDynamic();
      },
    );
  }
}
