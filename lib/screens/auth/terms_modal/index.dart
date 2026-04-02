import 'package:flutter/material.dart';
import 'package:orsocook/screens/auth/terms_modal/style.dart';
import 'package:orsocook/screens/auth/terms_modal/content.dart';

class TermsModal extends StatelessWidget {
  const TermsModal({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    if (isMobile) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Termini e Privacy'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
          backgroundColor: Colors.deepOrange,
          foregroundColor: Colors.white,
        ),
        body: TermsModalContent(
          onClose: () => Navigator.of(context).pop(),
        ),
      );
    }

    return Center(
      child: Container(
        width: TermsModalStyle.getCardWidth(context),
        height: TermsModalStyle.getCardHeight(context),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(TermsModalStyle.borderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(40),
              blurRadius: 40,
              offset: const Offset(0, 20),
            ),
            BoxShadow(
              color: Colors.deepOrange.withAlpha(30),
              blurRadius: 30,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(TermsModalStyle.borderRadius),
          child: TermsModalContent(
            onClose: () => Navigator.of(context).pop(),
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
    builder: (context) => const TermsModal(),
  );
}
