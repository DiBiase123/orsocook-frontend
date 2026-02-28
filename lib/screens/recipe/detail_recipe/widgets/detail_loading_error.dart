import 'package:flutter/material.dart';

class DetailLoadingWidget extends StatelessWidget {
  const DetailLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 24),
          Text('Caricamento ricetta...'),
        ],
      ),
    );
  }
}

class DetailErrorWidget extends StatelessWidget {
  final String? error;
  final VoidCallback onRetry;

  const DetailErrorWidget({
    super.key,
    this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 24),
          Text(
            error ?? 'Errore sconosciuto',
            style: const TextStyle(color: Colors.red, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            child: const Text('RIPROVA'),
          ),
        ],
      ),
    );
  }
}
