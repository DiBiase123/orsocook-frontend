import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:orsocook/services/profile_controller.dart';
import 'package:orsocook/screens/profile/widgets/profile_header.dart';
import 'package:orsocook/screens/profile/widgets/profile_tabs.dart';
import 'package:orsocook/screens/profile/profile_stats_widget.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  ProfileController? _profileController;
  bool _isInitialLoad = true;
  String? _lastShownMessage;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _profileController = Provider.of<ProfileController>(context, listen: false);

    if (_isInitialLoad && _profileController != null) {
      _loadProfile();
    }
  }

  @override
  void dispose() {
    _lastShownMessage = null;
    _profileController?.clearSuccessMessage();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    if (!mounted || _profileController == null) return;

    try {
      final controller = _profileController;
      if (controller != null) {
        await controller.loadProfile();
      } else {
        if (kDebugMode) {
          debugPrint('❌ ProfileController null in loadProfile');
        }
      }
      if (mounted) {
        setState(() {
          _isInitialLoad = false;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Errore caricamento profilo: $e');
      }
    }
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Sei sicuro di voler effettuare il logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annulla'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _performLogout();
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _performLogout() async {
    try {
      await _profileController?.logout();

      if (mounted) {
        context.go('/login');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Errore durante il logout'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showSuccessMessage(String message) {
    if (_lastShownMessage == message || !mounted) return;

    _lastShownMessage = message;

    final snackBar = SnackBar(
      content: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.white),
          const SizedBox(width: 8),
          Expanded(child: Text(message)),
        ],
      ),
      backgroundColor: Colors.green,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 3),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);

    Future.delayed(const Duration(seconds: 4), () {
      if (mounted && _lastShownMessage == message) {
        _lastShownMessage = null;
        _profileController?.clearSuccessMessage();
      }
    });
  }

  Widget _buildErrorWidget(ProfileController controller) {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red[700]),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  controller.error!,
                  style: TextStyle(color: Colors.red[700]),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: controller.retry,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[700],
              foregroundColor: Colors.white,
            ),
            child: const Text('Riprova'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileBody(ProfileController controller) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentMessage = controller.lastSuccessMessage;
      if (currentMessage != null &&
          currentMessage != _lastShownMessage &&
          mounted) {
        _showSuccessMessage(currentMessage);
      }
    });

    return RefreshIndicator(
      onRefresh: () async {
        await controller.refreshProfile();
        if (mounted) {
          setState(() {});
        }
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ProfileHeader(
              key: ValueKey(controller.userProfile?.avatarUrl ?? 'no-avatar'),
            ),
            if (controller.hasProfile && controller.userStats != null)
              ProfileStatsWidget(stats: controller.userStats!),
            SizedBox(
              height: 400,
              child: _isInitialLoad
                  ? const Center(child: CircularProgressIndicator())
                  : const ProfileTabs(),
            ),
            if (controller.error != null) _buildErrorWidget(controller),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Disabilita il back nativo
      onPopInvokedWithResult: (didPop, result) {
        // Naviga sempre alla home quando si tenta il back
        context.go('/home');
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              context.go('/home');
            },
            tooltip: 'Home',
          ),
          title: const Text(
            'Il Mio Profilo',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _handleLogout,
              tooltip: 'Logout',
            ),
          ],
        ),
        body: Consumer<ProfileController>(
          builder: (context, controller, child) {
            return _buildProfileBody(controller);
          },
        ),
      ),
    );
  }
}
