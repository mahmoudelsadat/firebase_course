import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/firebase_auth_service.dart';
import '../../models/user_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserModel? _user;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  void _loadUser() async {
    final auth = Provider.of<FirebaseAuthService>(context, listen: false);
    final userData = await auth.getUserData(FirebaseAuth.instance.currentUser!.uid);
    setState(() => _user = userData);
  }

  @override
  Widget build(BuildContext context) {
    const Color tgAccent = Color(0xFF2481cc);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(icon: const Icon(Icons.edit_outlined), onPressed: () {}),
        ],
      ),
      body: _user == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: tgAccent.withOpacity(0.2),
                          child: Text(
                            _user!.name[0].toUpperCase(),
                            style: const TextStyle(fontSize: 50, color: tgAccent, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: CircleAvatar(
                            radius: 18,
                            backgroundColor: tgAccent,
                            child: Icon(Icons.camera_alt, size: 18, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _user!.name,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    _user!.role.toString().split('.').last.toUpperCase(),
                    style: const TextStyle(color: Color(0xFF7f91a4), letterSpacing: 1.2),
                  ),
                  const SizedBox(height: 32),
                  _buildProfileItem(Icons.phone_outlined, 'Phone', '+1 234 567 890'),
                  _buildProfileItem(Icons.alternate_email, 'Username', '@${_user!.name.toLowerCase().replaceAll(' ', '_')}'),
                  _buildProfileItem(Icons.info_outline, 'Bio', 'Pharmacy app user since 2024'),
                  const Divider(height: 40),
                  _buildProfileItem(Icons.email_outlined, 'Email', _user!.email),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ElevatedButton(
                      onPressed: () => Provider.of<FirebaseAuthService>(context, listen: false).signOut(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent.withOpacity(0.1),
                        foregroundColor: Colors.redAccent,
                      ),
                      child: const Text('Logout Account'),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileItem(IconData icon, String title, String value) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF7f91a4)),
      title: Text(value, style: const TextStyle(fontSize: 16)),
      subtitle: Text(title, style: const TextStyle(color: Color(0xFF7f91a4), fontSize: 13)),
    );
  }
}
