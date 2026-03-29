import 'package:flutter/material.dart';
import 'package:orsocook/screens/auth/forgot_password_modal/index.dart';

Future<void> showForgotPasswordModal(BuildContext context) {
  return showDialog(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.transparent,
    builder: (context) => const ForgotPasswordModal(),
  );
}
