import 'package:flutter/material.dart';
import 'package:orsocook/utils/app_theme.dart';
import 'package:orsocook/utils/responsive_breakpoints.dart';

class AuthFormWrapper extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final List<Widget> children;
  final VoidCallback onClose;
  final bool showCloseButton;
  final String? title;

  const AuthFormWrapper({
    super.key,
    required this.formKey,
    required this.onClose,
    required this.children,
    this.showCloseButton = true,
    this.title,
  });

  Color _getHeaderColor() {
    if (title == 'Accedi') {
      return AppColors.primary;
    }
    if (title == 'Registrati') {
      return Colors.deepOrange.shade200;
    }
    return Colors.deepOrange;
  }

  @override
  Widget build(BuildContext context) {
    final headerColor = _getHeaderColor();
    final screenHeight = MediaQuery.of(context).size.height;
    final isDesktop = ResponsiveBreakpoints.isDesktop(context);
    final isTablet = ResponsiveBreakpoints.isTablet(context);

    // Larghezza dinamica
    double modalWidth;
    if (isDesktop) {
      modalWidth = 550;
    } else if (isTablet) {
      modalWidth = 500;
    } else {
      modalWidth = MediaQuery.of(context).size.width * 0.95;
    }

    // Padding dinamico
    final horizontalPadding = isDesktop ? 32.0 : (isTablet ? 24.0 : 16.0);
    final verticalPadding = isDesktop ? 32.0 : (isTablet ? 24.0 : 16.0);
    final titleFontSize = isDesktop ? 24.0 : (isTablet ? 22.0 : 20.0);

    return Align(
      alignment: Alignment.topCenter,
      child: Material(
        color: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: modalWidth,
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
                      horizontal: horizontalPadding,
                      vertical: 12,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (title != null)
                          Text(
                            title!,
                            style: TextStyle(
                              fontSize: titleFontSize,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
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
                    padding: EdgeInsets.all(verticalPadding),
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
