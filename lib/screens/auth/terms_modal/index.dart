import 'package:flutter/material.dart';
import 'package:orsocook/screens/auth/terms_modal/content.dart';
import 'package:orsocook/utils/device_classifier.dart';

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

    const double borderRadius = 24;
    const double cardWidth = 520;

    if (isMobile) {
      return Material(
        color: colorScheme.surface,
        child: SafeArea(
          child: Column(
            children: [
              AppBar(
                title: const Text('Termini e Condizioni'),
                backgroundColor: Colors.orange,
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
          child: Container(
            width: cardWidth,
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
              child: TermsModalContent(
                onClose: closeCallback,
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
