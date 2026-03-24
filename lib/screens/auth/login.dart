import 'dart:ui';
import 'package:flutter/material.dart';
import 'login_modal/index.dart';

Future<void> showLoginModal(BuildContext context) {
  return showDialog(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.transparent,
    builder: (context) {
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
              child: LoginModal(),
            ),
          ],
        ),
      );
    },
  );
}
