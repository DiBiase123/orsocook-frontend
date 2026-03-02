import 'package:flutter/material.dart';
import 'package:orsocook/services/auth_service.dart';

// ========== WIDGET ICONA ==========
class AvatarIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;

  const AvatarIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: IconButton(
        icon: Icon(icon, size: 44),
        onPressed: onTap,
        tooltip: tooltip,
        padding: const EdgeInsets.all(8),
        constraints: const BoxConstraints(
          minWidth: 52, // Larghezza minima aumentata
          minHeight: 52, // Altezza minima aumentata
        ),
      ),
    );
  }
}

// ========== WIDGET IMMAGINE CON ANIMAZIONE ==========
class AvatarImageButton extends StatefulWidget {
  final String avatarUrl;
  final String tooltip;
  final VoidCallback? onTap;

  const AvatarImageButton({
    super.key,
    required this.avatarUrl,
    required this.tooltip,
    this.onTap,
  });

  @override
  State<AvatarImageButton> createState() => _AvatarImageButtonState();
}

class _AvatarImageButtonState extends State<AvatarImageButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  void _handleTapDown(_) => _controller.forward();
  void _handleTapUp(_) {
    _controller.reverse();
    widget.onTap?.call();
  }

  void _handleTapCancel() => _controller.reverse();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Tooltip(
        message: widget.tooltip,
        child: GestureDetector(
          onTapDown: _handleTapDown,
          onTapUp: _handleTapUp,
          onTapCancel: _handleTapCancel,
          child: AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) => Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                margin: const EdgeInsets.symmetric(
                    horizontal: 12), // Più spazio ai lati
                padding:
                    const EdgeInsets.all(2), // Padding interno per respirare
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _isHovered
                        ? Colors.orange
                        : Colors.orange.withAlpha(100),
                    width: _isHovered ? 3 : 2,
                  ),
                  boxShadow: [
                    if (_isHovered)
                      BoxShadow(
                        color: Colors.orange.withAlpha(80),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      )
                    else
                      BoxShadow(
                        color: Colors.orange.withAlpha(60),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                  ],
                ),
                child: CircleAvatar(
                  backgroundImage: NetworkImage(widget.avatarUrl),
                  radius:
                      30, // +10% rispetto a 28 (ora 33% più grande dell'originale)
                  backgroundColor: Colors.grey[200],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ========== BUILDER PRINCIPALE ==========
class AvatarBuilder {
  static Widget buildAvatar(AuthService authService, VoidCallback onTap) {
    if (!authService.isLoggedIn) {
      return Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: 12), // Più spazio ai lati
        child: AvatarIconButton(
          icon: Icons.account_circle,
          tooltip: 'Accedi al profilo',
          onTap: onTap,
        ),
      );
    }

    final tooltip = authService.username != null
        ? 'Profilo di ${authService.username}'
        : 'Profilo';

    if (authService.avatarUrl?.isNotEmpty ?? false) {
      return AvatarImageButton(
        avatarUrl: authService.avatarUrl!,
        tooltip: tooltip,
        onTap: onTap,
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12), // Più spazio ai lati
      child: AvatarIconButton(
        icon: Icons.account_circle,
        tooltip: 'Profilo',
        onTap: onTap,
      ),
    );
  }
}
