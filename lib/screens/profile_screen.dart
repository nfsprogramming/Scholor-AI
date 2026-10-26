import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme.dart';
import '../services/app_state.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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
    int totalLessons = 0;
    int completedLessons = 0;
    for (var c in _appState.allCourses) {
      totalLessons += c.lessons.length;
      completedLessons += c.lessons.where((l) => l.isCompleted).length;
    }

    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              // Profile Header
              Center(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.primary, width: 2),
                      ),
                      child: CircleAvatar(
                        radius: 56,
                        backgroundImage: NetworkImage(
                          _authService.currentUser?.photoURL ?? 
                          "https://ui-avatars.com/api/?name=${_authService.currentUser?.displayName ?? 'User'}&background=4A40E0&color=fff"
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _authService.currentUser?.displayName ?? "The Fluid Scholor",
                      style: AppTheme.lightTheme.textTheme.displayMedium?.copyWith(fontSize: 24, fontWeight: FontWeight.w900),
                    ),
                    Text(
                      _authService.currentUser?.email ?? "master@scholar.ai",
                      style: TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 14),
                    ),
                  ],
                ),
              ).animate().fadeIn().scale(),

              const SizedBox(height: 48),

              // Stats Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatItem("COURSES", _appState.downloadedCourses.length.toString()),
                  _buildStatDivider(),
                  _buildStatItem("MASTERED", "$completedLessons/$totalLessons"),
                  _buildStatDivider(),
                  _buildStatItem("STREAK", "12D"),
                ],
              ).animate().slideY(begin: 0.2, end: 0),

              const SizedBox(height: 48),

              // Menu Options
              _buildMenuCard([
                _buildMenuItem(
                  Icons.cloud_sync_outlined, 
                  "Sync Progress to Cloud",
                  subtitle: _appState.lastSyncTime != null 
                    ? "Last synced: ${_appState.lastSyncTime!.hour}:${_appState.lastSyncTime!.minute.toString().padLeft(2, '0')}"
                    : "Not synced yet",
                  trailing: _appState.isSyncing 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : null,
                  onTap: () => _appState.syncToCloud(),
                ),
                _buildMenuItem(
                  Icons.settings_outlined, 
                  "Learning Preferences",
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Learning Preferences coming soon in Scholar v2.1!"))),
                ),
                _buildMenuItem(
                  Icons.notifications_none, 
                  "Smart Study Reminders",
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Notifications will start when your streak is in danger!"))),
                ),
                _buildMenuItem(
                  Icons.shield_outlined, 
                  "Data & Privacy",
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("All your data is encrypted locally on this device."))),
                ),
              ]),

              const SizedBox(height: 24),

              _buildMenuCard([
                _buildMenuItem(
                  Icons.help_outline, 
                  "Scholar Support Center",
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Contact support at help@scholar.ai"))),
                ),
                _buildMenuItem(Icons.logout, "Sign Out", isDestructive: true),
              ]),

              const SizedBox(height: 40),
              
              Text(
                "APP VERSION 2.0.4 - SCHOLAR CORE",
                style: TextStyle(color: AppTheme.onSurfaceVariant.withOpacity(0.4), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 24, color: AppTheme.primary)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: AppTheme.onSurfaceVariant.withOpacity(0.6), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
      ],
    );
  }

  Widget _buildStatDivider() {
    return Container(width: 1, height: 24, color: AppTheme.surfaceContainerHighest);
  }

  Widget _buildMenuCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildMenuItem(IconData icon, String label, {
    String? subtitle,
    Widget? trailing,
    bool isDestructive = false,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: isDestructive ? AppTheme.error : AppTheme.onSurfaceVariant),
      title: Text(
        label,
        style: TextStyle(
          color: isDestructive ? AppTheme.error : AppTheme.onSurface,
          fontWeight: isDestructive ? FontWeight.w800 : FontWeight.w600,
          fontSize: 15,
        ),
      ),
      subtitle: subtitle != null 
          ? Text(subtitle, style: TextStyle(color: AppTheme.onSurfaceVariant.withOpacity(0.6), fontSize: 12))
          : null,
      trailing: trailing ?? Icon(Icons.chevron_right, size: 18, color: AppTheme.onSurfaceVariant.withOpacity(0.3)),
      onTap: onTap ?? () async {
        if (isDestructive) {
          await _authService.signOut();
          if (!mounted) return;
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
          );
        }
      },
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
    );
  }
}
