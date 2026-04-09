import 'package:flutter/material.dart';

class AuthFormWrapperMobile extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final List<Widget> children;
  final VoidCallback onClose;
  final bool showCloseButton;
  final String? title;
  final Color headerColor;

  const AuthFormWrapperMobile({
    super.key,
    required this.formKey,
    required this.children,
    required this.onClose,
    required this.showCloseButton,
    this.title,
    required this.headerColor,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    // Padding superiore proporzionale all'altezza (es. 5% ma min 8, max 24)
    final topPadding = (screenHeight * 0.05).clamp(8.0, 24.0);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showCloseButton)
            Container(
              width: double.infinity,
              color: headerColor,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (title != null)
                    Expanded(
                      child: Text(
                        title!,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    )
                  else
                    const SizedBox.shrink(),
                  IconButton(
                    icon:
                        const Icon(Icons.close, size: 24, color: Colors.white),
                    onPressed: onClose,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            width: double.infinity,
            color: Colors.white,
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              bottom: 24,
              top: topPadding, // 👈 padding proporzionale
            ),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: children,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
