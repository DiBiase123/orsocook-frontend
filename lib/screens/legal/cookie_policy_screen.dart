import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:orsocook/utils/logger.dart';

class CookiePolicyScreen extends StatelessWidget {
  const CookiePolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    AppLogger.debug('🍪 Apertura CookiePolicyScreen');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Informativa Cookie'),
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
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Icon(
                Icons.cookie,
                size: 60,
                color: Colors.brown,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'INFORMATIVA SUI COOKIE - OrsoCook',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.brown,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),

            // INTRODUZIONE
            _buildSection(
              title: 'Cosa sono i Cookie?',
              content:
                  'I cookie sono piccoli file di testo che i siti web e le app memorizzano sul tuo dispositivo quando li visiti. '
                  'Contengono informazioni che aiutano a migliorare la tua esperienza di navigazione.',
            ),

            // TIPI DI COOKIE
            _buildSection(
              title: 'Tipi di Cookie Utilizzati',
              content: 'Utilizziamo diverse categorie di cookie:',
            ),

            // TABELLA COOKIE
            DataTable(
              columns: const [
                DataColumn(label: Text('Categoria')),
                DataColumn(label: Text('Finalità')),
                DataColumn(label: Text('Esempi')),
              ],
              rows: const [
                DataRow(cells: [
                  DataCell(Text('Essenziali',
                      style: TextStyle(fontWeight: FontWeight.bold))),
                  DataCell(Text('Funzionalità base')),
                  DataCell(Text('Autenticazione, sicurezza')),
                ]),
                DataRow(cells: [
                  DataCell(Text('Preferenze',
                      style: TextStyle(fontWeight: FontWeight.bold))),
                  DataCell(Text('Personalizzazione')),
                  DataCell(Text('Lingua, tema, impostazioni')),
                ]),
                DataRow(cells: [
                  DataCell(Text('Sicurezza',
                      style: TextStyle(fontWeight: FontWeight.bold))),
                  DataCell(Text('Protezione account')),
                  DataCell(Text('Prevenzione frodi, accessi non autorizzati')),
                ]),
                DataRow(cells: [
                  DataCell(Text('Performance',
                      style: TextStyle(fontWeight: FontWeight.bold))),
                  DataCell(Text('Analisi uso app')),
                  DataCell(Text('Statistiche anonime, miglioramenti')),
                ]),
              ],
            ),

            const SizedBox(height: 20),

            // COOKIE SPECIFICI
            _buildSection(
              title: 'Cookie Specifici di OrsoCook',
              content: 'Elenco dei principali cookie utilizzati:',
            ),

            _buildCookieItem(
              name: 'session_id',
              purpose: 'Mantiene la sessione di login attiva',
              duration: '30 giorni',
              type: 'Essenziale',
            ),

            _buildCookieItem(
              name: 'csrf_token',
              purpose: 'Protezione da attacchi CSRF',
              duration: 'Sessione',
              type: 'Sicurezza',
            ),

            _buildCookieItem(
              name: 'theme_preference',
              purpose: 'Memorizza tema scelto (chiaro/scuro)',
              duration: '1 anno',
              type: 'Preferenze',
            ),

            _buildCookieItem(
              name: 'language',
              purpose: 'Memorizza lingua preferita',
              duration: '1 anno',
              type: 'Preferenze',
            ),

            // GESTIONE COOKIE
            _buildSection(
              title: 'Come Gestire i Cookie',
              content:
                  'Puoi controllare e gestire i cookie attraverso le impostazioni del tuo browser:\n\n'
                  '**Chrome:** Impostazioni → Privacy e sicurezza → Cookie\n'
                  '**Firefox:** Opzioni → Privacy & Sicurezza → Cookie\n'
                  '**Safari:** Preferenze → Privacy → Gestione cookie\n'
                  '**Edge:** Impostazioni → Cookie e autorizzazioni sito\n\n'
                  'Disabilitando i cookie essenziali, alcune funzionalità dell\'app potrebbero non funzionare correttamente.',
            ),

            // COOKIE TERZE PARTI
            _buildSection(
              title: 'Cookie di Terze Parti',
              content:
                  'Attualmente OrsoCook NON utilizza cookie di terze parti per:\n'
                  '• Pubblicità\n'
                  '• Analytics esterni\n'
                  '• Social media\n'
                  '• Servizi di tracciamento\n\n'
                  'Se in futuro implementeremo tali servizi, aggiorneremo questa informativa e richiederemo il tuo consenso.',
            ),

            // CONSENSO
            _buildSection(
              title: 'Consenso',
              content:
                  'Utilizzando OrsoCook, accetti l\'uso dei cookie essenziali e di sicurezza, necessari per il funzionamento dell\'app.\n\n'
                  'Per i cookie non essenziali (se implementati in futuro), richiederemo il tuo consenso esplicito.',
            ),

            // INFORMAZIONI
            _buildSection(
              title: 'Informazioni e Contatti',
              content: 'Per domande sulla nostra politica dei cookie:\n\n'
                  'Email: privacy@orsocook.app\n'
                  'Ultimo aggiornamento: 02/02/2026',
            ),

            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.brown[50],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.brown[100]!),
              ),
              child: const Column(
                children: [
                  Icon(Icons.info_outline, color: Colors.brown, size: 30),
                  SizedBox(height: 10),
                  Text(
                    'Questa informativa si applica esclusivamente all\'app OrsoCook e non a siti web o servizi di terze parti collegati.',
                    style: TextStyle(fontSize: 14, color: Colors.brown),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required String content}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 25),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.brown,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          content,
          style: const TextStyle(fontSize: 16, height: 1.5),
        ),
      ],
    );
  }

  Widget _buildCookieItem({
    required String name,
    required String purpose,
    required String duration,
    required String type,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getColorForType(type),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    type.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '🎯 **Scopo:** $purpose',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              '⏱️ **Durata:** $duration',
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Color _getColorForType(String type) {
    switch (type.toLowerCase()) {
      case 'essenziale':
        return Colors.green;
      case 'sicurezza':
        return Colors.red;
      case 'preferenze':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}
