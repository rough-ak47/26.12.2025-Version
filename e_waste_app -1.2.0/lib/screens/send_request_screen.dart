import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_repositories.dart';
import 'dart:io';

class SendRequestScreen extends StatefulWidget {
  const SendRequestScreen({super.key});

  @override
  State<SendRequestScreen> createState() => _SendRequestScreenState();
}

class _SendRequestScreenState extends State<SendRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _itemTypeController = TextEditingController();
  final _addressController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();

  File? _selectedImage;
  Uint8List? _selectedImageBytes;
  bool _isLoading = false;
  bool _useRegisteredLocation = false;
  String? _registeredAddress;
  String? _registeredLocation;

  @override
  void dispose() {
    _itemTypeController.dispose();
    _addressController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Send Request'),
        backgroundColor: const Color(0xFFE8F5E8),
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFFAFAFA),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Upload Section
              _buildImageUploadSection(),
              const SizedBox(height: 24),

              // Form Fields
              _buildFormFields(),
              const SizedBox(height: 24),

              // Submit Button
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Upload E-Waste Photo',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color:
                    _selectedImage == null ? Colors.grey[300]! : Colors.green,
                width: 2,
                style: BorderStyle.solid,
              ),
            ),
            child: (_selectedImage == null && _selectedImageBytes == null)
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_photo_alternate,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap to add photo',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                    ],
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: kIsWeb
                        ? Image.memory(
                            _selectedImageBytes!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          )
                        : Image.file(
                            _selectedImage!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Checkbox(
              value: _useRegisteredLocation,
              onChanged: (val) async {
                if (val == null) return;
                if (val) {
                  final ok = await _loadRegisteredLocationIfNeeded();
                  if (!ok) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'Please add your address in profile first, then try again.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                    return;
                  }
                }
                setState(() {
                  _useRegisteredLocation = val;
                });
              },
              activeColor: const Color(0xFF2E7D32),
            ),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Collect from my registered location',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'Request Details',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 16),

        // Item Type
        _buildTextField(
          controller: _itemTypeController,
          label: 'Item Type',
          hint: 'e.g., Laptop, Mobile Phone, Tablet',
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter the item type';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        if (!_useRegisteredLocation) ...[
          // Address
          _buildTextField(
            controller: _addressController,
            label: 'Address',
            hint: 'Enter your complete address',
            maxLines: 3,
            validator: (value) {
              if (_useRegisteredLocation) return null;
              if (value == null || value.isEmpty) {
                return 'Please enter your address';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Location
          _buildTextField(
            controller: _locationController,
            label: 'Location',
            hint: 'City, State',
            validator: (value) {
              if (_useRegisteredLocation) return null;
              if (value == null || value.isEmpty) {
                return 'Please enter your location';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
        ],

        // Description (Optional)
        _buildTextField(
          controller: _descriptionController,
          label: 'Description (Optional)',
          hint: 'Additional details about the item',
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF2E7D32)),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitRequest,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2E7D32),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                'Submit Request',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      setState(() {
        if (kIsWeb) {
          _selectedImage = null;
          pickedFile.readAsBytes().then((bytes) {
            setState(() {
              _selectedImageBytes = bytes;
            });
          });
        } else {
          _selectedImage = File(pickedFile.path);
          _selectedImageBytes = null;
        }
      });
    }
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedImage == null && _selectedImageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload a photo of the e-waste item'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final client = Supabase.instance.client;
    final userId = client.auth.currentUser?.id;

    if (userId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please sign in to submit a request'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final itemsRepo = ItemsRepository();
      final pickupRepo = PickupRequestsRepository();
      final storageRepo = StorageRepository();

      final itemId = await itemsRepo.createItem(
        ownerId: userId,
        category: _itemTypeController.text.trim(),
        brand: null,
        model: null,
        status: 'listed',
        photos: const [],
      );

      String? photoPath;
      if (_selectedImage != null || _selectedImageBytes != null) {
        final uploadTarget = kIsWeb ? _selectedImageBytes! : _selectedImage!;
        photoPath = await storageRepo.uploadItemPhoto(
          file: uploadTarget,
          itemId: itemId,
        );
        await itemsRepo.updatePhotos(itemId, [photoPath]);
      }

      String pickupAddress;
      if (_useRegisteredLocation) {
        final ok = await _loadRegisteredLocationIfNeeded();
        if (!ok) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                    'Please add your address in profile first, then retry.'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }
        pickupAddress = _registeredLocation == null
            ? _registeredAddress!
            : '${_registeredAddress!} | ${_registeredLocation!}';
      } else {
        pickupAddress = _locationController.text.isEmpty
            ? _addressController.text.trim()
            : '${_addressController.text.trim()} | ${_locationController.text.trim()}';
      }

      await pickupRepo.createPickupRequest(
        itemId: itemId,
        requestedBy: userId,
        pickupAddress: pickupAddress,
        status: 'pending',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Request submitted successfully!'),
            backgroundColor: Color(0xFF2E7D32),
          ),
        );
        Navigator.pop(context, itemId);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit request: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<bool> _loadRegisteredLocationIfNeeded() async {
    if (_registeredAddress != null) return true;
    final client = Supabase.instance.client;
    final userId = client.auth.currentUser?.id;
    if (userId == null) return false;

    try {
      final profile = await client
          .from('profiles')
          .select('address, city, country')
          .eq('id', userId)
          .maybeSingle();

      final address = profile?['address']?.toString().trim();
      final city = profile?['city']?.toString().trim();
      final country = profile?['country']?.toString().trim();

      final locPieces = [
        if (city != null && city.isNotEmpty) city,
        if (country != null && country.isNotEmpty) country,
      ];

      if (address != null && address.isNotEmpty) {
        _registeredAddress = address;
        _registeredLocation = locPieces.isEmpty
            ? null
            : locPieces.where((e) => e.isNotEmpty).join(', ');
        return true;
      } else {
        // Address is missing, show dialog to capture it
        if (mounted) {
          final captured = await _showAddressCaptureDialog();
          if (captured) {
            // Reload to confirm
            return await _loadRegisteredLocationIfNeeded();
          }
        }
      }
    } catch (_) {
      // ignore fetch errors
    }
    return false;
  }

  Future<bool> _showAddressCaptureDialog() async {
    final addressCtrl = TextEditingController();
    final cityCtrl = TextEditingController();
    final countryCtrl = TextEditingController();
    bool isSaving = false;

    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => StatefulBuilder(
            builder: (context, setState) => AlertDialog(
              title: const Text('Add Address'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'To use "Collect from my registered location", please add your address details.',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: addressCtrl,
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
                            controller: cityCtrl,
                            decoration: const InputDecoration(
                              labelText: 'City',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: countryCtrl,
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
                  onPressed:
                      isSaving ? null : () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isSaving
                      ? null
                      : () async {
                          if (addressCtrl.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Address is required')),
                            );
                            return;
                          }

                          setState(() => isSaving = true);
                          try {
                            final client = Supabase.instance.client;
                            final userId = client.auth.currentUser!.id;

                            await client.from('profiles').update({
                              'address': addressCtrl.text.trim(),
                              'city': cityCtrl.text.trim(),
                              'country': countryCtrl.text.trim(),
                            }).eq('id', userId);

                            // ignore: use_build_context_synchronously
                            if (mounted) {
                              // ignore: use_build_context_synchronously
                              Navigator.pop(context, true);
                              // ignore: use_build_context_synchronously
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Address saved successfully!'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          } catch (e) {
                            // ignore: use_build_context_synchronously
                            if (mounted) {
                              // ignore: use_build_context_synchronously
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error: $e')),
                              );
                            }
                          } finally {
                            if (mounted) setState(() => isSaving = false);
                          }
                        },
                  child: isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save & Use'),
                ),
              ],
            ),
          ),
        ) ??
        false;
  }
}
