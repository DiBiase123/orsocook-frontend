import 'package:flutter/material.dart';
import 'package:orsocook/screens/auth/widgets/auth_error_box.dart';
import 'package:orsocook/utils/responsive_values.dart'; // AGGIUNTO

class LoginFormFields extends StatefulWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final String? errorMessage;
  final Function(String?) onEmailChanged;
  final Function(String?) onPasswordChanged;
  final Function()? onForgotPasswordPressed;
  final Function()? onSubmitted;
  final bool isLoading;

  const LoginFormFields({
    super.key,
    required this.emailController,
    required this.passwordController,
    this.errorMessage,
    required this.onEmailChanged,
    required this.onPasswordChanged,
    this.onForgotPasswordPressed,
    this.onSubmitted,
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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
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
          onChanged: widget.onEmailChanged,
        ),
        SizedBox(height: ResponsiveValues.gapMedium(context)), // MODIFICATO
        TextFormField(
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
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
            border: const OutlineInputBorder(),
            filled: true,
          ),
          validator: _validatePassword,
          onFieldSubmitted: (_) {
            if (widget.onSubmitted != null) {
              widget.onSubmitted!();
            }
          },
          onChanged: widget.onPasswordChanged,
        ),
        SizedBox(height: ResponsiveValues.gapSmall(context)), // MODIFICATO
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
        SizedBox(height: ResponsiveValues.gapSmall(context)), // MODIFICATO
        if (widget.errorMessage != null)
          AuthErrorBox(message: widget.errorMessage!),
      ],
    );
  }
}
