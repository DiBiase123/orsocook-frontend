import 'package:flutter/material.dart';
import 'package:orsocook/screens/auth/register_modal/content.dart';
import 'package:orsocook/utils/responsive_utils.dart';
import 'package:orsocook/theme/app_theme.dart';
import 'package:orsocook/theme/theme_common.dart';

class RegisterModal extends StatefulWidget {
  final VoidCallback? onNavigateToLogin;
  final VoidCallback? onClose;

  const RegisterModal({
    super.key,
    this.onNavigateToLogin,
    this.onClose,
  });

  @override
  State<RegisterModal> createState() => _RegisterModalState();
}

class _RegisterModalState extends State<RegisterModal> {
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
                title: Text('Registrazione',
                    style: ThemeCommon.appBarTitleStyle(context)),
                backgroundColor: DarkTheme.registerColor,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: widget.onNavigateToLogin ?? closeCallback,
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
                  controller: _scrollController,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    constraints: BoxConstraints(
                      minHeight: screenHeight - 100,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        RegisterModalContent(
                          onClose: closeCallback,
                          showCloseButton: false,
                          onNavigateToLogin: widget.onNavigateToLogin,
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
          child: RegisterModalContent(
            onClose: closeCallback,
            showCloseButton: true,
            onNavigateToLogin: widget.onNavigateToLogin,
          ),
        ),
      ),
    );
  }
}
