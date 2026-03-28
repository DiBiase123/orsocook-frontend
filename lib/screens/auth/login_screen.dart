import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:orsocook/services/auth_service.dart';
import 'package:orsocook/screens/auth/widgets/auth_screen.dart';
import 'package:orsocook/screens/auth/widgets/login_logo.dart';
import 'package:orsocook/screens/auth/widgets/login_form_fields.dart';
import 'package:orsocook/screens/auth/widgets/login_actions.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback? onNavigateToRegister;
  final VoidCallback? onNavigateToForgotPassword;

  const LoginScreen({
    super.key,
    this.onNavigateToRegister,
    this.onNavigateToForgotPassword,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
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
    // Aspetta il prossimo frame per assicurarsi che il form sia costruito
    await Future.delayed(Duration.zero);

    if (_formKey.currentState == null) {
      print('Form non pronto, riprovo');
      Future.delayed(const Duration(milliseconds: 50), _submitLogin);
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Login effettuato con successo!'),
              backgroundColor: Colors.green),
        );
        Navigator.of(context).pop();
        context.go('/home');
      } else {
        _handleLoginError(result);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Errore di connessione'),
            backgroundColor: Colors.red),
      );
    }
  }

  void _handleLoginError(dynamic result) {
    if (result.requiresVerification) {
      _showEmailNotVerifiedDialog(result.email ?? _emailController.text.trim());
    } else if (result.isLocked) {
      _showAccountLockedDialog(result.lockTime ?? 15);
    } else {
      setState(() => _errorMessage = result.message);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.message), backgroundColor: Colors.red),
      );
    }
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(result.message),
            backgroundColor: result.success ? Colors.green : Colors.red),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Errore di connessione'),
            backgroundColor: Colors.red),
      );
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
              widget.onNavigateToForgotPassword?.call();
            },
            child: const Text('PASSWORD DIMENTICATA'),
          ),
        ],
      ),
    );
  }

  void _navigateToForgotPassword() {
    widget.onNavigateToForgotPassword?.call();
  }

  void _navigateToRegister() {
    widget.onNavigateToRegister?.call();
  }

  void _clearErrorOnChange() {
    if (_errorMessage != null) setState(() => _errorMessage = null);
  }

  @override
  Widget build(BuildContext context) {
    return AuthScreen(
      title: 'Login',
      logo: const LoginLogo(),
      formFields: LoginFormFields(
        emailController: _emailController,
        passwordController: _passwordController,
        errorMessage: _errorMessage,
        onEmailChanged: (_) => _clearErrorOnChange(),
        onPasswordChanged: (_) => _clearErrorOnChange(),
        onForgotPasswordPressed: _isLoading ? null : _navigateToForgotPassword,
        onSubmitted: _submitLogin,
        isLoading: _isLoading,
      ),
      actions: LoginActions(
        isLoading: _isLoading,
        onLoginPressed: _submitLogin,
        onRegisterPressed: _isLoading ? null : _navigateToRegister,
        onContinueWithoutAuth: () => context.go('/home'),
        showSocialLogin: true,
      ),
      onBack: () => Navigator.of(context).pop(),
      onClose: () => Navigator.of(context).pop(),
      showBackButton: true,
      showCloseButton: true,
    );
  }
}
