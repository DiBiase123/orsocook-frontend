import 'package:flutter/material.dart';
import 'package:orsocook/screens/legal/privacy_policy_screen.dart';
import 'package:orsocook/screens/legal/cookie_policy_screen.dart';

class TermsModalContent extends StatelessWidget {
  final VoidCallback onClose;

  const TermsModalContent({super.key, required this.onClose});

  void _openPrivacyPolicy(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
    );
  }

  void _openCookiePolicy(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const CookiePolicyScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con gradiente
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.deepOrange.shade400,
                  Colors.deepOrange.shade700,
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Text(
                '📜 Termini & Privacy',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Sezione Termini
          _buildSection(
            icon: Icons.description,
            title: 'Termini di Utilizzo',
            color: Colors.deepOrange,
            content: '''
• Le ricette devono essere originali o debitamente attribuite
• Non sono ammessi contenuti offensivi o illegali
• Rispetta la privacy degli altri utenti
• I contenuti pubblicati rimangono di proprietà degli autori
• Ci riserviamo il diritto di rimuovere contenuti inappropriati''',
          ),
          const SizedBox(height: 20),
          // Sezione GDPR
          _buildSection(
            icon: Icons.security,
            title: 'Trattamento Dati (GDPR)',
            color: Colors.blue,
            content: '''
Per fornirti il servizio e garantire la sicurezza del tuo account, raccogliamo e trattiamo:
• Email e username (obbligatori per la registrazione)
• Indirizzo IP e dati dispositivo (per sicurezza)
• Ricette, commenti e preferenze''',
          ),
          const SizedBox(height: 20),
          // Sezione Diritti
          _buildSection(
            icon: Icons.gavel,
            title: 'I tuoi Diritti (GDPR)',
            color: Colors.green,
            content: '''
Hai diritto a:
• Accedere ai tuoi dati
• Correggere dati inesatti
• Cancellare il tuo account
• Opporti al trattamento
• Portabilità dei dati''',
          ),
          const SizedBox(height: 20),
          // Documentazione
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.book, color: Colors.deepOrange.shade600),
                    const SizedBox(width: 8),
                    const Text(
                      'Documentazione Completa',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () => _openPrivacyPolicy(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        children: [
                          Icon(Icons.privacy_tip, color: Colors.blue.shade600),
                          const SizedBox(width: 8),
                          const Text(
                            '📄 Privacy Policy completa',
                            style: TextStyle(
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () => _openCookiePolicy(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        children: [
                          Icon(Icons.cookie, color: Colors.brown.shade600),
                          const SizedBox(width: 8),
                          const Text(
                            '🍪 Informativa Cookie',
                            style: TextStyle(
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          // Bottone chiudi
          Center(
            child: ElevatedButton(
              onPressed: onClose,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 2,
              ),
              child: const Text(
                'CHIUDI',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    required Color color,
    required String content,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(51)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: const TextStyle(fontSize: 14, height: 1.4),
          ),
        ],
      ),
    );
  }
}
