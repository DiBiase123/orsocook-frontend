import 'package:flutter/material.dart';

class LoginFormFields extends StatefulWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final String? errorMessage;
  final Function(String?) onEmailChanged;
  final Function(String?) onPasswordChanged;
  final Function()? onForgotPasswordPressed;
  final Function()? onSubmitted; // <-- NUOVO: callback per invio da tastiera
  final bool isLoading;

  const LoginFormFields({
    super.key,
    required this.emailController,
    required this.passwordController,
    this.errorMessage,
    required this.onEmailChanged,
    required this.onPasswordChanged,
    this.onForgotPasswordPressed,
    this.onSubmitted, // <-- NUOVO parametro
    required this.isLoading,
  });

  @override
  State<LoginFormFields> createState() => _LoginFormFieldsState();
}

class _LoginFormFieldsState extends State<LoginFormFields> {
  bool _obscurePassword = true;

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'L\'email è obbligatoria';
    }
    if (!value.contains('@') || !value.contains('.')) {
      return 'Inserisci un\'email valida';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'La password è obbligatoria';
    }
    if (value.length < 6) {
      return 'La password deve avere almeno 6 caratteri';
    }
    return null;
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: widget.emailController,
      keyboardType: TextInputType.emailAddress,
      autofillHints: const [AutofillHints.email],
      textInputAction: TextInputAction.next,
      decoration: const InputDecoration(
        labelText: 'Email',
        prefixIcon: Icon(Icons.email),
        border: OutlineInputBorder(),
        filled: true,
      ),
      validator: _validateEmail,
      onChanged: (value) {
        widget.onEmailChanged(value);
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: widget.passwordController,
      obscureText: _obscurePassword,
      autofillHints: const [AutofillHints.password],
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
        labelText: 'Password',
        prefixIcon: const Icon(Icons.lock),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        ),
        border: const OutlineInputBorder(),
        filled: true,
      ),
      validator: _validatePassword,
      onFieldSubmitted: (_) {
        // Invoca il callback quando si preme "invio" sulla tastiera
        if (widget.onSubmitted != null) {
          widget.onSubmitted!();
        }
      },
      onChanged: (value) {
        widget.onPasswordChanged(value);
      },
    );
  }

  Widget _buildErrorSection() {
    if (widget.errorMessage == null) return const SizedBox.shrink();

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
            child: Text(
              widget.errorMessage!,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildEmailField(),
        const SizedBox(height: 20),
        _buildPasswordField(),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: widget.isLoading ? null : widget.onForgotPasswordPressed,
            child: const Text(
              'Password dimenticata?',
              style: TextStyle(color: Colors.blue),
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildErrorSection(),
      ],
    );
  }
}
