import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:orsocook/services/auth_service.dart';
import 'package:orsocook/screens/home/widgets/avatar_buttons.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onProfileTap;
  final VoidCallback onCreateRecipeTap;

  const HomeAppBar({
    super.key,
    required this.onProfileTap,
    required this.onCreateRecipeTap,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        return AppBar(
          title: const Text(
            'OrsoCook',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: onCreateRecipeTap,
              tooltip: 'Crea ricetta',
            ),
            GestureDetector(
              onTap: onProfileTap,
              child: AvatarBuilder.buildAvatar(authService, onProfileTap),
            ),
          ],
        );
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
