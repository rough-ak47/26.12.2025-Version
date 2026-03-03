import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
//import '../models/user_model.dart';
import '../providers/home_provider.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';
import '../widgets/profile/profile_header.dart';
import '../widgets/profile/profile_options.dart';
import '../widgets/profile/profile_statistics.dart';
import '../widgets/profile/profile_settings.dart';
import '../widgets/profile/edit_profile_dialog.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: const Color(0xFFE8F5E8),
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFFAFAFA),
      body: Consumer2<HomeProvider, AuthProvider>(
        builder: (context, homeProvider, authProvider, child) {
          final user = authProvider.user ?? homeProvider.currentUser;

          if (homeProvider.isLoading || authProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Profile Header
                ProfileHeader(user: user),
                const SizedBox(height: 24),

                // Profile Options
                ProfileOptions(
                  onEditProfile: () => _showEditProfileDialog(context),
                  onRequestHistory: () {
                    // Navigate to detailed request history
                  },
                  onMyImpact: () => _showImpactDialog(context),
                ),
                const SizedBox(height: 24),

                // Statistics
                ProfileStatistics(statistics: homeProvider.statistics),
                const SizedBox(height: 24),

                // Settings
                ProfileSettings(
                  onNotifications: () {
                    // Navigate to notification settings
                  },
                  onHelp: () => _showHelpDialog(context),
                  onAbout: () => _showAboutDialog(context),
                  onLogout: () => _showLogoutDialog(context),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const EditProfileDialog(),
    );
  }

  void _showImpactDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Your Environmental Impact'),
        content: const Text(
          'By recycling your e-waste through our platform, you have contributed to reducing electronic waste and promoting sustainable practices. Thank you for making a difference!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help & Support'),
        content: const Text(
          'Need help? Contact our support team at support@ewastecollector.com or call +1-800-EWASTE for assistance.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About E-Waste Collector'),
        content: const Text(
          'E-Waste Collector v1.0.0\n\nAn app to help you responsibly dispose of electronic waste and contribute to a cleaner environment.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final authProvider =
                  Provider.of<AuthProvider>(context, listen: false);
              await authProvider.logout();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => const LoginScreen(),
                  ),
                  (route) => false,
                );
              }
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
