import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:income_track/providers/auth_provider.dart';

class Profile extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch user data provider
    final userData = ref.watch(userDataProvider);

    // Check if data is empty and reload it if necessary
    if (userData.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Simulating loading user data (can use API or local storage)
        ref.read(userDataProvider.notifier).loadUserData(
            '{"firstName": "John", "lastName": "Doe", "phone": "1234567890"}');
      });
    }

    return Scaffold(
      backgroundColor: Colors.deepPurple.shade100,
      appBar: AppBar(
        backgroundColor: Colors.deepPurple.shade200,
        title: const Text('ໂປຣໄຟຂອງທ່ານ'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            context.go('/home');
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Handle edit profile
            },
          ),
        ],
      ),
      body: userData.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // Profile Avatar
                  const CircleAvatar(
                    radius: 50,
                    child: Icon(
                      Icons.account_circle,
                      size: 90,
                    ), // Replace with your avatar image
                  ),
                  const SizedBox(height: 16),
                  // Name and Role
                  Text(
                    '${userData['firstName']} ${userData['lastName']}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Form Fields
                  ProfileField(
                    label: 'ເບີໂທ',
                    value: userData['phone'] ?? 'N/A',
                    icon: Icons.phone,
                  ),
                ],
              ),
            ),
    );
  }
}


// Reusable Widget for Profile Fields
class ProfileField extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const ProfileField({
    Key? key,
    required this.label,
    required this.value,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Icon(icon, color: Colors.grey),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
