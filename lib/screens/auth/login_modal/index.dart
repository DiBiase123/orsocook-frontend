import 'package:flutter/material.dart';
import 'package:orsocook/screens/auth/login_modal/content.dart';
import 'package:orsocook/utils/device_classifier.dart';

class LoginModal extends StatefulWidget {
  final VoidCallback? onNavigateToRegister;
  final VoidCallback? onNavigateToForgotPassword;
  final VoidCallback? onClose;

  const LoginModal({
    super.key,
    this.onNavigateToRegister,
    this.onNavigateToForgotPassword,
    this.onClose,
  });

  @override
  State<LoginModal> createState() => _LoginModalState();
}

class _LoginModalState extends State<LoginModal> {
  final ScrollController _scrollController = ScrollController();

  void resetScroll() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = DeviceClassifier.isMobile(context);
    final closeCallback = widget.onClose ?? () => Navigator.of(context).pop();
    final screenHeight = MediaQuery.of(context).size.height;
    final colorScheme = Theme.of(context).colorScheme;

    if (isMobile) {
      return Material(
        color: colorScheme.surface,
        child: SafeArea(
          child: Column(
            children: [
              AppBar(
                title: const Text('Login'),
                backgroundColor: colorScheme.primary,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: closeCallback,
                ),
                automaticallyImplyLeading: true,
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    constraints: BoxConstraints(
                      minHeight: screenHeight - 100,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        LoginModalContent(
                          onClose: closeCallback,
                          showCloseButton: false,
                          onNavigateToRegister: widget.onNavigateToRegister,
                          onNavigateToForgotPassword:
                              widget.onNavigateToForgotPassword,
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
        child: SingleChildScrollView(
          controller: _scrollController,
          child: LoginModalContent(
            onClose: closeCallback,
            showCloseButton: true,
            onNavigateToRegister: widget.onNavigateToRegister,
            onNavigateToForgotPassword: widget.onNavigateToForgotPassword,
          ),
        ),
      ),
    );
  }
}
