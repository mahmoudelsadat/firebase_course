import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/firebase_auth_service.dart';
import '../products/product_list_screen.dart';
import '../news/news_list_screen.dart';
import '../chat/chat_list_screen.dart';
import '../profile/profile_screen.dart';
import '../settings/settings_screen.dart';

class PharmacistHomeScreen extends StatefulWidget {
  const PharmacistHomeScreen({super.key});

  @override
  _PharmacistHomeScreenState createState() => _PharmacistHomeScreenState();
}

class _PharmacistHomeScreenState extends State<PharmacistHomeScreen> {
  int _selectedIndex = 0;
  
  final List<Widget> _pages = [
    const ProductListScreen(),
    const NewsListScreen(),
    const ChatListScreen(),
  ];

  final List<String> _titles = ['Inventory Management', 'Pharmacy Updates', 'Consultations'];

  @override
  Widget build(BuildContext context) {
    bool isLight = Theme.of(context).brightness == Brightness.light;
    Color bgColor = Theme.of(context).scaffoldBackgroundColor;
    Color surfaceColor = Theme.of(context).colorScheme.surface;
    Color accentColor = isLight ? Theme.of(context).primaryColor : const Color(0xFF4ADE80);
    Color textColor = isLight ? Colors.black87 : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          _titles[_selectedIndex],
          style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0.5, color: textColor),
        ),
        backgroundColor: bgColor,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
        actions: [
          IconButton(
            icon: Icon(Icons.account_circle_outlined, color: textColor),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen())),
          ),
        ],
      ),
      drawer: _buildPremiumDrawer(isLight, bgColor, surfaceColor, accentColor, textColor),
      body: _pages[_selectedIndex],
      bottomNavigationBar: _buildCustomBottomNav(isLight, bgColor, surfaceColor, accentColor),
    );
  }

  Widget _buildPremiumDrawer(bool isLight, Color bgColor, Color surfaceColor, Color accentColor, Color textColor) {
    return Drawer(
      backgroundColor: bgColor,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(top: 60, bottom: 30, left: 24, right: 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isLight 
                    ? [accentColor.withOpacity(0.1), Colors.white] 
                    : [accentColor.withOpacity(0.2), bgColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border(bottom: BorderSide(color: isLight ? Colors.black12 : const Color(0xFF1E293B))),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: accentColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: accentColor.withOpacity(0.4), blurRadius: 15, spreadRadius: 2),
                    ],
                  ),
                  child: Icon(Icons.medical_services_rounded, size: 36, color: isLight ? Colors.white : const Color(0xFF064E3B)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pharmacist Dashboard',
                        style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'pharmacist@pharmacy.com',
                        style: TextStyle(color: textColor.withOpacity(0.7), fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _drawerItem(Icons.person_outline, 'My Profile', textColor, () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
          }),
          _drawerItem(Icons.settings_outlined, 'App Settings', textColor, () {
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
          }),
          const Spacer(),
          Divider(color: isLight ? Colors.black12 : const Color(0xFF1E293B)),
          _drawerItem(
            Icons.logout, 
            'Logout', 
            const Color(0xFFEF4444), 
            () => Provider.of<FirebaseAuthService>(context, listen: false).signOut(),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _drawerItem(IconData icon, String title, Color color, VoidCallback onTap) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 4),
      leading: Icon(icon, color: color, size: 26),
      title: Text(title, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.w600)),
      onTap: onTap,
    );
  }

  Widget _buildCustomBottomNav(bool isLight, Color bgColor, Color surfaceColor, Color accentColor) {
    return Container(
      decoration: BoxDecoration(
        color: isLight ? Colors.white : bgColor,
        border: Border(top: BorderSide(color: isLight ? Colors.black12 : const Color(0xFF1E293B), width: 1)),
      ),
      padding: const EdgeInsets.only(bottom: 24, top: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(0, Icons.inventory_2_outlined, Icons.inventory_2, 'Inventory', accentColor, isLight),
          _navItem(1, Icons.campaign_outlined, Icons.campaign, 'News', accentColor, isLight),
          _navItem(2, Icons.forum_outlined, Icons.forum, 'Consults', accentColor, isLight),
        ],
      ),
    );
  }

  Widget _navItem(int index, IconData iconOutlined, IconData iconFilled, String label, Color accentColor, bool isLight) {
    bool isSelected = _selectedIndex == index;
    Color unselectedColor = isLight ? Colors.black54 : const Color(0xFF64748B);
    
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: isSelected ? 32 : 0,
            height: 3,
            decoration: BoxDecoration(
              color: isSelected ? accentColor : Colors.transparent,
              borderRadius: BorderRadius.circular(2),
              boxShadow: isSelected ? [BoxShadow(color: accentColor.withOpacity(0.5), blurRadius: 8, spreadRadius: 1)] : [],
            ),
          ),
          const SizedBox(height: 8),
          Icon(
            isSelected ? iconFilled : iconOutlined,
            color: isSelected ? accentColor : unselectedColor,
            size: 26,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? accentColor : unselectedColor,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}