import 'package:flutter/material.dart';
import 'package:orsocook/screens/legal/cookie_policy.dart';
import 'package:orsocook/utils/responsive_values.dart';

class TermsModalContent extends StatelessWidget {
  final VoidCallback onClose;
  final bool showCloseButton;

  const TermsModalContent({
    super.key,
    required this.onClose,
    this.showCloseButton = true,
  });

  void _openPrivacyPolicy(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const CookiePolicyScreen()),
    );
  }

  void _openCookiePolicy(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const CookiePolicyScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDarkMode = colorScheme.brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: ResponsiveValues.screenPadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
            context: context,
          ),
          SizedBox(height: ResponsiveValues.gapLarge(context)),
          _buildSection(
            icon: Icons.security,
            title: 'Trattamento Dati (GDPR)',
            color: Colors.blue,
            content: '''
Per fornirti il servizio e garantire la sicurezza del tuo account, raccogliamo e trattiamo:
• Email e username (obbligatori per la registrazione)
• Indirizzo IP e dati dispositivo (per sicurezza)
• Ricette, commenti e preferenze''',
            context: context,
          ),
          SizedBox(height: ResponsiveValues.gapLarge(context)),
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
            context: context,
          ),
          SizedBox(height: ResponsiveValues.gapLarge(context)),
          Container(
            padding: ResponsiveValues.screenPadding(context),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade200,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.book, color: Colors.deepOrange.shade600),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Documentazione Completa',
                        style: TextStyle(
                          fontSize: ResponsiveValues.titleSize(context),
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: ResponsiveValues.gapMedium(context)),
                GestureDetector(
                  onTap: () => _openPrivacyPolicy(context),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Icon(Icons.privacy_tip,
                            color: Colors.blue.shade600, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Privacy Policy completa',
                            style: TextStyle(
                              fontSize: ResponsiveValues.bodySize(context),
                              color: Colors.blue.shade600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => _openCookiePolicy(context),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Icon(Icons.cookie,
                            color: Colors.brown.shade600, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Informativa Cookie',
                            style: TextStyle(
                              fontSize: ResponsiveValues.bodySize(context),
                              color: Colors.blue.shade600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: ResponsiveValues.gapExtraLarge(context)),
          if (showCloseButton)
            Center(
              child: ElevatedButton(
                onPressed: onClose,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveValues.gapExtraLarge(context),
                    vertical: ResponsiveValues.gapMedium(context),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 2,
                  minimumSize:
                      Size(120, ResponsiveValues.buttonHeight(context)),
                ),
                child: Text(
                  'CHIUDI',
                  style: TextStyle(
                    fontSize: ResponsiveValues.bodySize(context),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          SizedBox(height: ResponsiveValues.gapMedium(context)),
        ],
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    required Color color,
    required String content,
    required BuildContext context,
  }) {
    final isDarkMode =
        Theme.of(context).colorScheme.brightness == Brightness.dark;

    return Container(
      padding: ResponsiveValues.screenPadding(context),
      decoration: BoxDecoration(
        color: color.withAlpha(isDarkMode ? 30 : 26),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(isDarkMode ? 60 : 51)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: ResponsiveValues.titleSize(context),
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveValues.gapMedium(context)),
          Text(
            content,
            style: TextStyle(
              fontSize: ResponsiveValues.bodySize(context),
              height: 1.4,
              color: isDarkMode ? Colors.white70 : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
