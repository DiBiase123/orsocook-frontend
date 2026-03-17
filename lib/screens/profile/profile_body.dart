import 'package:flutter/material.dart';
import 'package:orsocook/services/profile/profile_controller.dart';
import 'package:orsocook/screens/profile/profile_header.dart';
import 'package:orsocook/screens/profile/widgets/profile_tabs_widget.dart';
import 'package:orsocook/screens/profile/widgets/profile_stats_widget.dart';

class ProfileBody extends StatefulWidget {
  final ProfileController controller;
  final bool isInitialLoad;
  final String? lastShownMessage;
  final Function(String) onShowSuccessMessage;

  const ProfileBody({
    super.key,
    required this.controller,
    required this.isInitialLoad,
    required this.lastShownMessage,
    required this.onShowSuccessMessage,
  });

  @override
  State<ProfileBody> createState() => _ProfileBodyState();
}

class _ProfileBodyState extends State<ProfileBody> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentMessage = widget.controller.lastSuccessMessage;
      if (currentMessage != null &&
          currentMessage != widget.lastShownMessage &&
          mounted) {
        widget.onShowSuccessMessage(currentMessage);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 600;
    final horizontalPadding = isLargeScreen ? 24.0 : 16.0;

    return RefreshIndicator(
      onRefresh: () async {
        await widget.controller.refreshProfile();
        if (mounted) setState(() {});
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.all(horizontalPadding),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Avatar - larghezza basata sul contenuto
                    IntrinsicWidth(
                      child: ProfileHeader(
                        key: ValueKey(
                            widget.controller.userProfile?.avatarUrl ??
                                'no-avatar'),
                      ),
                    ),

                    SizedBox(width: isLargeScreen ? 24 : 16),

                    // Statistiche - occupano tutto lo spazio rimanente
                    if (widget.controller.hasProfile &&
                        widget.controller.userStats != null)
                      Expanded(
                        child: Container(
                          height: double.infinity,
                          constraints: const BoxConstraints(minHeight: 200),
                          child: ProfileStatsWidget(
                            key: ValueKey(
                                'stats-${widget.controller.userStats?.favoritesCount}-${widget.controller.userStats?.recipesCount}-${DateTime.now().millisecondsSinceEpoch}'),
                            stats: widget.controller.userStats!,
                            compact: true,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Tabs sotto - SENZA ALCUN SIZEDBOX
            if (widget.isInitialLoad)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator(),
                ),
              )
            else
              const ProfileTabs(), // Niente SizedBox, niente Expanded, niente vincoli
          ],
        ),
      ),
    );
  }
}
