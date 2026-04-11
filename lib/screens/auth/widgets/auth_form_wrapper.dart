import 'package:flutter/material.dart';
import 'package:orsocook/utils/device_classifier.dart';
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
    final colorScheme = Theme.of(context).colorScheme;

    if (title == 'Accedi') {
      return colorScheme.primary;
    }
    if (title == 'Registrati') {
      return colorScheme.tertiary;
    }
    return colorScheme.error;
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
