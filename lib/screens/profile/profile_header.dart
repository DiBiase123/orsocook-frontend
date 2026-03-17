import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:orsocook/services/profile/profile_controller.dart';
import 'package:orsocook/screens/profile/widgets/avatar_picker_widget.dart';
import 'package:orsocook/services/auth_service.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<ProfileController>(context);
    final user = controller.userProfile;
    final auth = Provider.of<AuthService>(context, listen: false);

    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 600;

    final fontSize = isLargeScreen ? 20.0 : 18.0;
    final smallFontSize = isLargeScreen ? 14.0 : 12.0;
    final padding = isLargeScreen ? 20.0 : 16.0;

    return Container(
      padding: EdgeInsets.all(padding),
      constraints: const BoxConstraints(
          minHeight: 200, minWidth: 200), // Larghezza minima
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[300]!,
          width: 2,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const AvatarPickerWidget(),
          const SizedBox(height: 16),
          if (user != null)
            Text(
              user.username,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            )
          else if (auth.username != null)
            Text(
              auth.username!,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          const SizedBox(height: 4),
          if (user != null)
            Text(
              user.email,
              style: TextStyle(
                fontSize: smallFontSize,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
              softWrap: true,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          const SizedBox(height: 4),
          if (user != null)
            Text(
              'Membro dal ${controller.formatDate(user.createdAt)}',
              style: TextStyle(
                fontSize: smallFontSize - 2,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }
}
