import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:orsocook/utils/logger.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    AppLogger.debug('📄 Apertura PrivacyPolicyScreen');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
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
                Icons.privacy_tip,
                size: 60,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'INFORMATIVA SULLA PRIVACY - OrsoCook',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),

            // 1. INTRODUZIONE
            _buildSection(
              title: '1. Introduzione',
              content:
                  'La presente Informativa sulla privacy descrive come OrsoCook (di seguito "noi", "ci", "nostro") raccoglie, utilizza e condivide le tue informazioni personali quando utilizzi la nostra applicazione.',
            ),

            // 2. DATI RACCOLTI
            _buildSection(
              title: '2. Dati Personali Raccolti',
              content: 'Raccogliamo i seguenti dati personali:\n\n'
                  '**Dati forniti volontariamente:**\n'
                  '• Nome utente e indirizzo email\n'
                  '• Password (hashata e crittografata)\n'
                  '• Ricette, commenti e preferenze\n'
                  '• Immagine del profilo (opzionale)\n\n'
                  '**Dati raccolti automaticamente:**\n'
                  '• Indirizzo IP e dati di connessione\n'
                  '• User-Agent (tipo browser/dispositivo)\n'
                  '• Timestamp di accessi e attività\n'
                  '• Cookie e tecnologie simili',
            ),

            // 3. FINALITÀ DEL TRATTAMENTO
            _buildSection(
              title: '3. Finalità del Trattamento',
              content: 'Utilizziamo i tuoi dati per:\n\n'
                  '• Fornire e gestire il servizio OrsoCook\n'
                  '• Autenticazione e sicurezza dell\'account\n'
                  '• Prevenzione di frodi e abusi\n'
                  '• Migliorare l\'esperienza utente\n'
                  '• Comunicazioni di servizio (verifica email, reset password)\n'
                  '• Rispetto di obblighi legali',
            ),

            // 4. BASI GIURIDICHE GDPR
            _buildSection(
              title: '4. Basi Giuridiche (GDPR Art. 6)',
              content: 'Il trattamento si basa su:\n\n'
                  '• **Esecuzione del contratto:** Per fornirti il servizio richiesto\n'
                  '• **Legittimo interesse:** Per sicurezza, prevenzione frodi e miglioramento servizio\n'
                  '• **Consenso:** Per specifiche finalità quando richiesto\n'
                  '• **Obbligo legale:** Per adempiere a obblighi normativi',
            ),

            // 5. CONSERVAZIONE DATI
            _buildSection(
              title: '5. Conservazione dei Dati',
              content:
                  'Conserviamo i tuoi dati solo per il periodo necessario:\n\n'
                  '• Dati account: Finché l\'account è attivo\n'
                  '• Sessioni di accesso: 30 giorni dall\'ultima attività\n'
                  '• Log di sicurezza: 90 giorni\n'
                  '• Contenuti pubblicati: Fino a cancellazione account\n\n'
                  'Al termine del periodo, i dati vengono cancellati o anonimizzati.',
            ),

            // 6. DIRITTI DELL'INTERESSATO
            _buildSection(
              title: '6. I Tuoi Diritti (GDPR)',
              content: 'Hai diritto a:\n\n'
                  '• **Accesso:** Ottenere copia dei tuoi dati\n'
                  '• **Rettifica:** Correggere dati inesatti\n'
                  '• **Cancellazione:** Eliminare il tuo account e dati\n'
                  '• **Limitazione:** Limitare il trattamento in casi specifici\n'
                  '• **Portabilità:** Ricevere i dati in formato strutturato\n'
                  '• **Opposizione:** Opporti al trattamento per motivi legittimi\n\n'
                  'Per esercitare i tuoi diritti, contattaci all\'email: privacy@orsocook.app',
            ),

            // 7. SICUREZZA
            _buildSection(
              title: '7. Sicurezza dei Dati',
              content: 'Adottiamo misure tecniche e organizzative adeguate:\n\n'
                  '• Crittografia dei dati sensibili\n'
                  '• Autenticazione sicura\n'
                  '• Backup regolari\n'
                  '• Limitazione accessi al personale autorizzato\n'
                  '• Valutazione periodica dei rischi',
            ),

            // 8. COOKIE
            _buildSection(
              title: '8. Cookie e Tecnologie Simili',
              content: 'Utilizziamo cookie per:\n\n'
                  '• **Cookie essenziali:** Funzionalità base dell\'app\n'
                  '• **Cookie di sicurezza:** Protezione account\n'
                  '• **Cookie di preferenze:** Memorizzare impostazioni\n\n'
                  'Puoi gestire le preferenze cookie nelle impostazioni del browser.',
            ),

            // 9. TRASFERIMENTO DATI
            _buildSection(
              title: '9. Trasferimento Dati Extra-UE',
              content:
                  'I tuoi dati sono ospitati su server nell\'Unione Europea.\n'
                  'Non trasferiamo dati al di fuori dello Spazio Economico Europeo (SEE) '
                  'senza garanzie adeguate come clausole contrattuali standard.',
            ),

            // 10. CONTATTI
            _buildSection(
              title: '10. Contatti e Responsabile della Protezione Dati',
              content: 'Titolare del trattamento:\n'
                  'OrsoCook\n'
                  'Email: privacy@orsocook.app\n\n'
                  'Per questioni relative alla privacy e GDPR, '
                  'contattaci all\'email sopra indicata.\n\n'
                  'Ultimo aggiornamento: 02/02/2026',
            ),

            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.blue[100]!),
              ),
              child: const Text(
                '⚠️ Questa Privacy Policy può essere aggiornata periodicamente. '
                'Ti invitiamo a consultarla regolarmente.',
                style: TextStyle(fontSize: 14, color: Colors.blue),
                textAlign: TextAlign.center,
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
            color: Colors.blue,
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
}
