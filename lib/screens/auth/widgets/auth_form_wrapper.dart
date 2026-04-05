import 'package:flutter/material.dart';
import 'package:orsocook/utils/app_theme.dart';
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

  Color _getHeaderColor() {
    if (title == 'Accedi') {
      return AppColors.primary; // viola
    }
    if (title == 'Registrati') {
      return Colors.deepOrange.shade200; // arancione chiaro
    }
    return Colors.deepOrange; // fallback
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final headerColor = _getHeaderColor();

    if (screenWidth >= 900) {
      return AuthFormWrapperDesktop(
        formKey: formKey,
        onClose: onClose,
        showCloseButton: showCloseButton,
        title: title,
        headerColor: headerColor,
        children: children,
      );
    } else if (screenWidth >= 600) {
      return AuthFormWrapperTablet(
        formKey: formKey,
        onClose: onClose,
        showCloseButton: showCloseButton,
        title: title,
        headerColor: headerColor,
        children: children,
      );
    } else {
      return AuthFormWrapperMobile(
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
