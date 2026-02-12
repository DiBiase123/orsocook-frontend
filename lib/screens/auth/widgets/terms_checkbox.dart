import 'package:flutter/material.dart';
import 'package:orsocook/utils/logger.dart';
import 'package:orsocook/screens/legal/privacy_policy_screen.dart';
import 'package:orsocook/screens/legal/cookie_policy_screen.dart';

class TermsCheckbox extends StatefulWidget {
  final bool value;
  final Function(bool) onChanged;
  final bool isLoading;

  const TermsCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    required this.isLoading,
  });

  @override
  State<TermsCheckbox> createState() => _TermsCheckboxState();
}

class _TermsCheckboxState extends State<TermsCheckbox> {
  void _showTermsDialog() {
    AppLogger.debug('📄 Apri termini e condizioni');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Termini, Condizioni e Privacy'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Benvenuto in OrsoCook!\n\n'
                '📋 **Termini di Utilizzo:**\n'
                '• Le ricette devono essere originali o debitamente attribuite\n'
                '• Non sono ammessi contenuti offensivi o illegali\n'
                '• Rispetta la privacy degli altri utenti\n'
                '• I contenuti pubblicati rimangono di proprietà degli autori\n'
                '• Ci riserviamo il diritto di rimuovere contenuti inappropriati\n\n',
                style: TextStyle(fontSize: 14),
              ),
              const Text(
                '🔐 **Trattamento Dati Personali (GDPR):**\n'
                'Per fornirti il servizio e garantire la sicurezza del tuo account, raccogliamo e trattiamo:\n'
                '• Email e username (obbligatori per la registrazione)\n'
                '• Indirizzo IP e dati dispositivo (per sicurezza e prevenzione frodi)\n'
                '• Ricette, commenti e preferenze (funzionalità dell\'app)\n\n',
                style: TextStyle(fontSize: 14),
              ),
              const Text(
                '⚖️ **Basi Giuridiche:**\n'
                '• Esecuzione contratto (fornitura servizio)\n'
                '• Legittimo interesse (sicurezza account)\n'
                '• Consenso (dove richiesto)\n\n',
                style: TextStyle(fontSize: 14),
              ),
              const Text(
                '👤 **I tuoi Diritti (GDPR):**\n'
                'Hai diritto a:\n'
                '• Accedere ai tuoi dati\n'
                '• Correggere dati inesatti\n'
                '• Cancellare il tuo account\n'
                '• Opporti al trattamento\n'
                '• Portabilità dei dati\n\n',
                style: TextStyle(fontSize: 14),
              ),
              const Text(
                '📚 **Documentazione Completa:**\n',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                  _openPrivacyPolicy(context);
                },
                child: const Text(
                  '📄 Leggi la Privacy Policy completa',
                  style: TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                  _openCookiePolicy(context);
                },
                child: const Text(
                  '🍪 Informativa Cookie',
                  style: TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('CHIUDI'),
          ),
        ],
      ),
    );
  }

  void _openPrivacyPolicy(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PrivacyPolicyScreen(),
      ),
    );
  }

  void _openCookiePolicy(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CookiePolicyScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          value: widget.value,
          onChanged: widget.isLoading
              ? null
              : (value) {
                  AppLogger.debug('📝 Termini accettati: $value');
                  widget.onChanged(value ?? false);
                },
        ),
        Expanded(
          child: GestureDetector(
            onTap: widget.isLoading ? null : _showTermsDialog,
            child: const Text(
              'Accetto i termini, condizioni e privacy',
              style: TextStyle(color: Colors.blue),
            ),
          ),
        ),
      ],
    );
  }
}
