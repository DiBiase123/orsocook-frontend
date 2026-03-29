import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:orsocook/services/auth_service.dart';
import 'package:orsocook/screens/auth/widgets/login_logo.dart';
import 'package:orsocook/screens/auth/widgets/login_form_fields.dart';
import 'package:orsocook/screens/auth/widgets/login_actions.dart';
import 'package:orsocook/utils/logger.dart';

class LoginModalContent extends StatefulWidget {
  final VoidCallback onClose;
  final bool showCloseButton;
  final VoidCallback? onNavigateToRegister;
  final VoidCallback? onNavigateToForgotPassword;

  const LoginModalContent({
    super.key,
    required this.onClose,
    this.showCloseButton = true,
    this.onNavigateToRegister,
    this.onNavigateToForgotPassword,
  });

  @override
  State<LoginModalContent> createState() => _LoginModalContentState();
}

class _LoginModalContentState extends State<LoginModalContent> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitLogin() async {
    // Usa WidgetsBinding per assicurarsi che il widget sia costruito
    await WidgetsBinding.instance.endOfFrame;

    if (!mounted) return;

    if (_formKey.currentState == null) {
      AppLogger.debug('Form non pronto, riprovo dopo il prossimo frame');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _formKey.currentState == null) {
          AppLogger.debug('Form ancora non pronto, ritento dopo 100ms');
          Future.delayed(const Duration(milliseconds: 100), () {
            if (mounted) _submitLogin();
          });
        } else if (mounted) {
          _submitLogin();
        }
      });
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final result = await authService.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (result.success) {
        _showSnackBar('Login effettuato con successo!', Colors.green);
        widget.onClose();
      } else {
        _handleLoginError(result);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showSnackBar('Errore di connessione', Colors.red);
    }
  }

  void _handleLoginError(dynamic result) {
    if (result.requiresVerification) {
      _showEmailNotVerifiedDialog(result.email ?? _emailController.text.trim());
    } else if (result.isLocked) {
      _showAccountLockedDialog(result.lockTime ?? 15);
    } else {
      setState(() => _errorMessage = result.message);
      _showSnackBar(result.message, Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showEmailNotVerifiedDialog(String email) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('📧 Email Non Verificata'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.mark_email_unread, size: 60, color: Colors.orange),
            const SizedBox(height: 16),
            const Text('Devi verificare la tua email prima di accedere.'),
            const SizedBox(height: 8),
            Text(email,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.blue)),
            const SizedBox(height: 16),
            const Text('Controlla la tua posta e clicca sul link di verifica.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => _resendVerificationEmail(email),
            child: const Text('RINVIA EMAIL'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('CHIUDI'),
          ),
        ],
      ),
    );
  }

  Future<void> _resendVerificationEmail(String email) async {
    setState(() => _isLoading = true);
    Navigator.of(context).pop();

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final result = await authService.resendVerificationEmail(email);

      if (!mounted) return;
      setState(() => _isLoading = false);
      _showSnackBar(result.message, result.success ? Colors.green : Colors.red);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showSnackBar('Errore di connessione', Colors.red);
    }
  }

  void _showAccountLockedDialog(int lockTime) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('🔒 Account Bloccato'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock_clock, size: 60, color: Colors.red),
            const SizedBox(height: 16),
            const Text('Troppi tentativi di login falliti.'),
            const SizedBox(height: 8),
            Text('Account bloccato per $lockTime minuti.',
                style: const TextStyle(
                    color: Colors.red, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('HO CAPITO'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _navigateToForgotPassword();
            },
            child: const Text('PASSWORD DIMENTICATA'),
          ),
        ],
      ),
    );
  }

  void _navigateToForgotPassword() {
    if (widget.onNavigateToForgotPassword != null) {
      widget.onNavigateToForgotPassword!();
    } else {
      widget.onClose();
    }
  }

  void _navigateToRegister() {
    if (widget.onNavigateToRegister != null) {
      widget.onNavigateToRegister!();
    } else {
      widget.onClose();
    }
  }

  void _clearErrorOnChange() {
    if (_errorMessage != null) setState(() => _errorMessage = null);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (widget.showCloseButton)
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: const Icon(Icons.close, size: 32),
                    onPressed: widget.onClose,
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.grey.withAlpha(50),
                      foregroundColor: Theme.of(context).colorScheme.primary,
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(8),
                    ),
                  ),
                ),
              const LoginLogo(),
              const SizedBox(height: 24),
              LoginFormFields(
                emailController: _emailController,
                passwordController: _passwordController,
                errorMessage: _errorMessage,
                onEmailChanged: (_) => _clearErrorOnChange(),
                onPasswordChanged: (_) => _clearErrorOnChange(),
                onForgotPasswordPressed:
                    _isLoading ? null : _navigateToForgotPassword,
                onSubmitted: _submitLogin,
                isLoading: _isLoading,
              ),
              const SizedBox(height: 24),
              LoginActions(
                isLoading: _isLoading,
                onLoginPressed: _submitLogin,
                onRegisterPressed: _isLoading ? null : _navigateToRegister,
                onContinueWithoutAuth: widget.onClose,
                showSocialLogin: true,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
