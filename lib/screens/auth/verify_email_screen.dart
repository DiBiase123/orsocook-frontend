import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:orsocook/services/auth_service.dart';
import 'package:orsocook/utils/logger.dart';
import 'login_screen.dart';
import 'package:universal_html/html.dart' as html;

class VerifyEmailScreen extends StatefulWidget {
  final String? token;

  const VerifyEmailScreen({super.key, this.token});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool _isLoading = false;
  bool _isSuccess = false;
  String? _errorMessage;
  String? _message;
  String _debugMessage = 'In attesa...';

  @override
  void initState() {
    super.initState();
    _initTokenAndVerify();
  }

  Future<void> _initTokenAndVerify() async {
    debugPrint(
        '🔍 VerifyEmailScreen initState - token da widget: ${widget.token}');

    String? tokenFromStorage;

    // Usa html SOLO se siamo sul web
    if (kIsWeb) {
      try {
        // localStorage
        if (html.window.localStorage.containsKey('pendingVerificationToken')) {
          tokenFromStorage =
              html.window.localStorage['pendingVerificationToken'];
          if (tokenFromStorage != null) {
            debugPrint(
                '🔍 Token recuperato da localStorage: $tokenFromStorage');
            html.window.localStorage.remove('pendingVerificationToken');
          }
        }
      } catch (e) {
        debugPrint('❌ Errore lettura localStorage: $e');
      }

      // Se non c'è, prova sessionStorage
      if (tokenFromStorage == null) {
        try {
          if (html.window.sessionStorage
              .containsKey('pendingVerificationToken')) {
            tokenFromStorage =
                html.window.sessionStorage['pendingVerificationToken'];
            if (tokenFromStorage != null) {
              debugPrint(
                  '🔍 Token recuperato da sessionStorage: $tokenFromStorage');
              html.window.sessionStorage.remove('pendingVerificationToken');
            }
          }
        } catch (e) {
          debugPrint('❌ Errore lettura sessionStorage: $e');
        }
      }
    }

    // Per tutte le piattaforme (incluso web come fallback) usa SharedPreferences
    if (tokenFromStorage == null) {
      try {
        final prefs = await SharedPreferences.getInstance();
        tokenFromStorage = prefs.getString('pendingVerificationToken');
        if (tokenFromStorage != null) {
          await prefs.remove('pendingVerificationToken');
          debugPrint(
              '🔍 Token recuperato da SharedPreferences: $tokenFromStorage');
        }
      } catch (e) {
        debugPrint('❌ Errore lettura SharedPreferences: $e');
      }
    }

    // Usa il token dai parametri o dallo storage
    final effectiveToken = widget.token ?? tokenFromStorage;

    debugPrint('🔍 VerifyEmailScreen - token finale: $effectiveToken');

    if (mounted) {
      setState(() {
        _debugMessage = 'initState - Token: ${effectiveToken ?? "NESSUNO"}';
      });
    }

    if (effectiveToken != null && effectiveToken.isNotEmpty) {
      _verifyEmail(effectiveToken);
    } else {
      if (mounted) {
        setState(() {
          _debugMessage = 'Token mancante o nullo';
        });
      }
    }
  }

  Future<void> _verifyEmail(String token) async {
    if (_isLoading) return;

    if (mounted) {
      setState(() {
        _debugMessage =
            'Avvio verifica per token: ${token.substring(0, 10)}...';
        _isLoading = true;
        _errorMessage = null;
        _message = null;
      });
    }

    AppLogger.debug(
        '🔐 Verifica email con token: ${token.length > 10 ? token.substring(0, 10) : token}...');

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final result = await authService.verifyEmail(token);

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      if (result.success) {
        AppLogger.success('✅ Email verificata con successo');
        setState(() {
          _isSuccess = true;
          _message = result.message;
          _debugMessage = 'Verifica riuscita!';
        });

        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            );
          }
        });
      } else {
        AppLogger.error('❌ Verifica email fallita: ${result.message}');
        setState(() {
          _isSuccess = false;
          _errorMessage = result.message;
          _debugMessage = 'Fallimento: ${result.message}';
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _isSuccess = false;
        _errorMessage = 'Errore di connessione';
        _debugMessage = 'Errore: ${e.toString()}';
      });

      AppLogger.error('❌ Errore durante la verifica email', e);
    }
  }

  Widget _buildLoading() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 20),
          Text(
            'Verifica in corso...',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccess() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.check_circle,
            size: 80,
            color: Colors.green,
          ),
          const SizedBox(height: 24),
          Text(
            _message ?? '🎉 Account verificato con successo!',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            'Verrai reindirizzato al login...',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 32),
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 80,
            color: Colors.red,
          ),
          const SizedBox(height: 24),
          Text(
            _errorMessage ?? 'Errore durante la verifica',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            'Il link di verifica potrebbe essere scaduto o non valido.',
            style: TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
            child: const Text('Vai al Login'),
          ),
        ],
      ),
    );
  }

  Widget _buildInitialState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.mark_email_read,
            size: 80,
            color: Colors.blue,
          ),
          const SizedBox(height: 24),
          const Text(
            'Verifica il tuo account',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Clicca il pulsante qui sotto per verificare il tuo indirizzo email e attivare il tuo account.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(height: 32),
          if (widget.token != null && widget.token!.isNotEmpty)
            ElevatedButton(
              onPressed: () => _verifyEmail(widget.token!),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(200, 50),
              ),
              child: const Text(
                'VERIFICA ACCOUNT',
                style: TextStyle(fontSize: 16),
              ),
            ),
          const SizedBox(height: 20),
          TextButton(
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
            child: const Text('Torna al Login'),
          ),
          const SizedBox(height: 30),
          Container(
            padding: const EdgeInsets.all(10),
            color: Colors.yellow.shade100,
            child: Text(
              '🔍 DEBUG: $_debugMessage',
              style: const TextStyle(fontSize: 12, color: Colors.black),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verifica Email'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            );
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: _isLoading
              ? _buildLoading()
              : _isSuccess
                  ? _buildSuccess()
                  : _errorMessage != null
                      ? _buildError()
                      : _buildInitialState(),
        ),
      ),
    );
  }
}
