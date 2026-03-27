import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:orsocook/services/auth_service.dart';
import 'package:orsocook/screens/auth/login.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String token;

  const ResetPasswordScreen({super.key, required this.token});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _isSuccess = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _errorMessage;
  String? _successMessage;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'La password è obbligatoria';
    if (value.length < 8) return 'Almeno 8 caratteri';
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Almeno una lettera maiuscola';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) return 'Almeno un numero';
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) return 'Conferma la password';
    return value == _passwordController.text
        ? null
        : 'Le password non corrispondono';
  }

  Future<void> _submitResetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final result = await authService.resetPassword(
        widget.token,
        _passwordController.text,
        _confirmPasswordController.text,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (result.success) {
        setState(() {
          _isSuccess = true;
          _successMessage = result.message;
        });
        Future.delayed(const Duration(seconds: 2), _navigateToLogin);
      } else {
        setState(() => _errorMessage = result.message);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Errore di connessione';
      });
    }
  }

  void _navigateToLogin() {
    if (mounted) {
      final navigator = Navigator.of(context);
      navigator.pop();
      Future.delayed(const Duration(milliseconds: 150), () {
        if (mounted) {
          showLoginModal(context);
        }
      });
    }
  }

  void _clearErrorOnChange() {
    if (_errorMessage != null || _successMessage != null) {
      setState(() {
        _errorMessage = null;
        _successMessage = null;
      });
    }
  }

  void _togglePasswordVisibility() =>
      setState(() => _obscurePassword = !_obscurePassword);
  void _toggleConfirmPasswordVisibility() =>
      setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);

  Widget _buildLogo() {
    return Column(
      children: [
        Icon(Icons.lock_open, size: 80, color: Theme.of(context).primaryColor),
        const SizedBox(height: 16),
        const Text('Nuova Password',
            style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.deepOrange)),
        const SizedBox(height: 8),
        const Text('Crea una nuova password per il tuo account',
            style: TextStyle(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center),
      ],
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: 'Nuova Password',
        prefixIcon: const Icon(Icons.lock),
        suffixIcon: IconButton(
          icon:
              Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
          onPressed: _togglePasswordVisibility,
        ),
        border: const OutlineInputBorder(),
        filled: true,
        helperText: 'Minimo 8 caratteri, 1 maiuscola, 1 numero',
      ),
      validator: _validatePassword,
      onChanged: (_) {
        _clearErrorOnChange();
        if (_confirmPasswordController.text.isNotEmpty) {
          _formKey.currentState?.validate();
        }
      },
    );
  }

  Widget _buildConfirmPasswordField() {
    return TextFormField(
      controller: _confirmPasswordController,
      obscureText: _obscureConfirmPassword,
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
        labelText: 'Conferma Nuova Password',
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(_obscureConfirmPassword
              ? Icons.visibility
              : Icons.visibility_off),
          onPressed: _toggleConfirmPasswordVisibility,
        ),
        border: const OutlineInputBorder(),
        filled: true,
      ),
      validator: _validateConfirmPassword,
      onFieldSubmitted: (_) => _submitResetPassword(),
      onChanged: (_) => _clearErrorOnChange(),
    );
  }

  Widget _buildPasswordStrength() {
    if (_passwordController.text.isEmpty) return const SizedBox.shrink();

    final password = _passwordController.text;
    int strength = 0;
    if (password.length >= 8) strength++;
    if (RegExp(r'[A-Z]').hasMatch(password)) strength++;
    if (RegExp(r'[0-9]').hasMatch(password)) strength++;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) strength++;

    final color = strength <= 1
        ? Colors.red
        : strength == 2
            ? Colors.orange
            : strength == 3
                ? Colors.lightGreen
                : Colors.green;
    final text = strength <= 1
        ? 'Debole'
        : strength == 2
            ? 'Media'
            : strength == 3
                ? 'Buona'
                : 'Forte';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text('Forza password: $text',
            style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        LinearProgressIndicator(
            value: strength / 4,
            backgroundColor: Colors.grey[300],
            color: color),
      ],
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
                  child: Text('Password reimpostata!',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.green))),
            ],
          ),
          const SizedBox(height: 8),
          Text(_successMessage ?? 'Password reimpostata con successo!',
              style: const TextStyle(color: Colors.green)),
          const SizedBox(height: 8),
          const Text('Verrai reindirizzato al login...',
              style: TextStyle(fontSize: 12, color: Colors.green)),
          const SizedBox(height: 16),
          const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green)),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _submitResetPassword,
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
          : const Text('REIMPOSTA PASSWORD',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildLoginLink() {
    if (_isSuccess) return const SizedBox.shrink();

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

  Widget _buildRequirementItem(String text) {
    final password = _passwordController.text;
    final bool isMet = switch (text) {
      'Almeno 8 caratteri' => password.length >= 8,
      'Almeno una lettera maiuscola' => RegExp(r'[A-Z]').hasMatch(password),
      'Almeno un numero' => RegExp(r'[0-9]').hasMatch(password),
      'Caratteri speciali consigliati' =>
        RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password),
      _ => false,
    };

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isMet ? Colors.green : Colors.grey[400],
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(text,
              style: TextStyle(color: isMet ? Colors.green : Colors.grey[600])),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reimposta Password'),
        leading: _isSuccess
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _navigateToLogin,
              ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildLogo(),
                const SizedBox(height: 40),
                _buildPasswordField(),
                _buildPasswordStrength(),
                const SizedBox(height: 16),
                _buildConfirmPasswordField(),
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
                const Text('Requisiti password:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center),
                const SizedBox(height: 12),
                _buildRequirementItem('Almeno 8 caratteri'),
                _buildRequirementItem('Almeno una lettera maiuscola'),
                _buildRequirementItem('Almeno un numero'),
                _buildRequirementItem('Caratteri speciali consigliati'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
