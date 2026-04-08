import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:orsocook/services/auth_service.dart';
import 'package:orsocook/screens/auth/widgets/register_logo.dart';
import 'package:orsocook/screens/auth/widgets/register_form_fields.dart';
import 'package:orsocook/screens/auth/widgets/register_actions.dart';
import 'package:orsocook/screens/auth/widgets/terms_checkbox.dart';
import 'package:orsocook/screens/auth/widgets/auth_form_wrapper.dart';
import 'package:orsocook/screens/auth/widgets/auth_form_wrapper/auth_form_wrapper_mobile.dart';
import 'package:orsocook/screens/auth/widgets/auth_utils.dart';

class RegisterModalContent extends StatefulWidget {
  final VoidCallback onClose;
  final bool showCloseButton;
  final VoidCallback? onNavigateToLogin;

  const RegisterModalContent({
    super.key,
    required this.onClose,
    this.showCloseButton = true,
    this.onNavigateToLogin,
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
    await AuthUtils.submitWithFormGuard(
      formKey: _formKey,
      mounted: mounted,
      onSubmit: _doSubmit,
    );
  }

  Future<void> _doSubmit() async {
    if (!_acceptTerms) {
      AuthUtils.showAuthSnackBar(context,
          message: 'Devi accettare i termini e condizioni',
          color: Colors.orange);
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await Provider.of<AuthService>(context, listen: false)
          .registerWithVerification(
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
        AuthUtils.showAuthSnackBar(context, message: result.message);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Errore di connessione';
      });
      AuthUtils.showAuthSnackBar(context, message: 'Errore di connessione');
    }
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
              _navigateToLogin();
            },
            child: const Text('ACCEDI'),
          ),
        ],
      ),
    );
  }

  Widget _buildStep(String text, IconData icon) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0),
        child: Row(
          children: [
            Icon(icon, color: Colors.blue, size: 20),
            const SizedBox(width: 10),
            Expanded(child: Text(text)),
          ],
        ),
      );

  void _clearErrorOnChange() {
    if (_errorMessage != null) setState(() => _errorMessage = null);
  }

  void _navigateToLogin() =>
      AuthUtils.navigateOrClose(widget.onNavigateToLogin, widget.onClose);

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    if (isMobile) {
      return AuthFormWrapperMobile(
        formKey: _formKey,
        onClose: widget.onClose,
        showCloseButton: widget.showCloseButton,
        title: 'Registrati',
        headerColor: Colors.deepOrange.shade200,
        children: [
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
      );
    }

    return AuthFormWrapper(
      formKey: _formKey,
      onClose: widget.onClose,
      showCloseButton: widget.showCloseButton,
      title: 'Registrati',
      children: [
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
    );
  }
}
