import 'package:flutter/material.dart';
import 'package:plan_ease/model/profile.dart';

class ProfileCard extends StatelessWidget {
  final Profile profile;

  const ProfileCard({super.key, required this.profile});

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
              backgroundImage: profile.photoProfileUrl != null && profile.photoProfileUrl!.isNotEmpty
                  ? NetworkImage(profile.photoProfileUrl!) as ImageProvider<Object>
                  : const NetworkImage('https://via.placeholder.com/150'),
              backgroundColor: Colors.grey[200],
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: () {
                  // Tambahkan logika untuk edit foto profil
                },
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
                    Icons.edit,
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
                value: profile.user?.fullName ?? 'Tidak Diketahui',
              ),
              const SizedBox(height: 12),
              _buildInfoRow(
                icon: Icons.email_outlined,
                value: profile.user?.email ?? 'Tidak Diketahui',
              ),
              const SizedBox(height: 12),
              _buildInfoRow(
                icon: Icons.phone_outlined,
                value: profile.user?.phone ?? 'Tidak Diketahui',
              ),
              const SizedBox(height: 12),
              _buildInfoRow(
                icon: Icons.business_outlined,
                value: profile.division ?? 'Tidak Diketahui',
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              // Tambahkan logika untuk navigasi ke halaman edit profil di sini
              // Contoh: Navigator.push(context, MaterialPageRoute(builder: (context) => EditProfileScreen(profile: profile)));
            },
            icon: const Icon(Icons.edit, color: Colors.white, size: 18),
            label: const Text(
              'Edit Profil',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E8C7A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
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

class MenuTile extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback? onTap;

  const MenuTile({
    super.key,
    required this.icon,
    required this.text,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F6EC),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.black),
        title: Text(text),
        onTap: onTap,
      ),
    );
  }
}
