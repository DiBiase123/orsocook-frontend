import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:orsocook/screens/auth/login_modal/index.dart';
import 'package:orsocook/screens/auth/register_modal/index.dart';
import 'package:orsocook/screens/auth/forgot_password_modal/index.dart';

class AuthDialog extends StatefulWidget {
  const AuthDialog({super.key});

  @override
  State<AuthDialog> createState() => _AuthDialogState();
}

class _AuthDialogState extends State<AuthDialog> {
  late Widget _currentScreen;
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _loginKey = GlobalKey();
  double _loginHeight = 0;
  bool _heightMeasured = false;

  void _scrollToTop() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _currentScreen = LoginModal(
      key: _loginKey,
      onNavigateToRegister: () => _navigateToRegister(),
      onNavigateToForgotPassword: () => _navigateToForgotPassword(),
      onClose: () => _closeDialog(),
    );
  }

  void _measureLoginHeight() {
    if (_heightMeasured) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final box = _loginKey.currentContext?.findRenderObject() as RenderBox?;
      if (box != null && box.hasSize) {
        _loginHeight = box.size.height;
        _heightMeasured = true;
      }
    });
  }

  void _navigateToRegister() {
    _measureLoginHeight();
    setState(() {
      _currentScreen = RegisterModal(
        onNavigateToLogin: () => _navigateToLogin(),
        onClose: () => _closeDialog(),
      );
    });
    _scrollToTop();
  }

  void _navigateToForgotPassword() {
    setState(() {
      _currentScreen = ForgotPasswordModal(
        onNavigateToLogin: () => _navigateToLogin(),
        onClose: () => _closeDialog(),
      );
    });
    _scrollToTop();
  }

  void _navigateToLogin() {
    setState(() {
      _currentScreen = LoginModal(
        onNavigateToRegister: () => _navigateToRegister(),
        onNavigateToForgotPassword: () => _navigateToForgotPassword(),
        onClose: () => _closeDialog(),
      );
    });
    _scrollToTop();
  }

  void _closeDialog() {
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final screenHeight = MediaQuery.of(context).size.height;

    final backgroundColor =
        isDarkMode ? Colors.black.withAlpha(230) : Colors.black.withAlpha(60);

    // Determina se siamo su Register
    final isRegister = _currentScreen is RegisterModal;
    final useFixedHeight = isRegister && _heightMeasured && _loginHeight > 0;

    // Widget da mostrare (con o senza altezza fissa per Register)
    Widget modalContent = _currentScreen;

    if (!isMobile && useFixedHeight) {
      modalContent = SizedBox(
        height: _loginHeight.clamp(0.0, screenHeight * 0.85),
        child: SingleChildScrollView(
          controller: _scrollController,
          child: _currentScreen,
        ),
      );
    } else if (!isMobile) {
      modalContent = SingleChildScrollView(
        controller: _scrollController,
        child: _currentScreen,
      );
    }

    return Stack(
      children: [
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            color: backgroundColor,
            width: double.infinity,
            height: double.infinity,
          ),
        ),
        Center(
          child: isMobile
              ? modalContent
              : ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: screenHeight * 0.85,
                  ),
                  child: modalContent,
                ),
        ),
      ],
    );
  }
}

Future<void> showLoginModal(BuildContext context) {
  return showDialog(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.transparent,
    useSafeArea: false,
    builder: (context) => const AuthDialog(),
  );
}
