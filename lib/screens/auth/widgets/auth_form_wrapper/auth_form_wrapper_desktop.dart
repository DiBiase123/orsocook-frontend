import 'package:flutter/material.dart';
import 'package:orsocook/utils/responsive_values.dart';
import 'package:orsocook/screens/auth/widgets/auth_compact_values.dart';

class AuthFormWrapperDesktop extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final List<Widget> children;
  final VoidCallback onClose;
  final bool showCloseButton;
  final String? title;
  final Color headerColor;

  const AuthFormWrapperDesktop({
    super.key,
    required this.formKey,
    required this.children,
    required this.onClose,
    this.showCloseButton = true,
    this.title,
    required this.headerColor,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Material(
        color: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: ResponsiveValues.modalMaxWidth(context),
            color: Colors.white,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (showCloseButton)
                  Container(
                    width: double.infinity,
                    color: headerColor,
                    padding: AuthCompactValues.headerPadding(context),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (title != null)
                          Expanded(
                            child: Text(
                              title!,
                              style: TextStyle(
                                fontSize: ResponsiveValues.titleSize(context),
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          )
                        else
                          const SizedBox.shrink(),
                        IconButton(
                          icon: const Icon(Icons.close,
                              size: 24, color: Colors.white),
                          onPressed: onClose,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ),
                Padding(
                  padding: AuthCompactValues.formPadding(context),
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: children,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
