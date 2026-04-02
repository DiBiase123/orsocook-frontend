import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:orsocook/services/auth_service.dart';
import 'package:orsocook/screens/home/widgets/avatar_buttons.dart';
import 'package:orsocook/screens/home/widgets/recipe_search_bar.dart';

class HomeAppBar extends StatelessWidget {
  final VoidCallback onProfileTap;
  final VoidCallback onCreateRecipeTap;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;

  const HomeAppBar({
    super.key,
    required this.onProfileTap,
    required this.onCreateRecipeTap,
    required this.searchController,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 900;
    final isSmall = screenWidth < 600;

    final logoSize = isMobile ? (isSmall ? 44.0 : 55.0) : 80.0;
    final avatarSize = logoSize;
    final iconSize = isMobile ? (isSmall ? 36.0 : 42.0) : 48.0;
    final titleSize = isMobile ? (isSmall ? 24.0 : 28.0) : 34.0;
    final vPadding = isMobile ? (isSmall ? 8.0 : 10.0) : 16.0;
    final gap = isMobile ? (isSmall ? 8.0 : 10.0) : 20.0;

    return Container(
      color: const Color(0xFF6750A4), // RIPRISTINATO il colore viola
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: gap, vertical: vPadding),
          child: isMobile
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: Row(
                        children: [
                          _buildLogo(logoSize),
                          const Spacer(),
                          _buildTitle(titleSize),
                          const Spacer(),
                          _buildAddButton(iconSize),
                          SizedBox(width: gap * 0.5),
                          _buildAvatar(avatarSize, iconSize),
                        ],
                      ),
                    ),
                    SizedBox(height: vPadding),
                    SizedBox(
                      width: double.infinity,
                      child: RecipeSearchBar(
                        controller: searchController,
                        onSearchChanged: onSearchChanged,
                        compact: false,
                        backgroundColor: Colors.white,
                      ),
                    ),
                  ],
                )
              : Row(
                  children: [
                    _buildLogo(logoSize),
                    SizedBox(width: gap),
                    _buildTitle(titleSize),
                    SizedBox(width: gap * 2),
                    Expanded(
                      child: RecipeSearchBar(
                        controller: searchController,
                        onSearchChanged: onSearchChanged,
                        compact: true,
                        backgroundColor: Colors.white,
                      ),
                    ),
                    SizedBox(width: gap),
                    _buildAddButton(iconSize),
                    SizedBox(width: gap * 0.5),
                    _buildAvatar(avatarSize, iconSize),
                    SizedBox(width: gap * 0.5),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildLogo(double size) {
    return ClipOval(
      child: Image.asset(
        'assets/images/OrsoCooK.png',
        width: size,
        height: size,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildTitle(double size) {
    return Text(
      'OrsoCook',
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: size,
        color: Colors.white,
      ),
    );
  }

  Widget _buildAddButton(double size) {
    return IconButton(
      icon: Icon(Icons.add_circle_outline, size: size),
      onPressed: onCreateRecipeTap,
      tooltip: 'Crea ricetta',
      color: Colors.white,
      padding: EdgeInsets.zero,
      constraints: BoxConstraints(minWidth: size, minHeight: size),
    );
  }

  Widget _buildAvatar(double avatarSize, double iconSize) {
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        return SizedBox(
          width: avatarSize,
          height: avatarSize,
          child: AvatarBuilder.buildAvatar(
            authService,
            onProfileTap,
            isInAppBar: true,
            size: iconSize,
            loggedSize: avatarSize,
          ),
        );
      },
    );
  }
}
