import 'package:flutter/material.dart';
import 'package:orsocook/utils/responsive_values.dart';

class RegisterActions extends StatelessWidget {
  final bool isLoading;
  final Function() onRegisterPressed;
  final Function()? onLoginPressed;
  final bool showFeatures;

  const RegisterActions({
    super.key,
    required this.isLoading,
    required this.onRegisterPressed,
    this.onLoginPressed,
    this.showFeatures = true,
  });

  Widget _buildRegisterButton(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ElevatedButton(
      onPressed: isLoading ? null : onRegisterPressed,
      style: ElevatedButton.styleFrom(
        minimumSize:
            Size(double.infinity, ResponsiveValues.buttonHeight(context)),
        backgroundColor: colorScheme.tertiary,
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
              'REGISTRATI',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
    );
  }

  Widget _buildLoginLink(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Hai già un account? ',
          style: TextStyle(color: Colors.grey),
        ),
        TextButton(
          onPressed: isLoading ? null : onLoginPressed,
          child: Text(
            'Accedi',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 20),
          const SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }

  Widget _buildFeaturesSection() {
    if (!showFeatures) return const SizedBox.shrink();

    return Column(
      children: [
        const Divider(),
        const SizedBox(height: 16),
        const Text(
          'Registrandoti, potrai:',
          style: TextStyle(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        _buildFeatureItem('Creare e salvare le tue ricette'),
        _buildFeatureItem('Commentare altre ricette'),
        _buildFeatureItem('Salvare ricette preferite'),
        _buildFeatureItem('Ricevere notifiche personalizzate'),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildRegisterButton(context),
        SizedBox(height: ResponsiveValues.gapLarge(context)),
        _buildLoginLink(context),
        _buildFeaturesSection(),
      ],
    );
  }
}
