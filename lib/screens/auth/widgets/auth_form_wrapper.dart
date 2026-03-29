import 'package:flutter/material.dart';

class AuthFormWrapper extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final List<Widget> children;
  final VoidCallback onClose;
  final bool showCloseButton;

  const AuthFormWrapper({
    super.key,
    required this.formKey,
    required this.children,
    required this.onClose,
    this.showCloseButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (showCloseButton)
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: const Icon(Icons.close, size: 32),
                    onPressed: onClose,
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.grey.withAlpha(50),
                      foregroundColor: Theme.of(context).colorScheme.primary,
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(8),
                    ),
                  ),
                ),
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}
