import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:orsocook/services/profile_controller.dart';
import 'package:orsocook/services/auth_service.dart';

class AvatarPickerWidget extends StatelessWidget {
  const AvatarPickerWidget({super.key});

  void _showAvatarConfirmDialog(BuildContext context) {
    final controller = Provider.of<ProfileController>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cambia avatar'),
        content: const Text('Vuoi salvare questa immagine come avatar?'),
        actions: [
          TextButton(
            onPressed: () {
              context.pop();
              controller.clearSelectedAvatar();
            },
            child: const Text('Annulla'),
          ),
          TextButton(
            onPressed: () async {
              context.pop();
              final result = await controller.uploadAvatar();

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(result['message'] as String),
                    backgroundColor:
                        result['success'] == true ? Colors.green : Colors.red,
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
            child: const Text('Salva'),
          ),
        ],
      ),
    );
  }

  void _pickAvatarImage(BuildContext context) async {
    final controller = Provider.of<ProfileController>(context, listen: false);

    try {
      await controller.pickAvatarImage();

      if (controller.selectedAvatar != null && context.mounted) {
        _showAvatarConfirmDialog(context);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<ProfileController>(context);
    final authService = Provider.of<AuthService>(context, listen: false);

    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 600;
    final avatarSize = isLargeScreen ? 100.0 : 80.0;
    final iconSize = isLargeScreen ? 24.0 : 18.0;
    final buttonSize = isLargeScreen ? 44.0 : 36.0;

    return Stack(
      children: [
        // Avatar container
        Container(
          width: avatarSize,
          height: avatarSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).colorScheme.primary.withAlpha(51),
            border: Border.all(
              color: Theme.of(context).colorScheme.primary,
              width: 2,
            ),
          ),
          child: controller.isChangingAvatar
              ? const Center(child: CircularProgressIndicator())
              : ClipRRect(
                  borderRadius: BorderRadius.circular(avatarSize / 2),
                  child: _buildAvatarImage(controller, authService, context),
                ),
        ),

        // Pulsante cambia avatar
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: IconButton(
              icon: Icon(
                Icons.camera_alt,
                size: iconSize,
                color: Colors.white,
              ),
              onPressed:
                  controller.isBusy ? null : () => _pickAvatarImage(context),
              tooltip: 'Cambia avatar',
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(
                minWidth: buttonSize,
                minHeight: buttonSize,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAvatarImage(
    ProfileController controller,
    AuthService authService,
    BuildContext context,
  ) {
    // Priorità 1: File temporaneo selezionato (XFile)
    if (controller.selectedAvatar != null) {
      return FutureBuilder(
        future: controller.selectedAvatar!.readAsBytes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData) {
            return Image.memory(
              snapshot.data!,
              fit: BoxFit.cover,
            );
          }
          return _buildPlaceholderIcon(context);
        },
      );
    }

    // Priorità 2: Avatar dal profilo
    final profileAvatarUrl = controller.displayAvatarUrl;
    if (profileAvatarUrl != null && profileAvatarUrl.isNotEmpty) {
      return Image.network(
        profileAvatarUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            _buildPlaceholderIcon(context),
      );
    }

    // Priorità 3: Avatar da AuthService (cache)
    final authAvatarUrl = authService.avatarUrl;
    if (authAvatarUrl != null && authAvatarUrl.isNotEmpty) {
      return Image.network(
        authAvatarUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            _buildPlaceholderIcon(context),
      );
    }

    // Fallback: icona placeholder
    return _buildPlaceholderIcon(context);
  }

  Widget _buildPlaceholderIcon(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 600;
    final iconSize = isLargeScreen ? 50.0 : 40.0;

    return Icon(
      Icons.person,
      size: iconSize,
      color: Theme.of(context).colorScheme.primary,
    );
  }
}
