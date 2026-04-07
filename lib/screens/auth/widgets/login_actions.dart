import 'package:flutter/material.dart';
import 'package:orsocook/utils/responsive_values.dart'; // AGGIUNTO

class LoginActions extends StatelessWidget {
  final bool isLoading;
  final Function() onLoginPressed;
  final Function()? onRegisterPressed;
  final Function()? onContinueWithoutAuth;
  final bool showSocialLogin;

  const LoginActions({
    super.key,
    required this.isLoading,
    required this.onLoginPressed,
    this.onRegisterPressed,
    this.onContinueWithoutAuth,
    this.showSocialLogin = true,
  });

  Widget _buildLoginButton(BuildContext context) {
    // MODIFICATO: aggiunto context
    return ElevatedButton(
      onPressed: isLoading ? null : onLoginPressed,
      style: ElevatedButton.styleFrom(
        minimumSize: Size(double.infinity,
            ResponsiveValues.buttonHeight(context)), // MODIFICATO
        backgroundColor: const Color(0xFF6750A4), // Viola
      ),
      child: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : const Text(
              'ACCEDI',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
    );
  }

  Widget _buildRegisterSection(BuildContext context) {
    // MODIFICATO: aggiunto context
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;

        if (availableWidth < 280) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Non hai un account?',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 4),
              TextButton(
                onPressed: isLoading ? null : onRegisterPressed,
                child: const Text(
                  'Registrati',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.deepOrange,
                  ),
                ),
              ),
            ],
          );
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Flexible(
              child: Text(
                'Non hai un account? ',
                style: TextStyle(color: Colors.grey),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            TextButton(
              onPressed: isLoading ? null : onRegisterPressed,
              child: const Text(
                'Registrati',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.deepOrange,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSocialLogin() {
    if (!showSocialLogin) return const SizedBox.shrink();

    return Column(
      children: [
        const Divider(),
        const SizedBox(height: 16),
        const Text(
          'Oppure accedi con',
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final availableWidth = constraints.maxWidth;

            if (availableWidth < 240) {
              final scaleFactor = availableWidth / 240;
              final iconSize = (40 * scaleFactor).clamp(20.0, 40.0);
              final spacing = (20 * scaleFactor).clamp(8.0, 20.0);

              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.facebook, color: Colors.blue),
                    onPressed: () {},
                    iconSize: iconSize,
                    padding: EdgeInsets.all(4 * scaleFactor),
                  ),
                  SizedBox(width: spacing),
                  IconButton(
                    icon: const Icon(Icons.g_mobiledata, color: Colors.red),
                    onPressed: () {},
                    iconSize: iconSize,
                    padding: EdgeInsets.all(4 * scaleFactor),
                  ),
                ],
              );
            }

            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.facebook, color: Colors.blue),
                  onPressed: () {},
                  iconSize: 40,
                ),
                const SizedBox(width: 20),
                IconButton(
                  icon: const Icon(Icons.g_mobiledata,
                      color: Colors.red, size: 40),
                  onPressed: () {},
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildLoginButton(context), // MODIFICATO: passato context
        SizedBox(height: ResponsiveValues.gapLarge(context)), // MODIFICATO
        _buildRegisterSection(context), // MODIFICATO: passato context
        _buildSocialLogin(),
        if (onContinueWithoutAuth != null) ...[
          SizedBox(height: ResponsiveValues.gapMedium(context)), // MODIFICATO
          TextButton(
            onPressed: onContinueWithoutAuth,
            child: const Text(
              'Continua senza account',
            ),
          ),
        ],
      ],
    );
  }
}
