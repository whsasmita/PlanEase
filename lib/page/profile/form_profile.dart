import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:plan_ease/model/profile.dart';
import 'package:plan_ease/service/profile_service.dart';
import 'package:plan_ease/service/auth_service.dart';

class FormProfilePage extends StatefulWidget {
  final Profile profile;
  final ProfileService? profileService;
  final XFile? selectedImage; // New parameter to receive pre-selected image

  const FormProfilePage({
    super.key,
    required this.profile,
    this.profileService,
    this.selectedImage, // Initialize the new parameter
  });

  @override
  State<FormProfilePage> createState() => _FormProfilePageState();
}

class _FormProfilePageState extends State<FormProfilePage> {
  XFile? _selectedImage;
  bool _isLoading = false;
  late ProfileService _profileService;

  @override
  void initState() {
    super.initState();
    _profileService = widget.profileService ?? ProfileService(AuthService());
    _selectedImage = widget.selectedImage; // Assign the pre-selected image
  }

  Future<void> _uploadProfileImage() async {
    if (_selectedImage == null) {
      _showErrorDialog('Silakan pilih gambar terlebih dahulu');
      return;
    }

    if (widget.profile.id == null) {
      _showErrorDialog('ID profil tidak valid');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // IMPORTANT: Change the API call here to use the main profile update endpoint
      // The backend's `update` method handles photo uploads to /profile/{id}
      await _profileService.updateProfilePhoto(
        profileId: widget.profile.id!,
        imageFile: File(_selectedImage!.path),
      );

      if (mounted) {
        Navigator.of(context).pop(true); // Return true to indicate success
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Foto profil berhasil diperbarui'),
            backgroundColor: Color(0xFF1E8C7A),
          ),
        );
      }
    } catch (e) {
      _showErrorDialog('Gagal mengupload foto: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildImagePreview() {
    if (_selectedImage != null) {
      return Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFF1E8C7A), width: 3),
        ),
        child: ClipOval(
          child: Image.file(
            File(_selectedImage!.path),
            fit: BoxFit.cover,
          ),
        ),
      );
    } else if (widget.profile.photoProfileUrl != null &&
        widget.profile.photoProfileUrl!.isNotEmpty) {
      return Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFF1E8C7A), width: 3),
        ),
        child: ClipOval(
          child: Image.network(
            widget.profile.photoProfileUrl!,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey[200],
                child: Icon(
                  Icons.broken_image,
                  size: 50,
                  color: Colors.grey[400],
                ),
              );
            },
          ),
        ),
      );
    } else {
      return Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey[200],
          border: Border.all(color: const Color(0xFF1E8C7A), width: 3),
        ),
        child: Icon(
          Icons.person,
          size: 80,
          color: Colors.grey[400],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ganti Foto Profil'),
        backgroundColor: const Color(0xFF1E8C7A),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1E8C7A),
              Color(0xFFF0F6EC),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const SizedBox(height: 40),
                _buildImagePreview(),
                const SizedBox(height: 40),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        widget.profile.user?.fullName ?? 'Tidak Diketahui',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D5016),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.profile.user?.email ?? 'Tidak Diketahui',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF666666),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : () => Navigator.of(context).pop(), // Just close this page
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    label: const Text(
                      'Kembali',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _uploadProfileImage,
                    icon: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(Icons.save, color: Colors.white),
                    label: Text(
                      _isLoading ? 'Mengupload...' : 'Simpan Foto',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedImage != null
                          ? const Color(0xFF2D5016)
                          : Colors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}