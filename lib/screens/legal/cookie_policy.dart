import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:orsocook/utils/logger.dart';
import 'package:orsocook/utils/responsive_values.dart';
import 'package:orsocook/theme/theme_common.dart';
import 'package:orsocook/screens/legal/widgets/accordion_section.dart';
import 'package:orsocook/screens/legal/widgets/cookie_section.dart';
import 'package:orsocook/screens/legal/widgets/cookie_item.dart';
import 'package:orsocook/screens/legal/widgets/cookie_table.dart';
import 'package:orsocook/screens/legal/data/cookie_data.dart';

class CookiePolicyScreen extends StatelessWidget {
  const CookiePolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDarkMode = colorScheme.brightness == Brightness.dark;
    final accentColor = ThemeCommon.informativeAccent(colorScheme);
    final sectionBg = ThemeCommon.informativeSectionBg(colorScheme);
    final borderColor = ThemeCommon.informativeBorder(colorScheme);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    AppLogger.debug('🍪 Apertura CookiePolicyScreen');
    AppLogger.debug('📐 Schermo: ${screenWidth}x$screenHeight');

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text('Informativa Cookie',
            style: ThemeCommon.appBarTitleStyle(context)),
        backgroundColor: isDarkMode ? const Color(0xFF0C4A6E) : accentColor,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).canPop()
              ? Navigator.of(context).pop()
              : context.go('/home'),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: ResponsiveValues.screenPadding(context).left,
          right: ResponsiveValues.screenPadding(context).right,
          bottom: ResponsiveValues.screenPadding(context).bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            CookieSection(
              index: 0,
              title: 'Cosa sono i Cookie?',
              content:
                  'I cookie sono piccoli file di testo che i siti web e le app memorizzano sul tuo dispositivo quando li visiti. Contengono informazioni che aiutano a migliorare la tua esperienza di navigazione.',
              isDarkMode: isDarkMode,
              context: context,
              isExpandable: false,
            ),
            AccordionSection(
              index: 1,
              title: 'Tipi di Cookie Utilizzati',
              isDarkMode: isDarkMode,
              context: context,
              body:
                  CookieTable(isDarkMode: isDarkMode, screenWidth: screenWidth),
            ),
            AccordionSection(
              index: 4,
              title: 'Cookie Specifici di OrsoCook',
              isDarkMode: isDarkMode,
              context: context,
              body: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: cookieList
                      .map((cookie) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: CookieItemWidget(
                              cookie: cookie,
                              index: cookieList.indexOf(cookie),
                              isDarkMode: isDarkMode,
                              context: context,
                            ),
                          ))
                      .toList(),
                ),
              ),
            ),
            _buildTextSection(
                index: 5,
                title: 'Come Gestire i Cookie',
                content: '''
Puoi controllare e gestire i cookie attraverso le impostazioni del tuo browser:

**Chrome:** Impostazioni → Privacy e sicurezza → Cookie
**Firefox:** Opzioni → Privacy & Sicurezza → Cookie
**Safari:** Preferenze → Privacy → Gestione cookie
**Edge:** Impostazioni → Cookie e autorizzazioni sito

Disabilitando i cookie essenziali, alcune funzionalità dell'app potrebbero non funzionare correttamente.''',
                isDarkMode: isDarkMode,
                context: context),
            _buildTextSection(
                index: 6,
                title: 'Cookie di Terze Parti',
                content: '''
Attualmente OrsoCook NON utilizza cookie di terze parti per:
• Pubblicità
• Analytics esterni
• Social media
• Servizi di tracciamento

Se in futuro implementeremo tali servizi, aggiorneremo questa informativa e richiederemo il tuo consenso.''',
                isDarkMode: isDarkMode,
                context: context),
            _buildTextSection(
                index: 7,
                title: 'Consenso',
                content: '''
Utilizzando OrsoCook, accetti l'uso dei cookie essenziali e di sicurezza, necessari per il funzionamento dell'app.

Per i cookie non essenziali (se implementati in futuro), richiederemo il tuo consenso esplicito.''',
                isDarkMode: isDarkMode,
                context: context),
            _buildTextSection(
                index: 8,
                title: 'Informazioni e Contatti',
                content: '''
Per domande sulla nostra politica dei cookie:

Email: privacy@orsocook.app

Ultimo aggiornamento: 02/02/2026''',
                isDarkMode: isDarkMode,
                context: context),
            const SizedBox(height: 20),
            Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                    color: sectionBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor)),
                child: Text(
                  'Questa informativa si applica esclusivamente all\'app OrsoCook e non a siti web o servizi di terze parti collegati.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: ResponsiveValues.bodySize(context),
                      color: isDarkMode ? Colors.white70 : Colors.black87,
                      height: 1.4),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildTextSection(
      {required int index,
      required String title,
      required String content,
      required bool isDarkMode,
      required BuildContext context}) {
    return AccordionSection(
      index: index,
      title: title,
      isDarkMode: isDarkMode,
      context: context,
      body: Text(content,
          style: TextStyle(
              fontSize: ResponsiveValues.bodySize(context),
              color: isDarkMode ? Colors.white70 : Colors.black87,
              height: 1.5)),
    );
  }
}
