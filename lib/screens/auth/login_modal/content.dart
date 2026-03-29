import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:orsocook/services/auth_service.dart';
import 'package:orsocook/screens/auth/widgets/login_logo.dart';
import 'package:orsocook/screens/auth/widgets/login_form_fields.dart';
import 'package:orsocook/screens/auth/widgets/login_actions.dart';
import 'package:orsocook/screens/auth/widgets/auth_form_wrapper.dart';
import 'package:orsocook/screens/auth/widgets/auth_utils.dart';

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
    await AuthUtils.submitWithFormGuard(
      formKey: _formKey,
      mounted: mounted,
      onSubmit: _doSubmit,
    );
  }

  Future<void> _doSubmit() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result =
          await Provider.of<AuthService>(context, listen: false).login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (result.success) {
        AuthUtils.showAuthSnackBar(context,
            message: 'Login effettuato con successo!', color: Colors.green);
        widget.onClose();
      } else {
        _handleLoginError(result);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      AuthUtils.showAuthSnackBar(context, message: 'Errore di connessione');
    }
  }

  void _handleLoginError(dynamic result) {
    if (result.requiresVerification) {
      _showEmailNotVerifiedDialog(result.email ?? _emailController.text.trim());
    } else if (result.isLocked) {
      _showAccountLockedDialog(result.lockTime ?? 15);
    } else {
      setState(() => _errorMessage = result.message);
      AuthUtils.showAuthSnackBar(context, message: result.message);
    }
  }

  Future<void> _resendVerificationEmail(String email) async {
    setState(() => _isLoading = true);
    Navigator.of(context).pop();

    try {
      final result = await Provider.of<AuthService>(context, listen: false)
          .resendVerificationEmail(email);

      if (!mounted) return;
      setState(() => _isLoading = false);
      AuthUtils.showAuthSnackBar(context,
          message: result.message,
          color: result.success ? Colors.green : Colors.red);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      AuthUtils.showAuthSnackBar(context, message: 'Errore di connessione');
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

  void _navigateToForgotPassword() => AuthUtils.navigateOrClose(
      widget.onNavigateToForgotPassword, widget.onClose);

  void _navigateToRegister() =>
      AuthUtils.navigateOrClose(widget.onNavigateToRegister, widget.onClose);

  void _clearErrorOnChange() {
    if (_errorMessage != null) setState(() => _errorMessage = null);
  }

  @override
  Widget build(BuildContext context) {
    return AuthFormWrapper(
      formKey: _formKey,
      onClose: widget.onClose,
      showCloseButton: widget.showCloseButton,
      children: [
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
    );
  }
}
