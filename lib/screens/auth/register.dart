import 'package:flutter/material.dart';
import 'package:orsocook/screens/auth/register_modal/index.dart';

Future<void> showRegisterModal(BuildContext context) {
  return showDialog(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.transparent,
    builder: (context) => const RegisterModal(),
  );
}
