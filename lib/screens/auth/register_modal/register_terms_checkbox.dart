import 'package:flutter/material.dart';
import 'package:orsocook/utils/logger.dart';
import 'package:orsocook/screens/auth/terms_modal/index.dart';

class TermsCheckbox extends StatefulWidget {
  final bool value;
  final Function(bool) onChanged;
  final bool isLoading;
  final VoidCallback? onTermsModalClosed; // Nuovo callback

  const TermsCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    required this.isLoading,
    this.onTermsModalClosed,
  });

  @override
  State<TermsCheckbox> createState() => _TermsCheckboxState();
}

class _TermsCheckboxState extends State<TermsCheckbox> {
  void _showTermsModal() {
    AppLogger.debug('📄 Apri termini e condizioni');
    showTermsModal(context).then((_) {
      // Quando il modale viene chiuso, chiama il callback
      widget.onTermsModalClosed?.call();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Transform.translate(
          offset: const Offset(-8, 0),
          child: Checkbox(
            value: widget.value,
            onChanged: widget.isLoading
                ? null
                : (value) {
                    AppLogger.debug('📝 Termini accettati: $value');
                    widget.onChanged(value ?? false);
                  },
          ),
        ),
        Expanded(
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: widget.isLoading ? null : _showTermsModal,
              child: const Text(
                'Accetto i termini, condizioni e privacy',
                style: TextStyle(color: Colors.blue),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
