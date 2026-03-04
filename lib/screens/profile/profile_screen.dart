import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:orsocook/services/profile_controller.dart';
import 'package:orsocook/screens/profile/profile_body.dart';
import 'package:orsocook/services/logout_manager.dart';

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
      await _profileController?.loadProfile();
      if (mounted) setState(() => _isInitialLoad = false);
    } catch (e) {
      if (kDebugMode) debugPrint('Errore caricamento profilo: $e');
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
              LogoutManager.performLogout(context);
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showSuccessMessage(String message) {
    if (_lastShownMessage == message || !mounted) return;
    _lastShownMessage = message;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
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
      ),
    );

    Future.delayed(const Duration(seconds: 4), () {
      if (mounted && _lastShownMessage == message) {
        _lastShownMessage = null;
        _profileController?.clearSuccessMessage();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) => context.go('/home'),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.home),
            onPressed: () => context.go('/home'),
            tooltip: 'Home',
          ),
          title: const Text('Il Mio Profilo',
              style: TextStyle(fontWeight: FontWeight.bold)),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _handleLogout,
              tooltip: 'Logout',
            ),
          ],
        ),
        body: Consumer<ProfileController>(
          builder: (context, controller, child) => ProfileBody(
            controller: controller,
            isInitialLoad: _isInitialLoad,
            lastShownMessage: _lastShownMessage,
            onShowSuccessMessage: _showSuccessMessage,
          ),
        ),
      ),
    );
  }
}
