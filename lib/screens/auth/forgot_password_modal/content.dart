import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:orsocook/services/auth_service.dart';
import 'package:orsocook/utils/logger.dart';
import 'package:orsocook/screens/auth/widgets/auth_error_box.dart';
import 'package:orsocook/screens/auth/widgets/auth_form_wrapper.dart';
import 'package:orsocook/screens/auth/widgets/auth_utils.dart';

class ForgotPasswordModalContent extends StatefulWidget {
  final VoidCallback onClose;
  final bool showCloseButton;
  final VoidCallback? onNavigateToLogin;

  const ForgotPasswordModalContent({
    super.key,
    required this.onClose,
    this.showCloseButton = true,
    this.onNavigateToLogin,
  });

  @override
  State<ForgotPasswordModalContent> createState() =>
      _ForgotPasswordModalContentState();
}

class _ForgotPasswordModalContentState
    extends State<ForgotPasswordModalContent> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  bool _isLoading = false;
  bool _isSuccess = false;
  String? _errorMessage;
  String? _successMessage;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'L\'email è obbligatoria';
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)
        ? null
        : 'Inserisci un\'email valida';
  }

  Future<void> _submitForgotPassword() async {
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
      _successMessage = null;
    });

    try {
      final result = await Provider.of<AuthService>(context, listen: false)
          .forgotPassword(_emailController.text.trim());

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        if (result.success) {
          _isSuccess = true;
          _successMessage = result.message;
          Future.delayed(
            const Duration(seconds: 2),
            () {
              if (mounted) _navigateToLogin();
            },
          );
        } else {
          _errorMessage = result.message;
        }
      });
    } catch (e) {
      AppLogger.debug('forgotPassword error: $e');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Errore di connessione';
      });
    }
  }

  void _navigateToLogin() =>
      AuthUtils.navigateOrClose(widget.onNavigateToLogin, widget.onClose);

  void _clearMessages() {
    if (_errorMessage != null || _successMessage != null) {
      setState(() {
        _errorMessage = null;
        _successMessage = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthFormWrapper(
      formKey: _formKey,
      onClose: widget.onClose,
      showCloseButton: widget.showCloseButton,
      children: [
        _buildLogo(),
        const SizedBox(height: 24),
        _buildEmailField(),
        const SizedBox(height: 16),
        if (_errorMessage != null) AuthErrorBox(message: _errorMessage!),
        if (_isSuccess) _buildSuccessSection(),
        const SizedBox(height: 24),
        _buildSubmitButton(),
        const SizedBox(height: 24),
        _buildLoginLink(),
        const SizedBox(height: 20),
        const Divider(),
        const SizedBox(height: 16),
        const Text(
          'Cosa succede dopo:',
          style: TextStyle(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        _buildStepItem('Riceverai un\'email con un link di reset'),
        _buildStepItem('Clicca sul link (valido per 1 ora)'),
        _buildStepItem('Imposta una nuova password'),
        _buildStepItem('Accedi con la nuova password'),
      ],
    );
  }

  Widget _buildLogo() => Column(
        children: [
          Icon(Icons.lock_reset,
              size: 80, color: Theme.of(context).primaryColor),
          const SizedBox(height: 16),
          const Text(
            'Password dimenticata?',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.deepOrange,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Inserisci la tua email per reimpostare la password',
            style: TextStyle(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      );

  Widget _buildEmailField() => TextFormField(
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
        textInputAction: TextInputAction.done,
        decoration: const InputDecoration(
          labelText: 'Email',
          prefixIcon: Icon(Icons.email),
          border: OutlineInputBorder(),
          filled: true,
          hintText: 'es. mario@esempio.com',
        ),
        validator: _validateEmail,
        onChanged: (_) => _clearMessages(),
        onFieldSubmitted: (_) => _submitForgotPassword(),
      );

  Widget _buildSuccessSection() => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.green[50],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Email inviata!',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _successMessage ??
                  'Riceverai istruzioni per reimpostare la password.',
              style: const TextStyle(color: Colors.green),
            ),
            const SizedBox(height: 16),
            const Text('⚠️ Controlla la cartella spam',
                style: TextStyle(fontSize: 12, color: Colors.orange)),
            const SizedBox(height: 16),
            const Text('Reindirizzamento al login...',
                style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 8),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
            ),
          ],
        ),
      );

  Widget _buildSubmitButton() => ElevatedButton(
        onPressed: _isLoading ? null : _submitForgotPassword,
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 50),
          backgroundColor: Colors.deepOrange,
        ),
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              )
            : const Text(
                'INVIA ISTRUZIONI',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      );

  Widget _buildLoginLink() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Torna al ', style: TextStyle(color: Colors.grey)),
          TextButton(
            onPressed: _isLoading ? null : _navigateToLogin,
            child: const Text(
              'Login',
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.deepOrange),
            ),
          ),
        ],
      );

  Widget _buildStepItem(String text) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0),
        child: Row(
          children: [
            const Icon(Icons.arrow_right, color: Colors.deepOrange, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(text)),
          ],
        ),
      );
}
