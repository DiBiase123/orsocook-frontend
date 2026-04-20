import 'package:flutter/material.dart';

class AuthUtils {
  static Future<void> submitWithFormGuard({
    required GlobalKey<FormState> formKey,
    required bool mounted,
    required Future<void> Function() onSubmit,
  }) async {
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted) return;

    if (formKey.currentState == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (formKey.currentState == null) {
          Future.delayed(
            const Duration(milliseconds: 100),
            () {
              if (mounted) onSubmit();
            },
          );
        } else {
          onSubmit();
        }
      });
      return;
    }

    if (!formKey.currentState!.validate()) return;
    await onSubmit();
  }

  static void showAuthSnackBar(
    BuildContext context, {
    required String message,
    Color color = Colors.red,
  }) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  static void navigateOrClose(
    VoidCallback? navigate,
    VoidCallback onClose,
  ) {
    navigate != null ? navigate() : onClose();
  }
}
