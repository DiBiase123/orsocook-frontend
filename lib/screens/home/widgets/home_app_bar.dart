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
    const appBarColor = Color(0xFF6750A4);

    // Breakpoint per dimensioni
    late final double logoSize;
    late final double iconSize;
    late final double titleFontSize;
    late final double verticalPadding;
    late final double spacing;
    late final bool isMobile;

    if (screenWidth < 600) {
      // Mobile piccolo
      isMobile = true;
      logoSize = 44;
      iconSize = 36;
      titleFontSize = 24; // aumentato da 18 a 24
      verticalPadding = 8;
      spacing = 8;
    } else if (screenWidth < 900) {
      // Tablet / Mobile grande
      isMobile = true;
      logoSize = 55;
      iconSize = 42;
      titleFontSize = 28; // aumentato da 22 a 28
      verticalPadding = 10;
      spacing = 10;
    } else {
      // Desktop
      isMobile = false;
      logoSize = 80;
      iconSize = 48;
      titleFontSize = 34; // aumentato da 28 a 34
      verticalPadding = 16;
      spacing = 20;
    }

    return Container(
      color: appBarColor,
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: spacing, vertical: verticalPadding),
          child: isMobile
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ClipOval(
                          child: Image.asset(
                            'assets/images/OrsoCooK.png',
                            width: logoSize,
                            height: logoSize,
                            fit: BoxFit.cover,
                          ),
                        ),
                        SizedBox(width: spacing),
                        Text(
                          'OrsoCook',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: titleFontSize,
                            color: Colors.white,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: Icon(Icons.add_circle_outline, size: iconSize),
                          onPressed: onCreateRecipeTap,
                          tooltip: 'Crea ricetta',
                          color: Colors.white,
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(
                            minWidth: iconSize,
                            minHeight: iconSize,
                          ),
                        ),
                        SizedBox(width: spacing * 0.5),
                        Consumer<AuthService>(
                          builder: (context, authService, child) {
                            return SizedBox(
                              width: iconSize,
                              height: iconSize,
                              child: AvatarBuilder.buildAvatar(
                                authService,
                                onProfileTap,
                                isInAppBar: true,
                                size: iconSize,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: verticalPadding),
                    RecipeSearchBar(
                      controller: searchController,
                      onSearchChanged: onSearchChanged,
                      compact: false,
                      backgroundColor: Colors.white,
                    ),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ClipOval(
                      child: Image.asset(
                        'assets/images/OrsoCooK.png',
                        width: logoSize,
                        height: logoSize,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(width: spacing),
                    Text(
                      'OrsoCook',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: titleFontSize,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: spacing * 2),
                    Expanded(
                      child: RecipeSearchBar(
                        controller: searchController,
                        onSearchChanged: onSearchChanged,
                        compact: true,
                        backgroundColor: Colors.white,
                      ),
                    ),
                    SizedBox(width: spacing),
                    IconButton(
                      icon: Icon(Icons.add_circle_outline, size: iconSize),
                      onPressed: onCreateRecipeTap,
                      tooltip: 'Crea ricetta',
                      color: Colors.white,
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(
                        minWidth: iconSize,
                        minHeight: iconSize,
                      ),
                    ),
                    SizedBox(width: spacing * 0.5),
                    SizedBox(
                      width: iconSize,
                      height: iconSize,
                      child: Consumer<AuthService>(
                        builder: (context, authService, child) {
                          return AvatarBuilder.buildAvatar(
                            authService,
                            onProfileTap,
                            isInAppBar: true,
                            size: iconSize,
                          );
                        },
                      ),
                    ),
                    SizedBox(width: spacing * 0.5),
                  ],
                ),
        ),
      ),
    );
  }
}
