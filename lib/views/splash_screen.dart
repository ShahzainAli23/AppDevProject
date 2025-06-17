import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';
import 'MainNavigationController.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _scaleAnim = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).chain(CurveTween(curve: Curves.elasticOut)).animate(_controller);

    _controller.forward();

    Future.delayed(const Duration(seconds: 3), () {
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // Already logged in user
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const MainNavigationController(isGuest: false),
          ),
        );
      } else {
        // Not logged in, go to login screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: ScaleTransition(
          scale: _scaleAnim,
          child: Image.asset('assets/darbs_logo.png', width: 220),
        ),
      ),
    );
  }
}
