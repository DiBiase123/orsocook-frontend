import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:orsocook/services/auth_service.dart';
import 'package:orsocook/screens/home/widgets/avatar_buttons.dart';
import 'package:orsocook/screens/home/widgets/recipe_search_bar.dart';
import 'package:orsocook/providers/theme_provider.dart';

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
    final isDesktop = screenWidth >= 900;
    final isTablet = screenWidth >= 600 && screenWidth < 900;
    final colorScheme = Theme.of(context).colorScheme;
    final themeProvider = Provider.of<ThemeProvider>(context);

    double logoSize;
    double avatarSize;
    double iconSize;
    double titleSize;
    double vPadding;
    double gap;

    if (isDesktop) {
      logoSize = 80.0;
      avatarSize = 80.0;
      iconSize = 48.0;
      titleSize = 34.0;
      vPadding = 16.0;
      gap = 20.0;
    } else if (isTablet) {
      logoSize = 55.0;
      avatarSize = 55.0;
      iconSize = 42.0;
      titleSize = 28.0;
      vPadding = 10.0;
      gap = 10.0;
    } else {
      logoSize = 44.0;
      avatarSize = 44.0;
      iconSize = 36.0;
      titleSize = 24.0;
      vPadding = 8.0;
      gap = 8.0;
    }

    return Container(
      color: colorScheme.primary,
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: gap, vertical: vPadding),
          child: (isDesktop || isTablet)
              ? Row(
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
                      ),
                    ),
                    SizedBox(width: gap),
                    _buildAddButton(iconSize),
                    SizedBox(width: gap * 0.5),
                    _buildThemeToggleButton(iconSize, themeProvider),
                    SizedBox(width: gap * 0.5),
                    _buildAvatar(avatarSize, iconSize),
                    SizedBox(width: gap * 0.5),
                  ],
                )
              : Column(
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
                          _buildThemeToggleButton(iconSize, themeProvider),
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
                      ),
                    ),
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

  Widget _buildThemeToggleButton(double size, ThemeProvider themeProvider) {
    return IconButton(
      icon: Icon(
        themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
        size: size * 0.7,
      ),
      onPressed: () => themeProvider.toggleTheme(),
      tooltip: themeProvider.isDarkMode ? 'Tema chiaro' : 'Tema scuro',
      color: Colors.white,
      padding: EdgeInsets.zero,
      constraints: BoxConstraints(minWidth: size * 0.7, minHeight: size * 0.7),
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
