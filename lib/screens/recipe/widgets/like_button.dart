import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart'; // <-- AGGIUNTO
import 'package:orsocook/services/like_service.dart';
import 'package:orsocook/services/auth_service.dart';
import 'package:orsocook/utils/logger.dart';

class LikeButton extends StatefulWidget {
  final String recipeId;
  final double size;
  final Color? color;
  final bool showLoading;
  final VoidCallback? onToggle;

  const LikeButton({
    super.key,
    required this.recipeId,
    this.size = 24.0,
    this.color,
    this.showLoading = true,
    this.onToggle,
  });

  @override
  State<LikeButton> createState() => _LikeButtonState();
}

class _LikeButtonState extends State<LikeButton> {
  bool _isProcessing = false;
  bool _hasCheckedInitialState = false;

  @override
  void initState() {
    super.initState();
    // NON facciamo chiamate API qui, usiamo solo la cache
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _hasCheckedInitialState = true;
        });
      }
    });
  }

  Future<void> _toggleLike(LikeService likeService) async {
    if (_isProcessing) return;

    final authService = Provider.of<AuthService>(context, listen: false);

    if (!authService.isLoggedIn) {
      _showLoginPrompt();
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final success = await likeService.toggleLike(widget.recipeId);

      if (!success) {
        _showErrorSnackbar('Errore durante l\'operazione');
      } else {
        widget.onToggle?.call();
        final isNowLiked = likeService.isLiked(widget.recipeId);
        _showSuccessSnackbar(
            isNowLiked ? 'Mi piace aggiunto!' : 'Mi piace rimosso!');
      }
    } catch (e) {
      AppLogger.error('Error toggling like', e);
      _showErrorSnackbar('Errore: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  void _showLoginPrompt() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Accedi per mettere "Mi piace" alle ricette'),
        backgroundColor: Colors.orange[800],
        action: SnackBarAction(
          label: 'ACCEDI',
          textColor: Colors.white,
          onPressed: () {
            // Chiudi lo snackbar
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            // Naviga al login
            GoRouter.of(context).go('/login');
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
    return Consumer<LikeService>(
      builder: (context, likeService, child) {
        final isLiked = likeService.isLiked(widget.recipeId);
        final likesCount = likeService.getLikesCount(widget.recipeId);
        final authService = Provider.of<AuthService>(context);
        final isLoggedIn = authService.isLoggedIn;

        // Se non abbiamo ancora inizializzato, mostra un placeholder
        if (!_hasCheckedInitialState && widget.showLoading) {
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

        // Utente non loggato
        if (!isLoggedIn) {
          return Stack(
            children: [
              IconButton(
                iconSize: widget.size,
                icon: Icon(
                  Icons.thumb_up_outlined,
                  color: widget.color ?? Colors.grey,
                ),
                onPressed: _showLoginPrompt,
                tooltip: 'Accedi per mettere "Mi piace"',
              ),
              if (likesCount > 0)
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      likesCount > 99 ? '99+' : likesCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          );
        }

        // In elaborazione
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

        // Bottone normale
        return Stack(
          children: [
            IconButton(
              iconSize: widget.size,
              icon: Icon(
                isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                color:
                    isLiked ? Colors.blue : widget.color ?? Colors.grey[700]!,
              ),
              onPressed: () => _toggleLike(likeService),
              tooltip: isLiked ? 'Rimuovi mi piace' : 'Metti mi piace',
            ),
            if (likesCount > 0)
              Positioned(
                bottom: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: isLiked ? Colors.blue : Colors.grey[600],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    likesCount > 99 ? '99+' : likesCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
