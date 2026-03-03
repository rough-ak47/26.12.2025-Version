import 'package:flutter/material.dart';

class ProfileOptions extends StatelessWidget {
  final VoidCallback onEditProfile;
  final VoidCallback onRequestHistory;
  final VoidCallback onMyImpact;

  const ProfileOptions({
    super.key,
    required this.onEditProfile,
    required this.onRequestHistory,
    required this.onMyImpact,
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
            icon: Icons.edit,
            title: 'Edit Profile',
            onTap: onEditProfile,
          ),
          const Divider(height: 1),
          _buildProfileOption(
            icon: Icons.history,
            title: 'Request History',
            onTap: onRequestHistory,
          ),
          const Divider(height: 1),
          _buildProfileOption(
            icon: Icons.analytics,
            title: 'My Impact',
            onTap: onMyImpact,
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
