import 'package:orsocook/theme/common_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:orsocook/utils/logger.dart';
import 'package:orsocook/utils/responsive_utils.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  Color _getSectionColor(int index, ColorScheme colorScheme, bool isDarkMode) {
    final List<Color> lightColors = [
      const Color(0xFF0284C7),
      const Color(0xFF0D9488),
      const Color(0xFF059669),
      const Color(0xFF7C3AED),
      const Color(0xFFEA580C),
      const Color(0xFFDB2777),
      const Color(0xFF4F46E5),
      const Color(0xFF0891B2),
      const Color(0xFFD946EF),
      const Color(0xFF16A34A),
    ];

    final List<Color> darkColors = [
      const Color(0xFF7DD3FC),
      const Color(0xFF5EEAD4),
      const Color(0xFF86EFAC),
      const Color(0xFFC4B5FD),
      const Color(0xFFFDBA74),
      const Color(0xFFF9A8D4),
      const Color(0xFFA5B4FC),
      const Color(0xFF67E8F9),
      const Color(0xFFF0ABFC),
      const Color(0xFFBBF7D0),
    ];

    return isDarkMode
        ? darkColors[index % darkColors.length]
        : lightColors[index % lightColors.length];
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDarkMode = colorScheme.brightness == Brightness.dark;
    final accentColor = ThemeCommon.informativeAccent(colorScheme);
    final sectionBg = ThemeCommon.informativeSectionBg(colorScheme);
    final borderColor = ThemeCommon.informativeBorder(colorScheme);

    final appBarColor = isDarkMode ? const Color(0xFF0C4A6E) : accentColor;

    AppLogger.debug('📄 Apertura PrivacyPolicyPage');

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text('Privacy Policy',
            style: ThemeCommon.appBarTitleStyle(context)),
        backgroundColor: appBarColor,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.go('/home');
            }
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: ResponsiveValues.screenPadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            Center(
              child: Icon(
                Icons.privacy_tip,
                size: 120,
                color: accentColor,
              ),
            ),
            const SizedBox(height: 40),
            _buildSection(
              index: 0,
              title: '1. Introduzione',
              content:
                  'La presente Informativa sulla privacy descrive come OrsoCook (di seguito "noi", "ci", "nostro") raccoglie, utilizza e condivide le tue informazioni personali quando utilizzi la nostra applicazione.',
              colorScheme: colorScheme,
              isDarkMode: isDarkMode,
              context: context,
            ),
            _buildSection(
              index: 1,
              title: '2. Dati Personali Raccolti',
              content: 'Raccogliamo i seguenti dati personali:\n\n'
                  '• Nome utente e indirizzo email\n'
                  '• Password (hashata e crittografata)\n'
                  '• Ricette, commenti e preferenze\n'
                  '• Immagine del profilo (opzionale)\n\n'
                  '**Dati raccolti automaticamente:**\n'
                  '• Indirizzo IP e dati di connessione\n'
                  '• User-Agent (tipo browser/dispositivo)\n'
                  '• Timestamp di accessi e attività\n'
                  '• Cookie e tecnologie simili',
              colorScheme: colorScheme,
              isDarkMode: isDarkMode,
              context: context,
            ),
            _buildSection(
              index: 2,
              title: '3. Finalità del Trattamento',
              content: 'Utilizziamo i tuoi dati per:\n\n'
                  '• Fornire e gestire il servizio OrsoCook\n'
                  '• Autenticazione e sicurezza dell\'account\n'
                  '• Prevenzione di frodi e abusi\n'
                  '• Migliorare l\'esperienza utente\n'
                  '• Comunicazioni di servizio (verifica email, reset password)\n'
                  '• Rispetto di obblighi legali',
              colorScheme: colorScheme,
              isDarkMode: isDarkMode,
              context: context,
            ),
            _buildSection(
              index: 3,
              title: '4. Basi Giuridiche (GDPR Art. 6)',
              content: 'Il trattamento si basa su:\n\n'
                  '• **Esecuzione del contratto:** Per fornirti il servizio richiesto\n'
                  '• **Legittimo interesse:** Per sicurezza, prevenzione frodi e miglioramento servizio\n'
                  '• **Consenso:** Per specifiche finalità quando richiesto\n'
                  '• **Obbligo legale:** Per adempiere a obblighi normativi',
              colorScheme: colorScheme,
              isDarkMode: isDarkMode,
              context: context,
            ),
            _buildSection(
              index: 4,
              title: '5. Conservazione dei Dati',
              content:
                  'Conserviamo i tuoi dati solo per il periodo necessario:\n\n'
                  '• Dati account: Finché l\'account è attivo\n'
                  '• Sessioni di accesso: 30 giorni dall\'ultima attività\n'
                  '• Log di sicurezza: 90 giorni\n'
                  '• Contenuti pubblicati: Fino a cancellazione account\n\n'
                  'Al termine del periodo, i dati vengono cancellati o anonimizzati.',
              colorScheme: colorScheme,
              isDarkMode: isDarkMode,
              context: context,
            ),
            _buildSection(
              index: 5,
              title: '6. I Tuoi Diritti (GDPR)',
              content: 'Hai diritto a:\n\n'
                  '• **Accesso:** Ottenere copia dei tuoi dati\n'
                  '• **Rettifica:** Correggere dati inesatti\n'
                  '• **Cancellazione:** Eliminare il tuo account e dati\n'
                  '• **Limitazione:** Limitare il trattamento in casi specifici\n'
                  '• **Portabilità:** Ricevere i dati in formato strutturato\n'
                  '• **Opposizione:** Opporti al trattamento per motivi legittimi\n\n'
                  'Per esercitare i tuoi diritti, contattaci all\'email: privacy@orsocook.app',
              colorScheme: colorScheme,
              isDarkMode: isDarkMode,
              context: context,
            ),
            _buildSection(
              index: 6,
              title: '7. Sicurezza dei Dati',
              content: 'Adottiamo misure tecniche e organizzative adeguate:\n\n'
                  '• Crittografia dei dati sensibili\n'
                  '• Autenticazione sicura\n'
                  '• Backup regolari\n'
                  '• Limitazione accessi al personale autorizzato\n'
                  '• Valutazione periodica dei rischi',
              colorScheme: colorScheme,
              isDarkMode: isDarkMode,
              context: context,
            ),
            _buildSection(
              index: 7,
              title: '8. Cookie e Tecnologie Simili',
              content: 'Utilizziamo cookie per:\n\n'
                  '• **Cookie essenziali:** Funzionalità base dell\'app\n'
                  '• **Cookie di sicurezza:** Protezione account\n'
                  '• **Cookie di preferenze:** Memorizzare impostazioni\n\n'
                  'Puoi gestire le preferenze cookie nelle impostazioni del browser.',
              colorScheme: colorScheme,
              isDarkMode: isDarkMode,
              context: context,
            ),
            _buildSection(
              index: 8,
              title: '9. Trasferimento Dati Extra-UE',
              content:
                  'I tuoi dati sono ospitati su server nell\'Unione Europea.\n'
                  'Non trasferiamo dati al di fuori dello Spazio Economico Europeo (SEE) '
                  'senza garanzie adeguate come clausole contrattuali standard.',
              colorScheme: colorScheme,
              isDarkMode: isDarkMode,
              context: context,
            ),
            _buildSection(
              index: 9,
              title: '10. Contatti e Responsabile della Protezione Dati',
              content: 'Titolare del trattamento:\n'
                  'OrsoCook\n'
                  'Email: privacy@orsocook.app\n\n'
                  'Per questioni relative alla privacy e GDPR, '
                  'contattaci all\'email sopra indicata.\n\n'
                  'Ultimo aggiornamento: 02/02/2026',
              colorScheme: colorScheme,
              isDarkMode: isDarkMode,
              context: context,
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: ResponsiveValues.screenPadding(context),
              decoration: BoxDecoration(
                color: sectionBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: accentColor,
                    size: 24,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '⚠️ Questa Privacy Policy può essere aggiornata periodicamente. Ti invitiamo a consultarla regolarmente.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: ResponsiveValues.bodySize(context),
                      color: isDarkMode ? Colors.white70 : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required int index,
    required String title,
    required String content,
    required ColorScheme colorScheme,
    required bool isDarkMode,
    required BuildContext context,
  }) {
    final sectionColor = _getSectionColor(index, colorScheme, isDarkMode);

    final bgColor =
        isDarkMode ? sectionColor.withAlpha(25) : sectionColor.withAlpha(20);
    final borderColorWidget =
        isDarkMode ? sectionColor.withAlpha(60) : sectionColor.withAlpha(40);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: ResponsiveValues.screenPadding(context),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColorWidget),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.article_outlined,
                color: sectionColor,
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: ResponsiveValues.titleSize(context),
                    fontWeight: FontWeight.bold,
                    color: sectionColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              fontSize: ResponsiveValues.bodySize(context),
              height: 1.5,
              color: isDarkMode ? Colors.white70 : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
