class CookieData {
  final String name;
  final String purpose;
  final String duration;
  final String type;

  const CookieData({
    required this.name,
    required this.purpose,
    required this.duration,
    required this.type,
  });
}

const List<CookieData> cookieList = [
  CookieData(
    name: 'session_id',
    purpose: 'Mantiene la sessione di login attiva',
    duration: '30 giorni',
    type: 'Essenziale',
  ),
  CookieData(
    name: 'csrf_token',
    purpose: 'Protezione da attacchi CSRF',
    duration: 'Sessione',
    type: 'Sicurezza',
  ),
  CookieData(
    name: 'theme_preference',
    purpose: 'Memorizza tema scelto (chiaro/scuro)',
    duration: '1 anno',
    type: 'Preferenze',
  ),
  CookieData(
    name: 'language',
    purpose: 'Memorizza lingua preferita',
    duration: '1 anno',
    type: 'Preferenze',
  ),
];
