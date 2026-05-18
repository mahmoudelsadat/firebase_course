import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/firebase_auth_service.dart';
import '../products/product_list_screen.dart';
import '../news/news_list_screen.dart';
import '../chat/chat_list_screen.dart';
import '../profile/profile_screen.dart';
import '../settings/settings_screen.dart';
import '../../models/user_model.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  _CustomerHomeScreenState createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  int _selectedIndex = 0;
  UserModel? _userData;

  final List<Widget> _pages = [
    ProductListScreen(),
    NewsListScreen(),
    ChatListScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final authService = Provider.of<FirebaseAuthService>(context, listen: false);
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final data = await authService.getUserData(user.uid);
      if (mounted) {
        setState(() {
          _userData = data;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color tgAccent = Color(0xFF2481cc);

    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedIndex == 0 
            ? 'Pharmacy Shop' 
            : _selectedIndex == 1 
                ? 'Health News' 
                : 'Consultations'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: Color(0xFF17212b)),
              accountName: Text(_userData?.name ?? 'Loading...'),
              accountEmail: Text(_userData?.email ?? ''),
              currentAccountPicture: CircleAvatar(
                backgroundColor: tgAccent,
                child: Text(
                  _userData?.name[0].toUpperCase() ?? '?',
                  style: const TextStyle(fontSize: 24, color: Colors.white),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('My Profile'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.help_outline),
              title: const Text('Pharmacy Support'),
              onTap: () {},
            ),
            const Spacer(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text('Logout', style: TextStyle(color: Colors.redAccent)),
              onTap: () => Provider.of<FirebaseAuthService>(context, listen: false).signOut(),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.medical_services_outlined),
            activeIcon: Icon(Icons.medical_services),
            label: 'Products',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.newspaper_outlined),
            activeIcon: Icon(Icons.newspaper),
            label: 'News',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            activeIcon: Icon(Icons.chat_bubble),
            label: 'Consults',
          ),
        ],
      ),
    );
  }
}
