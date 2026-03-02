import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:orsocook/services/favorite_service.dart';
import 'package:orsocook/services/auth_service.dart';
import 'package:orsocook/utils/logger.dart';
import 'package:orsocook/models/recipe.dart';

class FavoriteButton extends StatefulWidget {
  final String recipeId;
  final Recipe? recipe;
  final double size;
  final Color? color;
  final bool showLoading;
  final VoidCallback? onToggle;

  const FavoriteButton({
    super.key,
    required this.recipeId,
    this.recipe,
    this.size = 24.0,
    this.color,
    this.showLoading = true,
    this.onToggle,
  });

  @override
  State<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton> {
  bool _isProcessing = false;
  bool _isFavorite = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInitialState();
  }

  Future<void> _loadInitialState() async {
    final favoriteService =
        Provider.of<FavoriteService>(context, listen: false);

    try {
      final isFavorite = await favoriteService.isFavorite(widget.recipeId);
      if (mounted) {
        setState(() {
          _isFavorite = isFavorite;
          _isLoading = false;
        });
      }
    } catch (e) {
      AppLogger.error('Error loading favorite state', e);
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _toggleFavorite(FavoriteService favoriteService) async {
    if (_isProcessing) return;

    final authService = Provider.of<AuthService>(context, listen: false);

    if (!authService.isLoggedIn) {
      _showLoginPrompt();
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final success = await favoriteService.toggleFavorite(widget.recipeId);

      if (success && mounted) {
        // Ricarica lo stato dopo il toggle
        final newState = await favoriteService.isFavorite(widget.recipeId);

        setState(() {
          _isFavorite = newState;
          _isProcessing = false;
        });

        // Notifica callback se fornito
        widget.onToggle?.call();

        // Mostra feedback
        _showSuccessSnackbar(
            newState ? 'Aggiunto ai preferiti' : 'Rimosso dai preferiti');

        AppLogger.success(newState
            ? 'Recipe ${widget.recipeId} added to favorites'
            : 'Recipe ${widget.recipeId} removed from favorites');
      } else {
        setState(() => _isProcessing = false);
        _showErrorSnackbar('Errore durante l\'operazione');
      }
    } catch (e) {
      AppLogger.error('Error toggling favorite', e);
      if (mounted) {
        setState(() => _isProcessing = false);
      }
      _showErrorSnackbar('Errore: ${e.toString()}');
    }
  }

  void _showLoginPrompt() {
    AppLogger.auth('User not logged in, showing login prompt');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Accedi per salvare le ricette preferite'),
        backgroundColor: Colors.orange[800],
        action: SnackBarAction(
          label: 'ACCEDI',
          textColor: Colors.white,
          onPressed: () {
            context.go('/login');
          },
        ),
      ),
    );
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final isLoggedIn = authService.isLoggedIn;

    if (!isLoggedIn) {
      return IconButton(
        iconSize: widget.size,
        icon: Icon(
          Icons.favorite_border,
          color: widget.color ?? Colors.grey,
        ),
        onPressed: _showLoginPrompt,
        tooltip: 'Accedi per aggiungere ai preferiti',
      );
    }

    if (_isLoading && widget.showLoading) {
      return SizedBox(
        width: widget.size,
        height: widget.size,
        child: const Center(
          child: SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    if (_isProcessing && widget.showLoading) {
      return SizedBox(
        width: widget.size,
        height: widget.size,
        child: const Center(
          child: SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    return IconButton(
      iconSize: widget.size,
      icon: Icon(
        _isFavorite ? Icons.favorite : Icons.favorite_border,
        color: _isFavorite ? Colors.red : widget.color ?? Colors.grey[700],
      ),
      onPressed: () =>
          _toggleFavorite(Provider.of<FavoriteService>(context, listen: false)),
      tooltip: _isFavorite ? 'Rimuovi dai preferiti' : 'Aggiungi ai preferiti',
    );
  }
}
