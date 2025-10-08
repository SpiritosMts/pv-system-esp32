import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/auth_provider.dart';

class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Info Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    final user = authProvider.user;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start, // Align items to start
                      children: [
                        Center(
                          // Center the avatar
                          child: CircleAvatar(
                            radius: 40,
                            backgroundColor: Theme.of(context).primaryColor,
                            child: Text(
                              user?.email?.substring(0, 1).toUpperCase() ?? 'U',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Center(
                          // Center the email text
                          child: Text(
                            user?.email ?? 'No email',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Center(
                          // Center the user type text
                          child: Text(
                            'PV System Monitor User',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey[600],
                                ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ).animate().slideY(begin: 0.3, delay: 100.ms, duration: 600.ms).fadeIn(delay: 100.ms, duration: 600.ms),

            const SizedBox(height: 20),

            // Settings Options
            Text(
              'Preferences',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ).animate().slideX(begin: -0.3, delay: 200.ms, duration: 600.ms).fadeIn(delay: 200.ms, duration: 600.ms),

            const SizedBox(height: 16),

            _buildSettingsItem(
              context,
              icon: Icons.notifications,
              title: 'Notifications',
              subtitle: 'Configure alert preferences',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Notifications settings - Coming soon!')),
                );
              },
            ).animate().slideX(begin: 0.3, delay: 300.ms, duration: 600.ms).fadeIn(delay: 300.ms, duration: 600.ms),

            _buildSettingsItem(
              context,
              icon: Icons.palette,
              title: 'Theme',
              subtitle: 'Light, dark, or system default',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Theme settings - Coming soon!')),
                );
              },
            ).animate().slideX(begin: -0.3, delay: 400.ms, duration: 600.ms).fadeIn(delay: 400.ms, duration: 600.ms),

            _buildSettingsItem(
              context,
              icon: Icons.language,
              title: 'Language',
              subtitle: 'Choose your preferred language',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Language settings - Coming soon!')),
                );
              },
            ).animate().slideX(begin: 0.3, delay: 500.ms, duration: 600.ms).fadeIn(delay: 500.ms, duration: 600.ms),

            // Clear History Button
            _buildSettingsItem(
              context,
              icon: Icons.delete_outline,
              title: 'Clear History',
              subtitle: 'Delete all historical data',
              onTap: () {
                _showClearHistoryDialog(context);
              },
            ).animate().slideX(begin: -0.3, delay: 600.ms, duration: 600.ms).fadeIn(delay: 600.ms, duration: 600.ms),

            const SizedBox(height: 20),

            // About Section
            Text(
              'About',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ).animate().slideX(begin: -0.3, delay: 700.ms, duration: 600.ms).fadeIn(delay: 700.ms, duration: 600.ms),

            const SizedBox(height: 16),

            _buildSettingsItem(
              context,
              icon: Icons.info,
              title: 'App Version',
              subtitle: '1.0.0',
              onTap: () {},
            ).animate().slideX(begin: 0.3, delay: 800.ms, duration: 600.ms).fadeIn(delay: 800.ms, duration: 600.ms),

            _buildSettingsItem(
              context,
              icon: Icons.help,
              title: 'Help & Support',
              subtitle: 'Get help with the app',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Help & Support - Coming soon!')),
                );
              },
            ).animate().slideX(begin: -0.3, delay: 900.ms, duration: 600.ms).fadeIn(delay: 900.ms, duration: 600.ms),

            const SizedBox(height: 32),

            // Sign Out Button
            Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Sign Out'),
                          content: const Text('Are you sure you want to sign out?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                authProvider.signOut();
                              },
                              child: const Text('Sign Out'),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text('Sign Out'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                );
              },
            ).animate().slideY(begin: 0.3, delay: 1000.ms, duration: 600.ms).fadeIn(delay: 1000.ms, duration: 600.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Theme.of(context).primaryColor,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  void _showClearHistoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear History'),
        content: const Text('Are you sure you want to delete all historical data? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement clear history functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('History cleared successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Clear History'),
          ),
        ],
      ),
    );
  }
}
