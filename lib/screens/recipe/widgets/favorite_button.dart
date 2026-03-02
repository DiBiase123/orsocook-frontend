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
  late FavoriteService _favoriteService;

  @override
  void initState() {
    super.initState();
    _favoriteService = Provider.of<FavoriteService>(context, listen: false);
    _loadInitialState();
    _favoriteService.addListener(_onFavoriteChanged);
  }

  @override
  void didUpdateWidget(FavoriteButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.recipeId != widget.recipeId) {
      _loadInitialState();
    }
  }

  @override
  void dispose() {
    _favoriteService.removeListener(_onFavoriteChanged);
    super.dispose();
  }

  void _onFavoriteChanged() {
    if (mounted) {
      _refreshState();
    }
  }

  Future<void> _refreshState() => _updateFavoriteState();

  Future<void> _loadInitialState() => _updateFavoriteState();

  Future<void> _updateFavoriteState() async {
    if (!mounted) return;

    try {
      // Ora isFavorite è immediato grazie alla cache!
      final isFavorite = await _favoriteService.isFavorite(widget.recipeId);
      if (mounted) {
        setState(() {
          _isFavorite = isFavorite;
          _isLoading = false;
        });
      }
    } catch (e) {
      AppLogger.error('Error updating favorite state', e);
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _toggleFavorite() async {
    if (_isProcessing) return;

    final authService = Provider.of<AuthService>(context, listen: false);
    if (!authService.isLoggedIn) {
      _showLoginPrompt();
      return;
    }

    // Optimistic update IMMEDIATO
    setState(() {
      _isProcessing = true;
      _isFavorite = !_isFavorite;
    });

    try {
      final success = await _favoriteService.toggleFavorite(widget.recipeId);

      if (!success && mounted) {
        // Rollback se fallisce
        setState(() {
          _isFavorite = !_isFavorite;
          _isProcessing = false;
        });
        _showSnackbar('Errore durante l\'operazione', isError: true);
      } else if (mounted) {
        setState(() {
          _isProcessing = false;
        });
        widget.onToggle?.call();
        // Non mostriamo snackbar per essere più veloci?
        // Se vuoi mantenerlo, lascia questa riga
        _showSnackbar(
          _isFavorite ? 'Aggiunto ai preferiti' : 'Rimosso dai preferiti',
          isError: false,
        );
      }
    } catch (e) {
      AppLogger.error('Error toggling favorite', e);
      if (mounted) {
        setState(() {
          _isFavorite = !_isFavorite; // Rollback
          _isProcessing = false;
        });
        _showSnackbar('Errore: ${e.toString()}', isError: true);
      }
    }
  }

  void _showLoginPrompt() {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Accedi per salvare le ricette preferite'),
        backgroundColor: Colors.orange[800],
        action: SnackBarAction(
          label: 'ACCEDI',
          textColor: Colors.white,
          onPressed: () => context.go('/login'),
        ),
      ),
    );
  }

  void _showSnackbar(String message, {required bool isError}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration:
            Duration(seconds: isError ? 3 : 1), // Ridotto a 1 sec per successo
      ),
    );
  }

  bool get _showLoader =>
      widget.showLoading && _isLoading; // Rimosso _isProcessing

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = context.watch<AuthService>().isLoggedIn;

    if (!isLoggedIn) {
      return IconButton(
        iconSize: widget.size,
        icon: Icon(Icons.favorite_border, color: widget.color ?? Colors.grey),
        onPressed: _showLoginPrompt,
        tooltip: 'Accedi per aggiungere ai preferiti',
      );
    }

    if (_showLoader) {
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
      onPressed: _toggleFavorite,
      tooltip: _isFavorite ? 'Rimuovi dai preferiti' : 'Aggiungi ai preferiti',
    );
  }
}
