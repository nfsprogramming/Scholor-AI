import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme.dart';
import '../services/app_state.dart';
import '../services/auth_service.dart';
import 'lesson_player_screen.dart';

class DownloadsScreen extends StatefulWidget {
  const DownloadsScreen({super.key});

  @override
  State<DownloadsScreen> createState() => _DownloadsScreenState();
}

class _DownloadsScreenState extends State<DownloadsScreen> {
  final AppState _appState = AppState();
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _appState.addListener(_onStateChange);
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
    final downloaded = _appState.allCourses.where((c) => c.isDownloaded || _appState.isDownloading(c.id)).toList();

    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Offline Library",
                style: AppTheme.lightTheme.textTheme.displayMedium?.copyWith(fontSize: 28, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              Text(
                "${downloaded.length} course${downloaded.length == 1 ? '' : 's'} managed for offline",
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(color: AppTheme.onSurfaceVariant),
              ),
              const SizedBox(height: 40),

              if (downloaded.isEmpty)
                _buildEmptyState()
              else
                ...downloaded.map((course) => _buildCourseItem(course)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 100),
          Icon(Icons.cloud_off, size: 80, color: AppTheme.surfaceContainerHighest),
          const SizedBox(height: 24),
          Text(
            "Nothing Here Yet",
            style: TextStyle(color: AppTheme.onSurface, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            "Go to Home to find and download\ncourses for offline study.",
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.onSurfaceVariant),
          ),
        ],
      ),
    ).animate().fadeIn().scale();
  }

  Widget _buildCourseItem(Course course) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(course.thumbnail, width: 80, height: 80, fit: BoxFit.cover),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(course.title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                    const SizedBox(height: 4),
                    Text(course.instructor, style: TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 14)),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _appState.toggleDownload(course.id),
                icon: _appState.isDownloading(course.id)
                  ? const Icon(Icons.close, color: AppTheme.onSurfaceVariant)
                  : const Icon(Icons.delete_outline, color: AppTheme.error),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Builder(builder: (ctx) {
            final isDownloading = _appState.isDownloading(course.id);
            final progress = isDownloading 
                ? _appState.getDownloadProgress(course.id)
                : _appState.getCourseProgress(course.id);
            final completed = course.lessons.where((l) => l.isCompleted).length;
            
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isDownloading 
                        ? "Downloading content..."
                        : "$completed / ${course.lessons.length} lessons completed",
                      style: TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      "${(progress * 100).toInt()}%",
                      style: TextStyle(color: isDownloading ? AppTheme.primary : AppTheme.primary, fontSize: 12, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: AppTheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation<Color>(isDownloading ? AppTheme.primary : AppTheme.primary),
                  ),
                ),
              ],
            );
          }),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LessonPlayerScreen(course: course, lesson: course.lessons[0])),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text("RESUME LESSON", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12, letterSpacing: 1)),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().slideX(begin: 0.1, end: 0);
  }
}
