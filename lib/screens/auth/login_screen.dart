import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:orsocook/services/auth_service.dart';
import 'package:orsocook/screens/home/home_screen.dart';
import 'package:orsocook/navigation/app_router.dart';
import 'package:orsocook/screens/auth/widgets/login_logo.dart';
import 'package:orsocook/screens/auth/widgets/login_form_fields.dart';
import 'package:orsocook/screens/auth/widgets/login_actions.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback? onLoginSuccess;

  const LoginScreen({super.key, this.onLoginSuccess});

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
    if (!_formKey.currentState!.validate()) {
      return;
    }

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
      setState(() {
        _isLoading = false;
      });

      if (result.success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Login effettuato con successo!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }

        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        }
      } else {
        if (result.requiresVerification) {
          _showEmailNotVerifiedDialog(
            context,
            result.email ?? _emailController.text.trim(),
          );
          return;
        }

        if (result.isLocked) {
          final lockTime = result.lockTime ?? 15;
          _showAccountLockedDialog(context, lockTime);
          return;
        }

        if (mounted) {
          setState(() {
            _errorMessage = result.message;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Errore di connessione';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Errore di connessione. Verifica la rete.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showEmailNotVerifiedDialog(BuildContext context, String email) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('📧 Email Non Verificata'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.mark_email_unread, size: 60, color: Colors.orange),
            const SizedBox(height: 16),
            const Text(
              'Devi verificare la tua email prima di accedere.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              email,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'Controlla la tua posta e clicca sul link di verifica.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _resendVerificationEmail(email);
            },
            child: const Text('RINVIA EMAIL'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('CHIUDI'),
          ),
        ],
      ),
    );
  }

  Future<void> _resendVerificationEmail(String email) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final result = await authService.resendVerificationEmail(email);

      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });

      if (result.success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Nuova email di verifica inviata!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Errore di connessione'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showAccountLockedDialog(BuildContext context, int lockTime) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('🔒 Account Temporaneamente Bloccato'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock_clock, size: 60, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Troppi tentativi di login falliti.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'L\'account è bloccato per $lockTime minuti.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
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

  void _navigateToForgotPassword() {
    if (!mounted) return;
    AppRouter.goToForgotPassword(context);
  }

  void _navigateToHomeWithoutAuth() {
    if (!mounted) return;

    final authService = Provider.of<AuthService>(context, listen: false);
    if (authService.isLoggedIn) {
      authService.logout();
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  void _navigateToRegister() {
    if (!mounted) return;
    Navigator.pushNamed(context, '/register');
  }

  void _handleEmailChanged(String? value) {
    if (_errorMessage != null) {
      setState(() {
        _errorMessage = null;
      });
    }
  }

  void _handlePasswordChanged(String? value) {
    if (_errorMessage != null) {
      setState(() {
        _errorMessage = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _navigateToHomeWithoutAuth,
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
                const LoginLogo(),
                const SizedBox(height: 40),
                LoginFormFields(
                  emailController: _emailController,
                  passwordController: _passwordController,
                  errorMessage: _errorMessage,
                  onEmailChanged: _handleEmailChanged,
                  onPasswordChanged: _handlePasswordChanged,
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
                  onContinueWithoutAuth: _navigateToHomeWithoutAuth,
                  showSocialLogin: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
