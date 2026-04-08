import 'package:flutter/material.dart';
import 'package:orsocook/utils/responsive_values.dart';

class AuthFormWrapperTablet extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final List<Widget> children;
  final VoidCallback onClose;
  final bool showCloseButton;
  final String? title;
  final Color headerColor;

  const AuthFormWrapperTablet({
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

    return Align(
      alignment: Alignment.topCenter,
      child: Material(
        color: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: ResponsiveValues.modalMaxWidth(context),
            constraints: BoxConstraints(
              maxHeight: screenHeight * 0.85,
            ),
            color: Colors.white,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (showCloseButton)
                  Container(
                    width: double.infinity,
                    color: headerColor,
                    padding: EdgeInsets.symmetric(
                      horizontal: ResponsiveValues.gapMedium(context),
                      vertical: ResponsiveValues.gapMedium(context),
                    ),
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
                Flexible(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding:
                        EdgeInsets.all(ResponsiveValues.gapMedium(context)),
                    child: Form(
                      key: formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: children,
                      ),
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
