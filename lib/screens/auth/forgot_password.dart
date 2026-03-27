import 'dart:ui';
import 'package:flutter/material.dart';
import 'forgot_password_modal/index.dart';
import 'forgot_password_mobile.dart';

class ForgotPasswordDynamic extends StatelessWidget {
  const ForgotPasswordDynamic({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 1024;

    if (isMobile) {
      return const ForgotPasswordMobile();
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
              child: ForgotPasswordModal(),
            ),
          ],
        ),
      );
    }
  }
}

Future<void> showForgotPasswordModal(BuildContext context) {
  final isMobile = MediaQuery.of(context).size.width < 1024;

  if (isMobile) {
    return Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ForgotPasswordMobile()),
    );
  } else {
    return showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.transparent,
      builder: (context) {
        return const ForgotPasswordDynamic();
      },
    );
  }
}
