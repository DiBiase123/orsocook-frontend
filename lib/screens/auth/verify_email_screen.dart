import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:orsocook/services/auth_service.dart';
import 'package:orsocook/utils/logger.dart';
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

  @override
  void initState() {
    super.initState();
    _initializeVerification();
  }

  Future<void> _initializeVerification() async {
    final effectiveToken = widget.token ?? await _getTokenFromStorage();

    if (effectiveToken != null && effectiveToken.isNotEmpty) {
      _verifyEmail(effectiveToken);
    }
  }

  Future<String?> _getTokenFromStorage() async {
    if (kIsWeb) {
      try {
        // Prova localStorage
        if (html.window.localStorage.containsKey('pendingVerificationToken')) {
          final token = html.window.localStorage['pendingVerificationToken'];
          html.window.localStorage.remove('pendingVerificationToken');
          return token;
        }

        // Prova sessionStorage
        if (html.window.sessionStorage
            .containsKey('pendingVerificationToken')) {
          final token = html.window.sessionStorage['pendingVerificationToken'];
          html.window.sessionStorage.remove('pendingVerificationToken');
          return token;
        }
      } catch (e) {
        AppLogger.error('Errore lettura storage web', e);
      }
    }

    // Fallback su SharedPreferences
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('pendingVerificationToken');
      if (token != null) {
        await prefs.remove('pendingVerificationToken');
      }
      return token;
    } catch (e) {
      AppLogger.error('Errore lettura SharedPreferences', e);
      return null;
    }
  }

  Future<void> _verifyEmail(String token) async {
    if (_isLoading || !mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _message = null;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final result = await authService.verifyEmail(token);

      if (!mounted) return;

      if (result.success) {
        setState(() {
          _isLoading = false;
          _isSuccess = true;
          _message = result.message;
        });

        Future.delayed(const Duration(seconds: 3), _navigateToLogin);
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = result.message;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Errore di connessione';
      });
      AppLogger.error('Errore verifica email', e);
    }
  }

  void _navigateToLogin() {
    if (mounted) {
      context.go('/login');
    }
  }

  Widget _buildLoading() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 20),
          Text('Verifica in corso...'),
        ],
      ),
    );
  }

  Widget _buildSuccess() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle, size: 80, color: Colors.green),
          const SizedBox(height: 24),
          Text(
            _message ?? 'Account verificato con successo!',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text('Verrai reindirizzato al login...'),
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
          const Icon(Icons.error_outline, size: 80, color: Colors.red),
          const SizedBox(height: 24),
          Text(
            _errorMessage ?? 'Errore durante la verifica',
            style: const TextStyle(fontSize: 18, color: Colors.red),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text('Il link potrebbe essere scaduto o non valido.'),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _navigateToLogin,
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
          const Icon(Icons.mark_email_read, size: 80, color: Colors.blue),
          const SizedBox(height: 24),
          const Text(
            'Verifica il tuo account',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Clicca il pulsante qui sotto per verificare il tuo indirizzo email.',
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 32),
          if (widget.token?.isNotEmpty ?? false)
            ElevatedButton(
              onPressed: () => _verifyEmail(widget.token!),
              style: ElevatedButton.styleFrom(minimumSize: const Size(200, 50)),
              child: const Text('VERIFICA ACCOUNT'),
            ),
          const SizedBox(height: 20),
          TextButton(
            onPressed: _navigateToLogin,
            child: const Text('Torna al Login'),
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
          onPressed: _navigateToLogin,
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
