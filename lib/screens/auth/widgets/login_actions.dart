import 'package:flutter/material.dart';
import 'package:orsocook/utils/responsive_utils.dart';
import 'package:orsocook/theme/app_theme.dart';

class LoginActions extends StatelessWidget {
  final bool isLoading;
  final Function() onLoginPressed;
  final Function()? onRegisterPressed;
  final Function()? onContinueWithoutAuth;
  final bool showSocialLogin;
  final bool isCompact;

  const LoginActions({
    super.key,
    required this.isLoading,
    required this.onLoginPressed,
    this.onRegisterPressed,
    this.onContinueWithoutAuth,
    this.showSocialLogin = true,
    this.isCompact = false,
  });

  Widget _buildLoginButton(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ElevatedButton(
      onPressed: isLoading ? null : onLoginPressed,
      style: ElevatedButton.styleFrom(
        minimumSize:
            Size(double.infinity, ResponsiveValues.buttonHeight(context)),
        backgroundColor: colorScheme.primary,
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Non hai un account? ',
          style: TextStyle(color: Colors.grey),
        ),
        TextButton(
          onPressed: isLoading ? null : onRegisterPressed,
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            'Registrati',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: DarkTheme.registerColor, // 👈 cambiato
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialLogin() {
    if (!showSocialLogin) return const SizedBox.shrink();
    if (isCompact) return const SizedBox.shrink();

    return Column(
      children: [
        const Divider(),
        const SizedBox(height: 12),
        const Text(
          'Oppure accedi con',
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 12),
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
        ? ResponsiveValues.gapMedium(context)
        : ResponsiveValues.gapLarge(context);

    final gapAfterRegister = isCompact
        ? ResponsiveValues.gapSmall(context)
        : ResponsiveValues.gapMedium(context);

    return Column(
      children: [
        _buildLoginButton(context),
        SizedBox(height: gapAfterButton),
        _buildRegisterSection(context),
        if (!isCompact) _buildSocialLogin(),
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
