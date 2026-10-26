import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math' as math;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/app_state.dart';
import 'onboarding_screen.dart';
import 'login_screen.dart';
import 'main_navigation_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  _navigateToNext() async {
    await Future.wait([
      Future.delayed(const Duration(milliseconds: 3500)),
      AppState().init(),
    ]);
    
    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final bool isFirstTime = prefs.getBool('isFirstTime') ?? true;
    final bool isLoggedIn = FirebaseAuth.instance.currentUser != null;

    Widget nextScreen;
    if (isFirstTime) {
      nextScreen = const OnboardingScreen();
    } else if (isLoggedIn) {
      nextScreen = const MainNavigationScreen();
    } else {
      nextScreen = const LoginScreen();
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => nextScreen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Nebula Mesh Background
          _buildNebulaBackground(),

          // 2. Pattern Overlay (Subtle dots/grid)
          _buildPatternOverlay(),

          // 3. Floating Decorative Nodes
          _buildFloatingNodes(),

          // 4. Main Content Shell
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo Cluster
                _buildLogoCluster(),
                const SizedBox(height: 48),

                // Branding Text
                _buildBranding(),
                const SizedBox(height: 96),

                // Loading Indicator
                _buildLoadingIndicator(),

                const SizedBox(height: 32),
                // Bottom Context
                _buildBottomContext(),
              ],
            ).animate().fadeIn(duration: 700.ms).scale(
                  begin: const Offset(0.9, 0.9),
                  end: const Offset(1.0, 1.0),
                  duration: 700.ms,
                  curve: Curves.easeOutCubic,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildNebulaBackground() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: const Color(0xFFFAF4FF),
      child: Stack(
        children: [
          // Top Left Blur
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF4A40E0).withOpacity(0.15),
              ),
            ).animate(onPlay: (controller) => controller.repeat(reverse: true))
             .move(begin: const Offset(-20, -20), end: const Offset(20, 20), duration: 4.seconds),
          ).animate().blur(begin: const Offset(80, 80), end: const Offset(120, 120)),

          // Bottom Right Blur
          Positioned(
            bottom: -100,
            right: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF702AE1).withOpacity(0.15),
              ),
            ).animate(onPlay: (controller) => controller.repeat(reverse: true))
             .move(begin: const Offset(20, 20), end: const Offset(-20, -20), duration: 5.seconds),
          ).animate().blur(begin: const Offset(80, 80), end: const Offset(120, 120)),
        ],
      ),
    );
  }

  Widget _buildPatternOverlay() {
    return Opacity(
      opacity: 0.05,
      child: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: NetworkImage("https://www.transparenttextures.com/patterns/micro-carbon.png"), // Subtle pattern
            repeat: ImageRepeat.repeat,
          ),
        ),
      ),
    );
  }

  Widget _buildLogoCluster() {
    return SizedBox(
      height: 192,
      width: 192,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer Rims
          Transform.rotate(
            angle: 12 * math.pi / 180,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(40),
                gradient: const LinearGradient(
                  colors: [Color(0xFF4A40E0), Color(0xFF702AE1)],
                ),
              ),
            ).animate().custom(builder: (context, value, child) => Opacity(opacity: 0.1 * value, child: child)),
          ),
          Transform.rotate(
            angle: -6 * math.pi / 180,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(40),
                gradient: const LinearGradient(
                  colors: [Color(0xFF4A40E0), Color(0xFF702AE1)],
                ),
              ),
            ).animate().custom(builder: (context, value, child) => Opacity(opacity: 0.1 * value, child: child)),
          ),

          // Main Icon Container
          Container(
            width: 128,
            height: 128,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF4A40E0), Color(0xFF702AE1)],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4A40E0).withOpacity(0.3),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                )
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.psychology, size: 64, color: Colors.white)
                    .animate(onPlay: (controller) => controller.repeat(reverse: true))
                    .shimmer(delay: 1.seconds, duration: 2.seconds),
                const Icon(Icons.menu_book, size: 24, color: Color(0xFFDEF7FF)),
              ],
            ),
          ).animate().scale(delay: 200.ms, duration: 500.ms, curve: Curves.easeOutBack),
        ],
      ),
    );
  }

  Widget _buildBranding() {
    return Column(
      children: [
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFF4A40E0), Color(0xFF702AE1)],
          ).createShader(bounds),
          child: const Text(
            "Scholor",
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 56,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -2,
            ),
          ),
        ).animate().slideY(begin: 0.2, end: 0, duration: 600.ms),
        const SizedBox(height: 8),
        RichText(
          textAlign: TextAlign.center,
          text: const TextSpan(
            style: TextStyle(
              color: Color(0xFF5F557F),
              fontSize: 18,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
            children: [
              TextSpan(text: "Learn Anytime.\n"),
              TextSpan(
                text: "Even Offline.",
                style: TextStyle(
                  color: Color(0xFF4A40E0),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 400.ms),
      ],
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      width: 192,
      height: 6,
      decoration: BoxDecoration(
        color: const Color(0xFFEDE4FF),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Stack(
        children: [
          Container(
            width: 60,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4A40E0), Color(0xFF702AE1)],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
          ).animate(onPlay: (controller) => controller.repeat())
           .moveX(begin: -60, end: 192, duration: 1500.ms, curve: Curves.easeInOutExpo),
        ],
      ),
    );
  }

  Widget _buildBottomContext() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.auto_awesome, size: 16, color: Color(0xFF5F557F)),
        const SizedBox(width: 8),
        Text(
          "AI ENHANCED EXPERIENCE",
          style: TextStyle(
            color: const Color(0xFF5F557F).withOpacity(0.6),
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 2,
          ),
        ),
      ],
    ).animate().fadeIn(delay: 1.seconds);
  }

  Widget _buildFloatingNodes() {
    return Stack(
      children: [
        // Offline Ready Node
        Positioned(
          top: 150,
          left: 40,
          child: _buildFloatingBox(
            icon: Icons.cloud_off,
            text: "Offline Ready",
            color: const Color(0xFF4A40E0),
            rotation: 0.05,
          ),
        ).animate(onPlay: (controller) => controller.repeat(reverse: true))
         .moveY(begin: -10, end: 10, duration: 3.seconds),

        // AI Tutor Active Node
        Positioned(
          bottom: 150,
          right: 30,
          child: _buildFloatingBox(
            icon: Icons.smart_toy,
            text: "AI Tutor Active",
            color: const Color(0xFF702AE1),
            rotation: -0.1,
          ),
        ).animate(onPlay: (controller) => controller.repeat(reverse: true))
         .moveY(begin: 10, end: -10, duration: 4.seconds),
      ],
    );
  }

  Widget _buildFloatingBox({
    required IconData icon,
    required String text,
    required Color color,
    required double rotation,
  }) {
    return Opacity(
      opacity: 0.4,
      child: Transform.rotate(
        angle: rotation,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFE8DEFF),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 10),
              Text(
                text,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF32294F),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
