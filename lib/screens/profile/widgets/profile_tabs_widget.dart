import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:orsocook/services/profile/profile_controller.dart';
import 'package:orsocook/screens/profile/widgets/profile_recipes_list_widget.dart';
import 'package:orsocook/utils/responsive_utils.dart';

class ProfileTabs extends StatefulWidget {
  const ProfileTabs({super.key});

  @override
  State<ProfileTabs> createState() => _ProfileTabsState();
}

class _ProfileTabsState extends State<ProfileTabs>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  static const _tabTitles = ['Le Mie Ricette', 'Preferiti'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabTitles.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<ProfileController>(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Container(
          color: colorScheme.primary.withAlpha(25),
          child: TabBar(
            controller: _tabController,
            tabs: _tabTitles.map((title) => Tab(text: title)).toList(),
            indicatorColor: colorScheme.tertiary,
            labelColor: colorScheme.tertiary,
            unselectedLabelColor: Colors.grey,
            labelStyle: const TextStyle(fontWeight: FontWeight.w600),
            onTap: controller.selectTab,
          ),
        ),
        Container(
          constraints: BoxConstraints(
            minHeight: 200,
            maxHeight: MediaQuery.of(context).size.height * 0.6,
          ),
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildContent(controller, 0),
              _buildContent(controller, 1),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContent(ProfileController controller, int index) {
    if (controller.isLoading && !controller.hasProfile) {
      return const _LoadingState();
    }

    if (!controller.hasProfile) {
      return _EmptyProfile(controller: controller);
    }

    if (index == 0) {
      return ProfileRecipesList(
        key: ValueKey('user-recipes-${controller.recentRecipes?.length ?? 0}'),
        recipes: controller.recentRecipes!,
        userId: controller.userProfile!.id,
        emptyMessage: 'Non hai ancora creato ricette',
        emptyIcon: Icons.restaurant_menu_outlined,
        isUserRecipes: true,
      );
    } else {
      return ProfileRecipesList(
        key: ValueKey('favorites-${controller.recentFavorites?.length ?? 0}'),
        recipes: controller.recentFavorites!,
        userId: controller.userProfile!.id,
        emptyMessage: 'Non hai ricette preferite',
        emptyIcon: Icons.favorite_border,
        isUserRecipes: false,
      );
    }
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          SizedBox(height: ResponsiveValues.gapMedium(context)),
          const Text('Caricamento dati...'),
        ],
      ),
    );
  }
}

class _EmptyProfile extends StatelessWidget {
  final ProfileController controller;

  const _EmptyProfile({required this.controller});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: ResponsiveValues.screenPadding(context),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_outline, size: 64, color: Colors.grey[400]),
          SizedBox(height: ResponsiveValues.gapMedium(context)),
          Text(
            'Nessun profilo caricato',
            style: TextStyle(
              fontSize: 18,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: ResponsiveValues.gapMedium(context)),
          ElevatedButton(
            onPressed: controller.refreshProfile,
            child: const Text('Ricarica'),
          ),
        ],
      ),
    );
  }
}
