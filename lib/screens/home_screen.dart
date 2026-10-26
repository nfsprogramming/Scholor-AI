import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme.dart';
import '../services/app_state.dart';
import 'lesson_player_screen.dart';
import 'profile_screen.dart';
import 'dart:ui';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback? onProfileTapped;
  const HomeScreen({super.key, this.onProfileTapped});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AppState _appState = AppState();

  @override
  void initState() {
    super.initState();
    _appState.addListener(_onStateChange);
    if (_appState.allCourses.isEmpty) {
      _appState.init();
    }
  }

  void _onStateChange() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _appState.removeListener(_onStateChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_appState.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppTheme.surface,
        body: Stack(
          children: [
            // Background Decor
            _buildBackgroundElements(),

            // Main Content
            CustomScrollView(
              slivers: [
                _buildAppBar(),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 130),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      const SizedBox(height: 24),
                      _buildHeroSection(),
                      const SizedBox(height: 40),
                      _buildSectionHeader("Continue Learning"),
                      const SizedBox(height: 20),
                      _buildProgressRow(),
                      const SizedBox(height: 48),
                      _buildSectionHeader("Available Offline Courses"),
                      const SizedBox(height: 20),
                      ..._appState.allCourses.map((c) => _buildCourseCard(c)),
                    ]),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundElements() {
    return Stack(
      children: [
        Positioned(
          top: -50,
          left: -50,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.primary.withOpacity(0.05),
            ),
          ).animate(onPlay: (controller) => controller.repeat(reverse: true))
           .scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1), duration: 10.seconds),
        ),
      ],
    );
  }

  Widget _buildAppBar() {
    return SliverSafeArea(
      bottom: false,
      sliver: SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('MMMM dd, yyyy').format(DateTime.now()).toUpperCase(),
                    style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                      color: AppTheme.onSurfaceVariant.withOpacity(0.6),
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Welcome, ${_appState.userName.split(' ')[0]}",
                    style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  if (widget.onProfileTapped != null) {
                    widget.onProfileTapped!();
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ProfileScreen()),
                    );
                  }
                },
                child: _buildProfileAvatar(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileAvatar() {
    final hasImage = _appState.userImage != null && _appState.userImage!.isNotEmpty;
    final isNetwork = hasImage && _appState.userImage!.startsWith('http');

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerHigh.withOpacity(0.8),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.6), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.15),
            blurRadius: 12,
            spreadRadius: 2,
          )
        ],
      ),
      child: ClipOval(
        child: hasImage
            ? (isNetwork
                ? CachedNetworkImage(
                    imageUrl: _appState.userImage!,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => _buildInitials(),
                    errorWidget: (context, url, error) => _buildInitials(),
                  )
                : Image.file(
                    File(_appState.userImage!),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => _buildInitials(),
                  ))
            : _buildInitials(),
      ),
    );
  }

  Widget _buildInitials() {
    String initials = "??";
    final name = _appState.userName;
    if (name.isNotEmpty) {
      final parts = name.trim().split(RegExp(r'\s+'));
      if (parts.length == 1) {
        initials = parts[0].substring(0, 1).toUpperCase();
      } else {
        initials = (parts[0].substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
      }
    }
    return Container(
      color: AppTheme.primary.withOpacity(0.1),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: AppTheme.primary,
            fontWeight: FontWeight.w900,
            fontSize: 16,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.primary,
        borderRadius: BorderRadius.circular(32),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4A40E0), Color(0xFF702AE1)],
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.2),
            blurRadius: 30,
            offset: const Offset(0, 15),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(full_radius_placeholder),
            ),
            child: const Text(
              "NEW LESSON",
              style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "Master Modern\nPython Programming",
            style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900, height: 1.2),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              final course = _appState.allCourses.firstWhere((c) => c.id == "python_master");
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LessonPlayerScreen(course: course, lesson: course.lessons[0])),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppTheme.primary,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
            ),
            child: const Text("Keep Learning", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
          ),
        ],
      ),
    ).animate().slideY(begin: 0.1, end: 0, duration: 800.ms, curve: Curves.easeOutCubic);
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        GestureDetector(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Showing all $title content...")),
            );
          },
          child: Text(
            "VIEW ALL",
            style: TextStyle(color: AppTheme.primary, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.2),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressRow() {
    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        itemCount: _appState.allCourses.length,
        separatorBuilder: (_, __) => const SizedBox(width: 20),
        itemBuilder: (context, index) {
          final course = _appState.allCourses[index];
          final progress = _appState.getCourseProgress(course.id);
          return _buildProgressOrb(course.title[0], progress, course.title);
        },
      ),
    );
  }

  Widget _buildProgressOrb(String initial, double progress, String label) {
    return SizedBox(
      width: 80,
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 72,
                height: 72,
                child: CircularProgressIndicator(
                  value: 1.0,
                  strokeWidth: 5,
                  color: AppTheme.surfaceContainerHighest,
                ),
              ),
              SizedBox(
                width: 72,
                height: 72,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 5,
                  strokeCap: StrokeCap.round,
                  color: AppTheme.primary,
                ),
              ),
              Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: Center(
                  child: Text(
                    initial,
                    style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w900, fontSize: 20),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    ).animate().scale(delay: (100 * (progress * 10)).ms);
  }

  Widget _buildCourseCard(Course course) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              course.thumbnail,
              width: 100,
              height: 100,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course.title,
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
                ),
                const SizedBox(height: 4),
                Text(
                  course.instructor,
                  style: TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 14),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.star, size: 14, color: Colors.amber[700]),
                    const SizedBox(width: 4),
                    Text(course.rating.toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    const SizedBox(width: 12),
                    Icon(Icons.access_time_filled, size: 14, color: AppTheme.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(course.duration, style: const TextStyle(fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => LessonPlayerScreen(course: course, lesson: course.lessons[0])),
                          );
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: AppTheme.primary.withOpacity(0.1),
                          foregroundColor: AppTheme.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const Text("Start Learn", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      onPressed: () => _appState.toggleDownload(course.id),
                      icon: _appState.isDownloading(course.id)
                          ? Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    value: _appState.getDownloadProgress(course.id),
                                    strokeWidth: 2,
                                    color: AppTheme.primary,
                                  ),
                                ),
                                const Icon(Icons.download, size: 14, color: AppTheme.primary),
                              ],
                            )
                          : Icon(
                              course.isDownloaded ? Icons.download_done : Icons.download_for_offline_outlined,
                              color: course.isDownloaded ? Colors.green : AppTheme.primary,
                            ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideX(begin: 0.1, end: 0);
  }

  static const double full_radius_placeholder = 32;
}
