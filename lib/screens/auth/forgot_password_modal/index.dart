import 'package:flutter/material.dart';
import 'package:orsocook/screens/auth/forgot_password_modal/content.dart';
import 'package:orsocook/utils/device_classifier.dart';

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

    if (isMobile) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: onNavigateToLogin ?? closeCallback,
            tooltip: 'Torna al login',
          ),
          title: const Text('Password dimenticata'),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: closeCallback,
              tooltip: 'Chiudi',
            ),
          ],
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Center(
                  child: ForgotPasswordModalContent(
                    onClose: closeCallback,
                    showCloseButton: false,
                    onNavigateToLogin: onNavigateToLogin,
                  ),
                ),
              ),
            );
          },
        ),
      );
    }

    // Tablet e Desktop con freccia e X
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 40), // 👈 spazio sopra
            Material(
              color: Colors.transparent,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 520,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon:
                              const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: onNavigateToLogin ?? closeCallback,
                          tooltip: 'Torna al login',
                        ),
                        const Expanded(
                          child: Text(
                            'Password dimenticata',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: closeCallback,
                          tooltip: 'Chiudi',
                        ),
                      ],
                    ),
                  ),
                  ForgotPasswordModalContent(
                    onClose: closeCallback,
                    showCloseButton: false,
                    onNavigateToLogin: onNavigateToLogin,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40), // 👈 spazio sotto
          ],
        ),
      ),
    );
  }
}
