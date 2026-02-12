import 'package:flutter/material.dart';
import 'package:orsocook/screens/auth/widgets/password_strength_indicator.dart';

class RegisterFormFields extends StatefulWidget {
  final TextEditingController usernameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final String? errorMessage;
  final Function(String?) onUsernameChanged;
  final Function(String?) onEmailChanged;
  final Function(String?) onPasswordChanged;
  final Function(String?) onConfirmPasswordChanged;
  final bool isLoading;
  final Function()? validateForm;

  const RegisterFormFields({
    super.key,
    required this.usernameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    this.errorMessage,
    required this.onUsernameChanged,
    required this.onEmailChanged,
    required this.onPasswordChanged,
    required this.onConfirmPasswordChanged,
    required this.isLoading,
    this.validateForm,
  });

  @override
  State<RegisterFormFields> createState() => _RegisterFormFieldsState();
}

class _RegisterFormFieldsState extends State<RegisterFormFields> {
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  String? _validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Il nome utente è obbligatorio';
    }
    if (value.length < 3) {
      return 'Almeno 3 caratteri';
    }
    if (value.length > 20) {
      return 'Massimo 20 caratteri';
    }
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
      return 'Solo lettere, numeri e underscore';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'L\'email è obbligatoria';
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
      return 'Inserisci un\'email valida';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'La password è obbligatoria';
    }
    if (value.length < 8) {
      return 'Almeno 8 caratteri';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Almeno una lettera maiuscola';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Almeno un numero';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Conferma la password';
    }
    if (value != widget.passwordController.text) {
      return 'Le password non corrispondono';
    }
    return null;
  }

  Widget _buildUsernameField() {
    return TextFormField(
      controller: widget.usernameController,
      textInputAction: TextInputAction.next,
      decoration: const InputDecoration(
        labelText: 'Nome utente',
        prefixIcon: Icon(Icons.person),
        border: OutlineInputBorder(),
        filled: true,
        hintText: 'es. chef_mario',
      ),
      validator: _validateUsername,
      onChanged: (value) {
        widget.onUsernameChanged(value);
      },
    );
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
        hintText: 'es. mario@esempio.com',
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
      textInputAction: TextInputAction.next,
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
        helperText: 'Minimo 8 caratteri, 1 maiuscola, 1 numero',
      ),
      validator: _validatePassword,
      onChanged: (value) {
        widget.onPasswordChanged(value);
        if (widget.confirmPasswordController.text.isNotEmpty &&
            widget.validateForm != null) {
          widget.validateForm!();
        }
      },
    );
  }

  Widget _buildConfirmPasswordField() {
    return TextFormField(
      controller: widget.confirmPasswordController,
      obscureText: _obscureConfirmPassword,
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
        labelText: 'Conferma Password',
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(
            _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: () {
            setState(() {
              _obscureConfirmPassword = !_obscureConfirmPassword;
            });
          },
        ),
        border: const OutlineInputBorder(),
        filled: true,
      ),
      validator: _validateConfirmPassword,
      onChanged: (value) {
        widget.onConfirmPasswordChanged(value);
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
        _buildUsernameField(),
        const SizedBox(height: 16),
        _buildEmailField(),
        const SizedBox(height: 16),
        _buildPasswordField(),
        PasswordStrengthIndicator(password: widget.passwordController.text),
        const SizedBox(height: 16),
        _buildConfirmPasswordField(),
        const SizedBox(height: 16),
        _buildErrorSection(),
      ],
    );
  }
}
