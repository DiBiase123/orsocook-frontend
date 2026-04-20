import 'package:flutter/material.dart';
import 'package:orsocook/theme/app_theme.dart';
import 'package:orsocook/utils/responsive_utils.dart';

class AuthFormWrapper extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final List<Widget> children;
  final VoidCallback onClose;
  final bool showCloseButton;
  final String? title;
  final Color headerColor;

  const AuthFormWrapper({
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
    final colorScheme = Theme.of(context).colorScheme;
    final deviceType = DeviceClassifier.getDeviceType(context);

    // Valori responsivi
    final bool isDesktop = deviceType == DeviceType.desktop;
    final bool isTablet = deviceType == DeviceType.tablet;

    final double containerWidth =
        isDesktop ? 520 : (isTablet ? 500 : double.infinity);
    final double borderRadius = isDesktop ? 24 : (isTablet ? 20 : 0);
    final double shadowIntensity = isDesktop ? 30 : (isTablet ? 25 : 0);
    final bool needsScroll = isDesktop || isTablet;

    Widget content = Column(
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
                  icon: const Icon(Icons.close, size: 22, color: Colors.white),
                  onPressed: onClose,
                  tooltip: 'Chiudi',
                ),
              ],
            ),
          ),
        Flexible(
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: children,
              ),
            ),
          ),
        ),
      ],
    );

    // Desktop e Tablet: centrato con container
    if (needsScroll) {
      content = SingleChildScrollView(
        child: Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: containerWidth,
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(borderRadius),
                boxShadow: shadowIntensity > 0
                    ? [
                        BoxShadow(
                          color: Colors.black
                              .withAlpha((shadowIntensity * 0.85).toInt()),
                          blurRadius: shadowIntensity.toDouble(),
                          offset: Offset(0, shadowIntensity / 3),
                        ),
                      ]
                    : null,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(borderRadius),
                child: content,
              ),
            ),
          ),
        ),
      );
    }

    return content;
  }

}
