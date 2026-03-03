import 'package:flutter/material.dart';

class ProfileSettings extends StatelessWidget {
  final VoidCallback onNotifications;
  final VoidCallback onHelp;
  final VoidCallback onAbout;
  final VoidCallback onLogout;

  const ProfileSettings({
    super.key,
    required this.onNotifications,
    required this.onHelp,
    required this.onAbout,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildProfileOption(
            icon: Icons.notifications,
            title: 'Notifications',
            onTap: onNotifications,
          ),
          const Divider(height: 1),
          _buildProfileOption(
            icon: Icons.help,
            title: 'Help & Support',
            onTap: onHelp,
          ),
          const Divider(height: 1),
          _buildProfileOption(
            icon: Icons.info,
            title: 'About',
            onTap: onAbout,
          ),
          const Divider(height: 1),
          _buildProfileOption(
            icon: Icons.logout,
            title: 'Logout',
            onTap: onLogout,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: const Color(0xFF2E7D32),
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey,
      ),
      onTap: onTap,
    );
  }
}
