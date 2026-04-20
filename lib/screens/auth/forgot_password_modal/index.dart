import 'package:flutter/material.dart';
import 'package:orsocook/screens/auth/forgot_password_modal/content.dart';
import 'package:orsocook/utils/responsive_utils.dart';
import 'package:orsocook/theme/theme_common.dart';

class ForgotPasswordModal extends StatelessWidget {
  final VoidCallback? onNavigateToLogin;
  final VoidCallback? onClose;

  const ForgotPasswordModal({
    super.key,
    this.onNavigateToLogin,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = DeviceClassifier.isMobile(context);
    final closeCallback = onClose ?? () => Navigator.of(context).pop();
    final screenHeight = MediaQuery.of(context).size.height;
    final colorScheme = Theme.of(context).colorScheme;

    if (isMobile) {
      return Material(
        color: colorScheme.surface,
        child: SafeArea(
          child: Column(
            children: [
              AppBar(
                title: Text('Password dimenticata',
                    style: ThemeCommon.appBarTitleStyle(context)),
                backgroundColor: Colors.orange,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: onNavigateToLogin ?? closeCallback,
                  tooltip: 'Torna al login',
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: closeCallback,
                    tooltip: 'Chiudi',
                  ),
                ],
                automaticallyImplyLeading: true,
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    constraints: BoxConstraints(
                      minHeight: screenHeight - 100,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ForgotPasswordModalContent(
                          onClose: closeCallback,
                          showCloseButton: false,
                          onNavigateToLogin: onNavigateToLogin,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Tablet e Desktop
    return Center(
      child: Material(
        color: Colors.transparent,
        child: ForgotPasswordModalContent(
          onClose: closeCallback,
          showCloseButton: true,
          onNavigateToLogin: onNavigateToLogin,
        ),
      ),
    );
  }
}
