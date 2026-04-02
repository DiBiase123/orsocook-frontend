import 'package:flutter/material.dart';
import 'package:orsocook/services/auth_service.dart';

class AvatarIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;
  final bool isInAppBar;
  final double? size;

  const AvatarIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    this.onTap,
    this.isInAppBar = false,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    final iconSize = size ?? (isInAppBar ? 32.0 : 44.0);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: IconButton(
        icon: Icon(icon, size: iconSize),
        onPressed: onTap,
        tooltip: tooltip,
        color: Colors.white,
        padding: const EdgeInsets.all(4),
        constraints: BoxConstraints(
          minWidth: iconSize + 8,
          minHeight: iconSize + 8,
        ),
      ),
    );
  }
}

class AvatarImageButton extends StatefulWidget {
  final String avatarUrl;
  final String tooltip;
  final VoidCallback? onTap;
  final bool isInAppBar;
  final double? size;

  const AvatarImageButton({
    super.key,
    required this.avatarUrl,
    required this.tooltip,
    this.onTap,
    this.isInAppBar = false,
    this.size,
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

  void _handleTapDown(TapDownDetails details) => _controller.forward();

  void _handleTapUp(TapUpDetails details) {
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
    final avatarRadius = widget.size != null
        ? widget.size! / 2
        : (widget.isInAppBar ? 20.0 : 30.0);
    final marginHorizontal = widget.isInAppBar ? 4.0 : 12.0;

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
                margin: EdgeInsets.symmetric(horizontal: marginHorizontal),
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color:
                        _isHovered ? Colors.white : Colors.white.withAlpha(100),
                    width: _isHovered ? 2 : 1,
                  ),
                  boxShadow: [
                    if (_isHovered)
                      BoxShadow(
                        color: Colors.white.withAlpha(80),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                  ],
                ),
                child: CircleAvatar(
                  backgroundImage: NetworkImage(widget.avatarUrl),
                  radius: avatarRadius,
                  backgroundColor: Colors.grey[300],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AvatarBuilder {
  static Widget buildAvatar(
    AuthService authService,
    VoidCallback onTap, {
    bool isInAppBar = false,
    double? size,
  }) {
    if (!authService.isLoggedIn) {
      return AvatarIconButton(
        icon: Icons.account_circle,
        tooltip: 'Accedi al profilo',
        onTap: onTap,
        isInAppBar: isInAppBar,
        size: size,
      );
    }

    final String? username = authService.username;
    final String tooltip =
        username != null ? 'Profilo di $username' : 'Profilo';

    final String? avatarUrl = authService.avatarUrl;
    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      return AvatarImageButton(
        avatarUrl: avatarUrl,
        tooltip: tooltip,
        onTap: onTap,
        isInAppBar: isInAppBar,
        size: size,
      );
    }

    return AvatarIconButton(
      icon: Icons.account_circle,
      tooltip: 'Profilo',
      onTap: onTap,
      isInAppBar: isInAppBar,
      size: size,
    );
  }
}
