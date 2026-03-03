import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import '../../providers/auth_provider.dart';
import '../../providers/home_provider.dart';
import '../../services/supabase_repositories.dart';

class EditProfileDialog extends StatefulWidget {
  const EditProfileDialog({super.key});

  @override
  State<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController addressController;
  late TextEditingController cityController;
  late TextEditingController countryController;

  File? newProfileImage;
  Uint8List? newProfileImageBytes;
  bool isUploading = false;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    nameController = TextEditingController(text: user?.name ?? '');
    phoneController = TextEditingController(text: user?.phoneNumber ?? user?.phone ?? '');
    addressController = TextEditingController(text: user?.address ?? '');
    cityController = TextEditingController(text: user?.city ?? '');
    countryController = TextEditingController(text: user?.country ?? '');
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    cityController.dispose();
    countryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user == null) return const SizedBox.shrink();

    return AlertDialog(
      title: const Text('Edit Profile'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Profile Image Picker
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 40,
                backgroundColor: Colors.grey[200],
                backgroundImage: newProfileImageBytes != null
                    ? MemoryImage(newProfileImageBytes!)
                    : newProfileImage != null
                        ? FileImage(newProfileImage!)
                        : (user.profileImageUrl != null
                            ? NetworkImage(user.profileImageUrl!)
                            : null) as ImageProvider?,
                child: (newProfileImage == null &&
                        newProfileImageBytes == null &&
                        user.profileImageUrl == null)
                    ? const Icon(Icons.camera_alt, color: Colors.grey)
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: addressController,
              decoration: const InputDecoration(
                labelText: 'Address',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: cityController,
                    decoration: const InputDecoration(
                      labelText: 'City',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: countryController,
                    decoration: const InputDecoration(
                      labelText: 'Country',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: isUploading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: isUploading ? null : _saveProfile,
          child: isUploading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save'),
        ),
      ],
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 500,
      maxHeight: 500,
    );
    if (picked != null) {
      if (kIsWeb) {
        final bytes = await picked.readAsBytes();
        setState(() {
          newProfileImageBytes = bytes;
          newProfileImage = null;
        });
      } else {
        setState(() {
          newProfileImage = File(picked.path);
          newProfileImageBytes = null;
        });
      }
    }
  }

  Future<void> _saveProfile() async {
    setState(() => isUploading = true);
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final storageRepo = StorageRepository();
      final user = authProvider.user!;

      // 1. Upload Image if changed
      if (newProfileImage != null || newProfileImageBytes != null) {
        final file = kIsWeb ? newProfileImageBytes! : newProfileImage!;
        final url = await storageRepo.uploadProfilePhoto(
          file: file,
          userId: user.id,
        );
        await authProvider.updateProfile({'profile_image_url': url});
      }

      // 2. Update Text Fields
      final updates = {
        'full_name': nameController.text.trim(),
        'phone': phoneController.text.trim(),
        'address': addressController.text.trim(),
        'city': cityController.text.trim(),
        'country': countryController.text.trim(),
      };

      final success = await authProvider.updateProfile(updates);

      if (!mounted) return;

      if (success) {
        // Refresh HomeProvider to update UI everywhere
        Provider.of<HomeProvider>(context, listen: false).loadData();

        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update profile'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => isUploading = false);
    }
  }
}
