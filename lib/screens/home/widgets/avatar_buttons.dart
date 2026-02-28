import 'package:flutter/material.dart';
import 'package:orsocook/services/auth_service.dart';

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
    return IconButton(
      icon: Icon(icon),
      onPressed: onTap,
      tooltip: tooltip,
    );
  }
}

class AvatarImageButton extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundImage: NetworkImage(avatarUrl),
            radius: 18,
            backgroundColor: Colors.grey[200],
          ),
        ),
      ),
    );
  }
}

class AvatarBuilder {
  static Widget buildAvatar(AuthService authService, VoidCallback onTap) {
    if (!authService.isLoggedIn) {
      return AvatarIconButton(
        icon: Icons.account_circle,
        tooltip: 'Accedi al profilo',
        onTap: onTap,
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

    return AvatarIconButton(
      icon: Icons.account_circle,
      tooltip: 'Profilo',
      onTap: onTap,
    );
  }
}
