import 'package:flutter/material.dart';
import 'package:plan_ease/model/profile.dart';
import 'package:plan_ease/page/profile/form_profile.dart'; // For photo update
import 'package:plan_ease/service/profile_service.dart';
import 'package:plan_ease/service/auth_service.dart';
import 'package:image_picker/image_picker.dart'; // Import for ImagePicker

// A new page for editing user details
import 'package:plan_ease/page/profile/edit_details_page.dart'; // NEW IMPORT

class ProfileCard extends StatefulWidget {
  final Profile profile;

  const ProfileCard({super.key, required this.profile});

  @override
  State<ProfileCard> createState() => _ProfileCardState();
}

class _ProfileCardState extends State<ProfileCard> {
  late Profile _currentProfile;
  late ProfileService _profileService;
  final ImagePicker _picker = ImagePicker(); // Initialize ImagePicker

  @override
  void initState() {
    super.initState();
    _currentProfile = widget.profile;
    _profileService = ProfileService(AuthService());
  }

  // Function to refresh profile data after an update
  Future<void> _refreshProfileData() async {
    if (_currentProfile.id == null) return;

    try {
      final updatedProfile = await _profileService.getProfileUser(_currentProfile.id!);
      setState(() {
        _currentProfile = updatedProfile;
      });
    } catch (e) {
      print('Error refreshing profile: $e');
      // Show snackbar error if necessary
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat ulang profil: $e')),
        );
      }
    }
  }

  // --- Photo Related Functions ---
  void _showImagePickerDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pilih Sumber Gambar'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galeri'),
                onTap: () {
                  Navigator.of(context).pop(); // Close dialog
                  _pickImageAndNavigateToForm(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Kamera'),
                onTap: () {
                  Navigator.of(context).pop(); // Close dialog
                  _pickImageAndNavigateToForm(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImageAndNavigateToForm(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 85,
      );

      if (image != null) {
        // Navigate to FormProfilePage with the selected image
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FormProfilePage(
              profile: _currentProfile,
              profileService: _profileService,
              selectedImage: image, // Pass the selected image
            ),
          ),
        );

        if (result == true && mounted) {
          await _refreshProfileData();
        }
      }
    } catch (e) {
      print('Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memilih gambar: $e')),
        );
      }
    }
  }
  // --- End Photo Related Functions ---

  // --- Navigation for Editing Details ---
  Future<void> _navigateToEditDetailsPage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditDetailsPage(
          profile: _currentProfile,
          profileService: _profileService,
        ),
      ),
    );

    if (result == true && mounted) {
      await _refreshProfileData();
    }
  }
  // --- End Navigation for Editing Details ---

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F6EC),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Profil Saya',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Color(0xFF2D5016),
            ),
          ),
          const SizedBox(height: 20),
          Stack(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: _currentProfile.photoProfileUrl != null &&
                        _currentProfile.photoProfileUrl!.isNotEmpty
                    ? NetworkImage(_currentProfile.photoProfileUrl!) as ImageProvider<Object>
                    : const AssetImage('assets/images/default_profile.png'),
                backgroundColor: Colors.grey[200],
                child: _currentProfile.photoProfileUrl != null &&
                        _currentProfile.photoProfileUrl!.isNotEmpty
                    ? ClipOval(
                        child: Image.network(
                          _currentProfile.photoProfileUrl!,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                    : null,
                                strokeWidth: 2,
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            print('Error loading profile image: $error');
                            return Icon(
                              Icons.broken_image,
                              size: 50,
                              color: Colors.grey[400],
                            );
                          },
                        ),
                      )
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _showImagePickerDialog, // Call the dialog here
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E8C7A),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 2,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow(
                  icon: Icons.person_outline,
                  value: _currentProfile.user?.fullName ?? 'Tidak Diketahui',
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  icon: Icons.email_outlined,
                  value: _currentProfile.user?.email ?? 'Tidak Diketahui',
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  icon: Icons.phone_outlined,
                  value: _currentProfile.user?.phone ?? 'Tidak Diketahui',
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  icon: Icons.business_outlined,
                  value: _currentProfile.division ?? 'Tidak Diketahui',
                ),
                const SizedBox(height: 12),
                _buildInfoRow( // Add position info if available
                  icon: Icons.work_outline,
                  value: _currentProfile.position ?? 'Tidak Diketahui',
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // MODIFIED: Removed the "Ganti Foto" button and centered "Edit Profil"
          Center(
            child: ElevatedButton.icon(
              onPressed: _navigateToEditDetailsPage, // Navigate to new edit details page
              icon: const Icon(Icons.edit, color: Colors.white, size: 18),
              label: const Text(
                'Edit Profil',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E8C7A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24), // Added horizontal padding
                elevation: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({required IconData icon, required String value}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF1E8C7A).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF1E8C7A),
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFF2D5016),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}