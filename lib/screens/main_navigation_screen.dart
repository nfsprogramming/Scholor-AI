import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:math' as math;
import '../theme.dart';
import 'home_screen.dart';
import 'syllabus_screen.dart';
import 'ai_tutor_screen.dart';
import 'profile_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomeScreen(onProfileTapped: () => _onItemTapped(3)),
      const SyllabusScreen(),
      const AiTutorScreen(),
      const ProfileScreen(),
    ];
  }

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.02, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
        child: Container(
          key: ValueKey<int>(_selectedIndex),
          child: _pages[_selectedIndex],
        ),
      ),
      bottomNavigationBar: _LiquidNavBar(
        selectedIndex: _selectedIndex,
        onItemSelected: _onItemTapped,
      ),
    );
  }
}

class _LiquidNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  const _LiquidNavBar({
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const double horizontalMargin = 20.0;
    const double barHeight = 72.0;
    // Calculate the width of the navigation bar itself
    final double navBarWidth = screenWidth - (horizontalMargin * 2);
    // Width of each tab item
    final double tabWidth = navBarWidth / 4;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(horizontalMargin, 0, horizontalMargin, 16),
        child: Container(
          height: barHeight,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: Colors.white.withOpacity(0.6), width: 1),
            boxShadow: [
              BoxShadow(
                color: AppTheme.onSurface.withOpacity(0.05),
                blurRadius: 32,
                offset: const Offset(0, 8),
              )
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Stack(
                children: [
                  // The liquid glass morphing pill
                  _LiquidMorphPill(
                    selectedIndex: selectedIndex,
                    tabWidth: tabWidth,
                  ),
                  // The navigation items
                  Row(
                    children: [
                      _buildNavItem(0, Icons.home_outlined, Icons.home, 'Home', tabWidth),
                      _buildNavItem(1, Icons.menu_book_outlined, Icons.menu_book, 'Syllabus', tabWidth),
                      _buildNavItem(2, Icons.smart_toy_outlined, Icons.smart_toy, 'AI Tutor', tabWidth),
                      _buildNavItem(3, Icons.person_outline, Icons.person, 'Profile', tabWidth),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData inactiveIcon, IconData activeIcon, String label, double width) {
    final bool isActive = selectedIndex == index;
    
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onItemSelected(index),
      child: SizedBox(
        width: width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              scale: isActive ? 1.06 : 0.95,
              duration: const Duration(milliseconds: 450),
              curve: _LiquidMorphPill.softSpring,
              child: Icon(
                isActive ? activeIcon : inactiveIcon,
                color: isActive ? AppTheme.primary : AppTheme.onSurfaceVariant.withOpacity(0.6),
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOut,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
                color: isActive ? AppTheme.primary : AppTheme.onSurfaceVariant.withOpacity(0.6),
                fontFamily: AppTheme.lightTheme.textTheme.bodyMedium?.fontFamily ?? 'Inter',
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}

class _LiquidMorphPill extends StatefulWidget {
  final int selectedIndex;
  final double tabWidth;
  
  static const Curve softSpring = Cubic(0.34, 1.3, 0.64, 1.0);

  const _LiquidMorphPill({
    Key? key,
    required this.selectedIndex,
    required this.tabWidth,
  }) : super(key: key);

  @override
  State<_LiquidMorphPill> createState() => _LiquidMorphPillState();
}

class _LiquidMorphPillState extends State<_LiquidMorphPill> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int _oldIndex = 0;
  int _newIndex = 0;

  @override
  void initState() {
    super.initState();
    _oldIndex = widget.selectedIndex;
    _newIndex = widget.selectedIndex;
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 550));
    _animation = Tween<double>(begin: _oldIndex.toDouble(), end: _newIndex.toDouble())
        .animate(CurvedAnimation(parent: _controller, curve: _LiquidMorphPill.softSpring));
  }

  @override
  void didUpdateWidget(_LiquidMorphPill oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      _oldIndex = _animation.value.round(); 
      _newIndex = widget.selectedIndex;
      
      _animation = Tween<double>(begin: _animation.value, end: _newIndex.toDouble())
          .animate(CurvedAnimation(parent: _controller, curve: _LiquidMorphPill.softSpring));
      
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final currentValue = _animation.value;
        final t = _controller.value;
        final distance = (_newIndex - _oldIndex).abs().toDouble();
        
        // Dynamic stretch based on distance
        final stretchMax = distance * 18.0; 
        final stretch = math.sin(t * math.pi) * stretchMax;

        final center = (currentValue + 0.5) * widget.tabWidth;
        final currentWidth = widget.tabWidth + stretch;
        final left = center - (currentWidth / 2);

        // Vertical compression
        final verticalInset = 8.0 + (stretch * 0.12);

        return Positioned(
          left: left,
          top: verticalInset,
          bottom: verticalInset,
          child: Container(
            width: currentWidth,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withOpacity(0.55),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withOpacity(0.15),
                    blurRadius: 12,
                    spreadRadius: 2,
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
