import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:orsocook/services/auth_service.dart';
import 'package:orsocook/utils/logger.dart';
import 'package:orsocook/screens/auth/widgets/register_logo.dart';
import 'package:orsocook/screens/auth/widgets/register_form_fields.dart';
import 'package:orsocook/screens/auth/widgets/register_actions.dart';
import 'package:orsocook/screens/auth/widgets/terms_checkbox.dart';

class RegisterScreen extends StatefulWidget {
  final VoidCallback? onRegisterSuccess;

  const RegisterScreen({super.key, this.onRegisterSuccess});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;
  bool _acceptTerms = false;

  @override
  void initState() {
    super.initState();
    AppLogger.auth('🔐 RegisterScreen inizializzata');
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
    AppLogger.debug('♻️ RegisterScreen disposed');
  }

  Future<void> _submitRegistration() async {
    final currentState = _formKey.currentState;
    if (currentState == null || !currentState.validate()) {
      AppLogger.debug('❌ Form non valido o currentState null');
      return;
    }

    // Salva context localmente prima di operazioni async
    final currentContext = context;

    if (!_acceptTerms) {
      AppLogger.debug('❌ Termini non accettati');

      if (currentContext.mounted) {
        ScaffoldMessenger.of(currentContext).showSnackBar(
          const SnackBar(
            content: Text('Devi accettare i termini e condizioni'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
      }
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    AppLogger.auth(
        '🔄 Tentativo registrazione: ${_usernameController.text} (${_emailController.text})');

    try {
      final authService =
          Provider.of<AuthService>(currentContext, listen: false);

      final result = await authService.registerWithVerification(
        _usernameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (currentContext.mounted) {
        setState(() {
          _isLoading = false;
        });
      }

      if (result.success) {
        AppLogger.success(
            '✅ Registrazione riuscita per: ${_usernameController.text}');

        final String email = _emailController.text.trim();

        // 👇 MOSTRA SOLO IL DIALOG - NO SNACKBAR
        if (result.requiresVerification && currentContext.mounted) {
          await _showVerificationDialog(currentContext, email);
        } else {
          // Caso raro: registrazione senza verifica (dovrebbe accadere solo in test)
          if (currentContext.mounted) {
            await _showSuccessDialog(currentContext);
          }
        }

        // Callback per successo
        widget.onRegisterSuccess?.call();
      } else {
        AppLogger.error('❌ Registrazione fallita: ${result.message}');

        if (currentContext.mounted) {
          setState(() {
            _errorMessage = result.message;
          });

          ScaffoldMessenger.of(currentContext).showSnackBar(
            SnackBar(
              content: Text(result.message),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    } catch (e) {
      if (currentContext.mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Errore di connessione';
        });
      }

      AppLogger.error('❌ Errore durante la registrazione', e);

      if (currentContext.mounted) {
        ScaffoldMessenger.of(currentContext).showSnackBar(
          const SnackBar(
            content: Text('Errore di connessione. Verifica la rete.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 4),
          ),
        );
      }
    }
  }

  // 👇 DIALOG PER VERIFICA EMAIL (caso principale)
  Future<void> _showVerificationDialog(
      BuildContext context, String email) async {
    await showDialog(
      context: context,
      barrierDismissible: false, // L'utente DEVE cliccare
      builder: (context) => AlertDialog(
        title: const Text(
          '🎉 Registrazione Completata!',
          textAlign: TextAlign.center,
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.mark_email_unread, size: 70, color: Colors.blue),
              const SizedBox(height: 20),
              const Text(
                'Abbiamo inviato un\'email di verifica a:',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[100]!),
                ),
                child: Text(
                  email,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                    fontSize: 15,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Per attivare il tuo account:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              _buildStep('1️⃣ Controlla la tua casella email', Icons.inbox),
              _buildStep('2️⃣ Cerca l\'email di OrsoCook', Icons.search),
              _buildStep('3️⃣ Clicca sul link di verifica', Icons.link),
              const SizedBox(height: 15),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange[100]!),
                ),
                child: const Text(
                  '⚠️ Se non trovi l\'email, controlla la cartella SPAM/Posta indesiderata',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.orange,
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Chiude il dialog
              context.go('/login'); // Vai al login
            },
            child: const Text('HO CAPITO',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // 👇 DIALOG PER SUCCESSO SENZA VERIFICA (solo per test/backup)
  Future<void> _showSuccessDialog(BuildContext context) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('✅ Registrazione Completata!'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, size: 70, color: Colors.green),
            SizedBox(height: 20),
            Text(
              'Il tuo account è stato creato con successo!\n\n'
              'Ora puoi accedere con le tue credenziali.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Chiude il dialog
              context.go('/login'); // Vai al login
            },
            child: const Text('ACCEDI'),
          ),
        ],
      ),
    );
  }

  // 👇 Widget per i passaggi nel dialog
  Widget _buildStep(String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  void _handleUsernameChanged(String? value) {
    if (_errorMessage != null) {
      setState(() {
        _errorMessage = null;
      });
    }
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

  void _handleConfirmPasswordChanged(String? value) {
    if (_errorMessage != null) {
      setState(() {
        _errorMessage = null;
      });
    }
  }

  void _handleTermsChanged(bool value) {
    AppLogger.debug('📝 Termini accettati: $value');
    setState(() {
      _acceptTerms = value;
    });
  }

  void _navigateToLogin() {
    AppLogger.navigation('⬅️ Torna a LoginScreen');
    if (mounted) {
      context.go('/login');
    }
  }

  void _validateForm() {
    _formKey.currentState?.validate();
  }

  @override
  Widget build(BuildContext context) {
    AppLogger.debug('🏗️ Building RegisterScreen');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrazione'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            AppLogger.navigation('⬅️ Torna indietro da RegisterScreen');
            if (mounted) {
              context.go('/login');
            }
          },
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
                const RegisterLogo(),
                const SizedBox(height: 32),
                RegisterFormFields(
                  usernameController: _usernameController,
                  emailController: _emailController,
                  passwordController: _passwordController,
                  confirmPasswordController: _confirmPasswordController,
                  errorMessage: _errorMessage,
                  onUsernameChanged: _handleUsernameChanged,
                  onEmailChanged: _handleEmailChanged,
                  onPasswordChanged: _handlePasswordChanged,
                  onConfirmPasswordChanged: _handleConfirmPasswordChanged,
                  isLoading: _isLoading,
                  validateForm: _validateForm,
                ),
                const SizedBox(height: 16),
                TermsCheckbox(
                  value: _acceptTerms,
                  onChanged: _handleTermsChanged,
                  isLoading: _isLoading,
                ),
                const SizedBox(height: 24),
                RegisterActions(
                  isLoading: _isLoading,
                  onRegisterPressed: _submitRegistration,
                  onLoginPressed: _isLoading ? null : _navigateToLogin,
                  showFeatures: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
