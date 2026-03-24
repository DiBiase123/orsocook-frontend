import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:orsocook/services/auth_service.dart';
import 'package:orsocook/utils/logger.dart';
import 'package:orsocook/screens/auth/login.dart';

class ForgotPasswordModalContent extends StatefulWidget {
  final VoidCallback onClose;

  const ForgotPasswordModalContent({
    super.key,
    required this.onClose,
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

    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return emailRegex.hasMatch(value) ? null : 'Inserisci un\'email valida';
  }

  Future<void> _submitForgotPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final result =
          await authService.forgotPassword(_emailController.text.trim());

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        if (result.success) {
          _isSuccess = true;
          _successMessage = result.message;
        } else {
          _errorMessage = result.message;
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Errore di connessione';
      });
      AppLogger.error('Errore reset password', e);
    }
  }

  void _navigateToLogin() {
    widget.onClose();
    showLoginModal(context);
  }

  Widget _buildLogo() {
    return Column(
      children: [
        Icon(Icons.lock_reset, size: 80, color: Theme.of(context).primaryColor),
        const SizedBox(height: 16),
        const Text(
          'Password dimenticata?',
          style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.deepOrange),
        ),
        const SizedBox(height: 8),
        const Text(
          'Inserisci la tua email per reimpostare la password',
          style: TextStyle(fontSize: 16, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      autofillHints: const [AutofillHints.email],
      textInputAction: TextInputAction.done,
      decoration: const InputDecoration(
        labelText: 'Email',
        prefixIcon: Icon(Icons.email),
        border: OutlineInputBorder(),
        filled: true,
        hintText: 'es. mario@esempio.com',
      ),
      validator: _validateEmail,
      onChanged: (_) {
        if (_errorMessage != null || _successMessage != null) {
          setState(() {
            _errorMessage = null;
            _successMessage = null;
          });
        }
      },
      onFieldSubmitted: (_) => _submitForgotPassword(),
    );
  }

  Widget _buildErrorSection() {
    if (_errorMessage == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red[100]!),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(width: 12),
          Expanded(
              child: Text(_errorMessage!,
                  style: const TextStyle(color: Colors.red))),
        ],
      ),
    );
  }

  Widget _buildSuccessSection() {
    if (!_isSuccess) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green[100]!),
      ),
      child: Column(
        children: [
          const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 12),
              Expanded(
                  child: Text('Email inviata!',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.green))),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _successMessage ??
                'Riceverai istruzioni per reimpostare la password.',
            style: const TextStyle(color: Colors.green),
          ),
          const SizedBox(height: 16),
          const Text(
            '⚠️ Controlla la cartella spam',
            style: TextStyle(
                fontSize: 12,
                color: Colors.orange,
                fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
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
                  strokeWidth: 2, color: Colors.white))
          : const Text('INVIA ISTRUZIONI',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Torna al ', style: TextStyle(color: Colors.grey)),
        TextButton(
          onPressed: _isLoading ? null : _navigateToLogin,
          child: const Text('Login',
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.deepOrange)),
        ),
      ],
    );
  }

  Widget _buildStepItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.arrow_right, color: Colors.deepOrange, size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Pulsante back in alto a sinistra
                IconButton(
                  icon: const Icon(Icons.arrow_back, size: 28),
                  onPressed: _navigateToLogin,
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.grey.withAlpha(50),
                    foregroundColor: Theme.of(context).colorScheme.primary,
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(8),
                  ),
                  iconSize: 28,
                ),
                // Pulsante X in alto a destra
                IconButton(
                  icon: const Icon(Icons.close, size: 28),
                  onPressed: widget.onClose,
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.grey.withAlpha(50),
                    foregroundColor: Theme.of(context).colorScheme.primary,
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(8),
                  ),
                  iconSize: 28,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildLogo(),
            const SizedBox(height: 24),
            _buildEmailField(),
            const SizedBox(height: 16),
            _buildErrorSection(),
            _buildSuccessSection(),
            const SizedBox(height: 24),
            _buildSubmitButton(),
            const SizedBox(height: 24),
            _buildLoginLink(),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 16),
            const Text('Cosa succede dopo:',
                style: TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center),
            const SizedBox(height: 12),
            _buildStepItem('1. Riceverai un\'email con un link di reset'),
            _buildStepItem('2. Clicca sul link (valido per 1 ora)'),
            _buildStepItem('3. Imposta una nuova password'),
            _buildStepItem('4. Accedi con la nuova password'),
          ],
        ),
      ),
    );
  }
}
