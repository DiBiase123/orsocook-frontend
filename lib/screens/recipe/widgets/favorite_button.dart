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

class _FavoriteButtonState extends State<FavoriteButton>
    with SingleTickerProviderStateMixin {
  bool _isProcessing = false;
  bool _isFavorite = false;
  bool _isLoading = true;
  late FavoriteService _favoriteService;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  OverlayEntry? _balloonEntry;

  @override
  void initState() {
    super.initState();
    _favoriteService = Provider.of<FavoriteService>(context, listen: false);
    _loadInitialState();
    _favoriteService.addListener(_onFavoriteChanged);

    // Animazione
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticInOut),
    );
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
    _animationController.dispose();
    _hideBalloon();
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

  // 🎈 BALLOON SOPRA IL BOTTONE
  void _showBalloon(String message, {required bool isRemoving}) {
    _hideBalloon();

    if (!mounted) return;

    final RenderBox buttonBox = context.findRenderObject() as RenderBox;
    final Offset buttonPosition = buttonBox.localToGlobal(Offset.zero);
    final Size buttonSize = buttonBox.size;

    _balloonEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: buttonPosition.dx + buttonSize.width / 2 - 80,
        top: buttonPosition.dy - 65,
        child: Material(
          color: Colors.transparent,
          child: TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 200),
            tween: Tween(begin: 0.0, end: 1.0),
            curve: Curves.elasticOut,
            builder: (context, scale, child) {
              return Transform.scale(
                scale: scale,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: isRemoving
                        ? Colors.amber.shade400 // Giallo per rimozione
                        : Colors.green.shade600, // Verde per aggiunta
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: Colors.black54,
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(50),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isRemoving ? Icons.heart_broken : Icons.favorite,
                        color: Colors.white, // Icona bianca
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        message,
                        style: const TextStyle(
                          color: Colors.white, // TESTO BIANCO
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_balloonEntry!);

    Future.delayed(const Duration(milliseconds: 1800), _hideBalloon);
  }

  void _hideBalloon() {
    _balloonEntry?.remove();
    _balloonEntry = null;
  }

  Future<void> _toggleFavorite() async {
    if (_isProcessing) {
      AppLogger.debug('⏳ Click bloccato - operazione in corso');
      return;
    }

    final authService = Provider.of<AuthService>(context, listen: false);
    if (!authService.isLoggedIn) {
      _showLoginPrompt();
      return;
    }

    final previousState = _isFavorite;

    setState(() {
      _isProcessing = true;
      _isFavorite = !_isFavorite;
    });

    _animationController.forward().then((_) => _animationController.reverse());

    try {
      final success = await _favoriteService.toggleFavorite(widget.recipeId);

      if (!success && mounted) {
        setState(() {
          _isFavorite = previousState;
          _isProcessing = false;
        });
        _showBalloon('Errore', isRemoving: true);
      } else if (mounted) {
        _showBalloon(
          _isFavorite ? 'Aggiunto!' : 'Rimosso!',
          isRemoving: !_isFavorite,
        );

        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) {
            setState(() {
              _isProcessing = false;
            });
          }
        });

        widget.onToggle?.call();
      }
    } catch (e) {
      AppLogger.error('Error toggling favorite', e);
      if (mounted) {
        setState(() {
          _isFavorite = previousState;
          _isProcessing = false;
        });
        _showBalloon('Errore', isRemoving: true);
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

  bool get _showLoader => widget.showLoading && _isLoading;

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = context.watch<AuthService>().isLoggedIn;

    if (!isLoggedIn) {
      return IconButton(
        iconSize: widget.size,
        icon: Icon(Icons.favorite_border, color: widget.color ?? Colors.grey),
        onPressed: _showLoginPrompt,
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

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: IconButton(
            iconSize: widget.size,
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color:
                  _isFavorite ? Colors.red : widget.color ?? Colors.grey[700],
            ),
            onPressed: _toggleFavorite,
          ),
        );
      },
    );
  }
}
