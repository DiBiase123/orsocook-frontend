import 'package:flutter/material.dart';
import 'package:orsocook/utils/responsive_values.dart';

class LoginActions extends StatelessWidget {
  final bool isLoading;
  final Function() onLoginPressed;
  final Function()? onRegisterPressed;
  final Function()? onContinueWithoutAuth;
  final bool showSocialLogin;
  final bool isCompact; // 👈 NUOVO: per modalità compatta

  const LoginActions({
    super.key,
    required this.isLoading,
    required this.onLoginPressed,
    this.onRegisterPressed,
    this.onContinueWithoutAuth,
    this.showSocialLogin = true,
    this.isCompact = false, // 👈 default false
  });

  Widget _buildLoginButton(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onLoginPressed,
      style: ElevatedButton.styleFrom(
        minimumSize:
            Size(double.infinity, ResponsiveValues.buttonHeight(context)),
        backgroundColor: const Color(0xFF6750A4),
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

    // In modalità compatta, nascondi la sezione social
    if (isCompact) return const SizedBox.shrink();

    return Column(
      children: [
        const Divider(),
        const SizedBox(height: 12), // ridotto da 16
        const Text(
          'Oppure accedi con',
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 12), // ridotto da 16
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
    final gapAfterButton = isCompact
        ? ResponsiveValues.gapMedium(context) // ridotto
        : ResponsiveValues.gapLarge(context);

    final gapAfterRegister = isCompact
        ? ResponsiveValues.gapSmall(context) // ridotto
        : ResponsiveValues.gapMedium(context);

    return Column(
      children: [
        _buildLoginButton(context),
        SizedBox(height: gapAfterButton),
        _buildRegisterSection(context),
        if (!isCompact) _buildSocialLogin(), // solo in modalità normale
        if (onContinueWithoutAuth != null) ...[
          SizedBox(height: gapAfterRegister),
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
