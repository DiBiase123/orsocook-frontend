import 'package:flutter/material.dart';

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

  Widget _buildLoginButton() {
    return ElevatedButton(
      onPressed: isLoading ? null : onLoginPressed,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
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

  Widget _buildRegisterSection() {
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
        _buildLoginButton(),
        const SizedBox(height: 24),
        _buildRegisterSection(),
        _buildSocialLogin(),
        if (onContinueWithoutAuth != null) ...[
          const SizedBox(height: 20),
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
