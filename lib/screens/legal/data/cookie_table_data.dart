class CookieTableRow {
  final String category;
  final String purpose;
  final String examples;
  final int index;

  const CookieTableRow({
    required this.category,
    required this.purpose,
    required this.examples,
    required this.index,
  });
}

const List<CookieTableRow> cookieTableData = [
  CookieTableRow(
      category: 'Essenziali',
      purpose: 'Funzionalità base',
      examples: 'Autenticazione, sicurezza',
      index: 0),
  CookieTableRow(
      category: 'Preferenze',
      purpose: 'Personalizzazione',
      examples: 'Lingua, tema, impostazioni',
      index: 1),
  CookieTableRow(
      category: 'Sicurezza',
      purpose: 'Protezione account',
      examples: 'Prevenzione frodi, accessi non autorizzati',
      index: 2),
  CookieTableRow(
      category: 'Performance',
      purpose: 'Analisi uso app',
      examples: 'Statistiche anonime, miglioramenti',
      index: 3),
];
