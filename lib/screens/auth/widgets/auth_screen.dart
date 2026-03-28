import 'package:flutter/material.dart';

class AuthScreen extends StatelessWidget {
  final String title;
  final Widget logo;
  final Widget formFields;
  final Widget actions;
  final VoidCallback? onBack;
  final VoidCallback? onClose;
  final bool showBackButton;
  final bool showCloseButton;

  const AuthScreen({
    super.key,
    required this.title,
    required this.logo,
    required this.formFields,
    required this.actions,
    this.onBack,
    this.onClose,
    this.showBackButton = true,
    this.showCloseButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 1024;

    if (isMobile) {
      return _buildMobileLayout(context);
    } else {
      return _buildDesktopLayout(context);
    }
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(title),
        leading: showBackButton
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: onBack ?? () => Navigator.of(context).pop(),
              )
            : null,
        actions: showCloseButton
            ? [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: onClose ?? () => Navigator.of(context).pop(),
                  tooltip: 'Chiudi',
                ),
              ]
            : null,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              logo,
              const SizedBox(height: 24),
              formFields,
              const SizedBox(height: 24),
              actions,
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    // Avvolgo in Material per fornire contesto ai TextFormField
    return Material(
      color: Colors.transparent,
      child: Center(
        child: Container(
          width: 520,
          constraints: const BoxConstraints(minWidth: 350, maxWidth: 600),
          margin: const EdgeInsets.symmetric(vertical: 40),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(40),
                blurRadius: 40,
                offset: const Offset(0, 20),
              ),
              BoxShadow(
                color: Colors.black.withAlpha(20),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
            border: Border.all(
              color: Colors.grey.withAlpha(50),
              width: 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (showCloseButton)
                    Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                        icon: const Icon(Icons.close, size: 32),
                        onPressed: onClose ?? () => Navigator.of(context).pop(),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.grey.withAlpha(50),
                          foregroundColor:
                              Theme.of(context).colorScheme.primary,
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(8),
                        ),
                      ),
                    ),
                  logo,
                  const SizedBox(height: 24),
                  formFields,
                  const SizedBox(height: 24),
                  actions,
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
