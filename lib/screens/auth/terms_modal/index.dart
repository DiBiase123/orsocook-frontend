import 'package:flutter/material.dart';
import 'package:orsocook/screens/auth/terms_modal/content.dart';
import 'package:orsocook/utils/device_classifier.dart';
import 'package:orsocook/theme/theme_common.dart';

class TermsModal extends StatelessWidget {
  final VoidCallback? onClose;

  const TermsModal({
    super.key,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = DeviceClassifier.isMobile(context);
    final closeCallback = onClose ?? () => Navigator.of(context).pop();
    final colorScheme = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDarkMode = colorScheme.brightness == Brightness.dark;

    // Colori informativi dal tema
    final accentColor = ThemeCommon.informativeAccent(colorScheme);
    // Colore header: in dark mode usa blu notte per leggibilità
    final headerBg = isDarkMode ? const Color(0xFF0C4A6E) : accentColor;

    const double borderRadius = 24;

    if (isMobile) {
      return Material(
        color: colorScheme.surface,
        child: SafeArea(
          child: Column(
            children: [
              AppBar(
                title: const Text('Termini e Condizioni'),
                backgroundColor: headerBg,
                foregroundColor: Colors.white,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: closeCallback,
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
                  child: TermsModalContent(
                    onClose: closeCallback,
                    showCloseButton: false,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Tablet e Desktop - con header personalizzato
    final cardWidth = screenWidth * 0.75;

    return SingleChildScrollView(
      child: Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: cardWidth,
            margin: const EdgeInsets.symmetric(vertical: 40),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(borderRadius),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(30),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(borderRadius),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header azzurro (o blu notte in dark) con icona, titolo e pulsante X
                  Container(
                    width: double.infinity,
                    color: headerBg,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.description,
                          color: Colors.white,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Termini & Privacy',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: closeCallback,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ),
                  // Contenuto
                  TermsModalContent(
                    onClose: closeCallback,
                    showCloseButton: false,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> showTermsModal(BuildContext context) {
  return showDialog(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.transparent,
    builder: (context) => TermsModal(
      onClose: () => Navigator.of(context).pop(),
    ),
  );
}
