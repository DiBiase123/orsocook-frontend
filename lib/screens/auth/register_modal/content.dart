import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:orsocook/services/auth_service.dart';
import 'package:orsocook/screens/auth/login.dart';
import 'package:orsocook/screens/auth/widgets/register_logo.dart';
import 'package:orsocook/screens/auth/widgets/register_form_fields.dart';
import 'package:orsocook/screens/auth/widgets/register_actions.dart';
import 'package:orsocook/screens/auth/widgets/terms_checkbox.dart';

class RegisterModalContent extends StatefulWidget {
  final VoidCallback onClose;
  final bool showCloseButton;

  const RegisterModalContent({
    super.key,
    required this.onClose,
    this.showCloseButton = true,
  });

  @override
  State<RegisterModalContent> createState() => _RegisterModalContentState();
}

class _RegisterModalContentState extends State<RegisterModalContent> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;
  bool _acceptTerms = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submitRegistration() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_acceptTerms) {
      _showSnackBar('Devi accettare i termini e condizioni', Colors.orange);
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final result = await authService.registerWithVerification(
        _usernameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (result.success) {
        if (result.requiresVerification) {
          _showVerificationDialog(_emailController.text.trim());
        } else {
          _showSuccessDialog();
        }
      } else {
        setState(() => _errorMessage = result.message);
        _showSnackBar(result.message, Colors.red);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Errore di connessione';
      });
      _showSnackBar('Errore di connessione', Colors.red);
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

  void _showVerificationDialog(String email) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('🎉 Registrazione Completata!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.mark_email_unread, size: 70, color: Colors.blue),
            const SizedBox(height: 20),
            const Text('Abbiamo inviato un\'email di verifica a:'),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(email, textAlign: TextAlign.center),
            ),
            const SizedBox(height: 20),
            const Text('Per attivare il tuo account:'),
            const SizedBox(height: 10),
            _buildStep('Controlla la tua casella email', Icons.inbox),
            _buildStep('Cerca l\'email di OrsoCook', Icons.search),
            _buildStep('Clicca sul link di verifica', Icons.link),
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('⚠️ Controlla la cartella SPAM'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              widget.onClose();
            },
            child: const Text('HO CAPITO'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('✅ Registrazione Completata!'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, size: 70, color: Colors.green),
            SizedBox(height: 20),
            Text('Account creato con successo!\n\nOra puoi accedere.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              widget.onClose();
            },
            child: const Text('ACCEDI'),
          ),
        ],
      ),
    );
  }

  Widget _buildStep(String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  void _clearErrorOnChange() {
    if (_errorMessage != null) setState(() => _errorMessage = null);
  }

  void _navigateToLogin() {
    widget.onClose();
    showLoginModal(context);
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
              const RegisterLogo(),
              const SizedBox(height: 24),
              RegisterFormFields(
                usernameController: _usernameController,
                emailController: _emailController,
                passwordController: _passwordController,
                confirmPasswordController: _confirmPasswordController,
                errorMessage: _errorMessage,
                onUsernameChanged: (_) => _clearErrorOnChange(),
                onEmailChanged: (_) => _clearErrorOnChange(),
                onPasswordChanged: (_) => _clearErrorOnChange(),
                onConfirmPasswordChanged: (_) => _clearErrorOnChange(),
                isLoading: _isLoading,
                validateForm: () => _formKey.currentState?.validate(),
              ),
              const SizedBox(height: 16),
              TermsCheckbox(
                value: _acceptTerms,
                onChanged: (value) => setState(() => _acceptTerms = value),
                isLoading: _isLoading,
              ),
              const SizedBox(height: 24),
              RegisterActions(
                isLoading: _isLoading,
                onRegisterPressed: _submitRegistration,
                onLoginPressed: _isLoading ? null : _navigateToLogin,
                showFeatures: true,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
