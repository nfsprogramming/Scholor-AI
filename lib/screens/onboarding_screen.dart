import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _pages = [
    OnboardingData(
      title: "Scholor",
      subtitle: "Learn Anytime.\nEven Offline.",
      description: "Access world-class courses without worrying about cellular data or Wi-Fi connectivity.",
      icon: Icons.auto_stories,
      color: AppTheme.primary,
    ),
    OnboardingData(
      title: "AI Power",
      subtitle: "Your Personal\nAI Tutor.",
      description: "Ask questions, get explanations, and master any subject with the help of local AI.",
      icon: Icons.psychology,
      color: AppTheme.secondary,
    ),
    OnboardingData(
      title: "Offline Ready",
      subtitle: "Mastery in your\n Pocket.",
      description: "Download once, learn forever. Experience high-quality synchronized audio and text lessons.",
      icon: Icons.cloud_off,
      color: const Color(0xFF006576),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient Mesh
          _buildBackground(),

          PageView.builder(
            controller: _pageController,
            itemCount: _pages.length,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemBuilder: (context, index) => _buildPage(_pages[index]),
          ),

          // Bottom Navigation
          _buildBottomNav(),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      color: AppTheme.surface,
      child: Stack(
        children: [
          Positioned(
            top: -150,
            right: -150,
            child: Container(
              width: 500,
              height: 500,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primary.withOpacity(0.08),
              ),
            ).animate(onPlay: (controller) => controller.repeat(reverse: true))
             .scale(begin: const Offset(1, 1), end: const Offset(1.2, 1.2), duration: 6.seconds),
          ),
          Positioned(
            bottom: -100,
            left: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.secondary.withOpacity(0.08),
              ),
            ).animate(onPlay: (controller) => controller.repeat(reverse: true))
             .scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1), duration: 8.seconds),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(OnboardingData data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Illustration/Icon Shell
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: data.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(48),
            ),
            child: Icon(data.icon, size: 80, color: data.color)
                .animate(onPlay: (controller) => controller.repeat(reverse: true))
                .moveY(begin: -10, end: 10, duration: 2.seconds, curve: Curves.easeInOut),
          ).animate().fadeIn(duration: 800.ms).scale(begin: const Offset(0.8, 0.8)),

          const SizedBox(height: 60),

          // Titles
          Column(
            children: [
              Text(
                data.title,
                style: AppTheme.lightTheme.textTheme.displayLarge?.copyWith(
                  fontSize: 16,
                  color: data.color,
                  letterSpacing: 2,
                ),
              ).animate().fadeIn(delay: 200.ms),
              const SizedBox(height: 12),
              Text(
                data.subtitle,
                textAlign: TextAlign.center,
                style: AppTheme.lightTheme.textTheme.displayLarge?.copyWith(
                  fontSize: 40,
                  height: 1.1,
                  letterSpacing: -1,
                ),
              ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),
            ],
          ),

          const SizedBox(height: 24),

          // Description
          Text(
            data.description,
            textAlign: TextAlign.center,
            style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
              color: AppTheme.onSurfaceVariant,
              height: 1.6,
            ),
          ).animate().fadeIn(delay: 600.ms),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Positioned(
      bottom: 60,
      left: 40,
      right: 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Indicators
          Row(
            children: List.generate(
              _pages.length,
              (index) => AnimatedContainer(
                duration: 300.ms,
                margin: const EdgeInsets.only(right: 8),
                width: _currentPage == index ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _currentPage == index ? AppTheme.primary : AppTheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),

          // Next/Get Started Button
          GestureDetector(
            onTap: () async {
              if (_currentPage < _pages.length - 1) {
                _pageController.nextPage(duration: 500.ms, curve: Curves.easeOutCubic);
              } else {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('isFirstTime', false);
                if (!mounted) return;
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              }
            },
            child: Container(
              height: 64,
              width: _currentPage == _pages.length - 1 ? 160 : 64,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primary, AppTheme.secondary],
                ),
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  )
                ],
              ),
              child: Center(
                child: _currentPage == _pages.length - 1
                    ? const Text(
                        "GET STARTED",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          letterSpacing: 1,
                        ),
                      )
                    : const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 20),
              ),
            ),
          ).animate().scale(begin: const Offset(0.5, 0.5), end: const Offset(1, 1), delay: 800.ms),
        ],
      ),
    );
  }
}

class OnboardingData {
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final Color color;

  OnboardingData({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.color,
  });
}
