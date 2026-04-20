import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:orsocook/services/auth_service.dart';
import 'package:orsocook/utils/logger.dart';
import 'package:orsocook/utils/responsive_utils.dart';
import 'package:orsocook/theme/theme_common.dart';

// Conditional import solo per Web
import 'package:universal_html/html.dart' as html if (dart.library.html) 'dart:html';

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
    // Solo su Web: leggi da localStorage/sessionStorage
    if (kIsWeb) {
      try {
        // eslint-disable-next-line avoid_dynamic_calls
        if (html.window.localStorage.containsKey('pendingVerificationToken')) {
          // eslint-disable-next-line avoid_dynamic_calls
          final token = html.window.localStorage['pendingVerificationToken'];
          // eslint-disable-next-line avoid_dynamic_calls
          html.window.localStorage.remove('pendingVerificationToken');
          return token;
        }

        // eslint-disable-next-line avoid_dynamic_calls
        if (html.window.sessionStorage.containsKey('pendingVerificationToken')) {
          // eslint-disable-next-line avoid_dynamic_calls
          final token = html.window.sessionStorage['pendingVerificationToken'];
          // eslint-disable-next-line avoid_dynamic_calls
          html.window.sessionStorage.remove('pendingVerificationToken');
          return token;
        }
      } catch (e) {
        AppLogger.error('Errore lettura storage web', e);
      }
    }

    // Su tutte le piattaforme: leggi da SharedPreferences
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          SizedBox(height: ResponsiveValues.gapLarge(context)),
          const Text('Verifica in corso...'),
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
          SizedBox(height: ResponsiveValues.gapLarge(context)),
          Text(
            _message ?? 'Account verificato con successo!',
            style: TextStyle(
              fontSize: ResponsiveValues.titleSize(context),
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: ResponsiveValues.gapMedium(context)),
          const Text('Verrai reindirizzato al login...'),
          SizedBox(height: ResponsiveValues.gapExtraLarge(context)),
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
          SizedBox(height: ResponsiveValues.gapLarge(context)),
          Text(
            _errorMessage ?? 'Errore durante la verifica',
            style: TextStyle(
              fontSize: ResponsiveValues.bodySize(context) + 2,
              color: Colors.red,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: ResponsiveValues.gapMedium(context)),
          const Text('Il link potrebbe essere scaduto o non valido.'),
          SizedBox(height: ResponsiveValues.gapExtraLarge(context)),
          ElevatedButton(
            onPressed: _navigateToLogin,
            style: ElevatedButton.styleFrom(
              minimumSize:
                  Size(double.infinity, ResponsiveValues.buttonHeight(context)),
            ),
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
          SizedBox(height: ResponsiveValues.gapLarge(context)),
          Text(
            'Verifica il tuo account',
            style: TextStyle(
              fontSize: ResponsiveValues.titleSize(context) + 4,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: ResponsiveValues.gapMedium(context)),
          Padding(
            padding: ResponsiveValues.horizontalPadding(context),
            child: const Text(
              'Clicca il pulsante qui sotto per verificare il tuo indirizzo email.',
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: ResponsiveValues.gapExtraLarge(context)),
          if (widget.token?.isNotEmpty ?? false)
            ElevatedButton(
              onPressed: () => _verifyEmail(widget.token!),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(200, ResponsiveValues.buttonHeight(context)),
              ),
              child: const Text('VERIFICA ACCOUNT'),
            ),
          SizedBox(height: ResponsiveValues.gapLarge(context)),
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
        title: Text('Verifica Email', style: ThemeCommon.appBarTitleStyle(context)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _navigateToLogin,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: ResponsiveValues.screenPadding(context),
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