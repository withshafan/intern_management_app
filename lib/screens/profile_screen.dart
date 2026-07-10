import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/auth_service.dart';
import '../widgets/glass_card.dart';
import '../theme/app_colors.dart';
import '../main.dart' show themeNotifier;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _auth = AuthService();

  void _signOut() async {
    try {
      await _auth.signOut();
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.danger),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // User Avatar Header
            GlassCard(
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: AppColors.primary.withOpacity(0.5), blurRadius: 20, spreadRadius: 2),
                      ],
                    ),
                    child: const CircleAvatar(
                      radius: 50,
                      backgroundColor: AppColors.primary,
                      child: Icon(Icons.person, size: 50, color: Colors.white),
                    ),
                  ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
                  const SizedBox(height: 16),
                  Text(
                    user?.email ?? 'Admin User',
                    style: Theme.of(context).textTheme.titleLarge,
                  ).animate().fadeIn(delay: 200.ms),
                  const SizedBox(height: 4),
                  const Text('System Administrator', style: TextStyle(color: Colors.grey)).animate().fadeIn(delay: 300.ms),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1),
            const SizedBox(height: 16),

            // Settings Section
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Preferences', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
                  const SizedBox(height: 16),
                  ValueListenableBuilder<ThemeMode>(
                    valueListenable: themeNotifier,
                    builder: (context, currentMode, _) {
                      final isDark = currentMode == ThemeMode.dark;
                      final onSurface = Theme.of(context).colorScheme.onSurface;
                      return ListTile(
                        leading: Icon(isDark ? Icons.dark_mode : Icons.light_mode, color: onSurface),
                        title: const Text('Dark Mode'),
                        trailing: Switch(
                          value: isDark,
                          activeColor: AppColors.primary,
                          onChanged: (val) {
                            themeNotifier.value = val ? ThemeMode.dark : ThemeMode.light;
                          },
                        ),
                      );
                    },
                  ),
                  Divider(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1)),
                  ListTile(
                    leading: Icon(Icons.notifications_active, color: Theme.of(context).colorScheme.onSurface),
                    title: const Text('Push Notifications'),
                    trailing: Switch(
                      value: true,
                      activeColor: AppColors.primary,
                      onChanged: (val) {},
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 150.ms, duration: 400.ms).slideY(begin: 0.1),
            const SizedBox(height: 16),
            
            // Made by withshafan
            Center(
              child: const Text(
                'Made by withshafan',
                style: TextStyle(
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w500,
                ),
              ).animate().fadeIn(delay: 200.ms),
            ),
            const SizedBox(height: 16),

            // Danger Zone
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Account', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.danger)),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const Icon(Icons.logout, color: AppColors.danger),
                    title: const Text('Sign Out', style: TextStyle(color: AppColors.danger)),
                    onTap: _signOut,
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 250.ms, duration: 400.ms).slideY(begin: 0.1),
          ],
        ),
      ),
    );
  }
}
