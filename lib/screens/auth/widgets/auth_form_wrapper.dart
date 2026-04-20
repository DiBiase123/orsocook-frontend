import 'package:flutter/material.dart';
import 'package:orsocook/theme/app_theme.dart';
import 'package:orsocook/utils/responsive_utils.dart';
import 'package:orsocook/screens/auth/widgets/auth_form_wrapper/auth_form_wrapper_desktop.dart';
import 'package:orsocook/screens/auth/widgets/auth_form_wrapper/auth_form_wrapper_tablet.dart';
import 'package:orsocook/screens/auth/widgets/auth_form_wrapper/auth_form_wrapper_mobile.dart';

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

  Color _getHeaderColor(BuildContext context) {
    if (title == 'Accedi') {
      return Theme.of(context).colorScheme.primary;
    }
    if (title == 'Registrati') {
      return DarkTheme.registerColor;
    }
    if (title == 'Password dimenticata') {
      return Colors.orange; // 👈 aggiungi questo
    }
    return Colors.deepOrange;
  }

  @override
  Widget build(BuildContext context) {
    final headerColor = _getHeaderColor(context);
    final deviceType = DeviceClassifier.getDeviceType(context);

    switch (deviceType) {
      case DeviceType.mobile:
        return AuthFormWrapperMobile(
          formKey: formKey,
          onClose: onClose,
          showCloseButton: showCloseButton,
          title: title,
          headerColor: headerColor,
          children: children,
        );
      case DeviceType.tablet:
        return AuthFormWrapperTablet(
          formKey: formKey,
          onClose: onClose,
          showCloseButton: showCloseButton,
          title: title,
          headerColor: headerColor,
          children: children,
        );
      case DeviceType.desktop:
        return AuthFormWrapperDesktop(
          formKey: formKey,
          onClose: onClose,
          showCloseButton: showCloseButton,
          title: title,
          headerColor: headerColor,
          children: children,
        );
    }
  }
}
