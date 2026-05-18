import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color tgAccent = Color(0xFF2481cc);
    const Color tgTextGrey = Color(0xFF7f91a4);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          _buildSectionHeader('Notifications'),
          SwitchListTile(
            title: const Text('Message Notifications'),
            subtitle: const Text('Alerts for new chat messages'),
            value: true,
            activeColor: tgAccent,
            onChanged: (val) {},
          ),
          SwitchListTile(
            title: const Text('News Updates'),
            subtitle: const Text('Get notified about pharmacy news'),
            value: false,
            activeColor: tgAccent,
            onChanged: (val) {},
          ),
          const Divider(),
          _buildSectionHeader('Appearance'),
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: const Text('Theme'),
            subtitle: const Text('Dark Mode (Telegram Aesthetic)'),
            trailing: const Icon(Icons.chevron_right, color: tgTextGrey),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.text_fields),
            title: const Text('Text Size'),
            subtitle: const Text('Medium'),
            trailing: const Icon(Icons.chevron_right, color: tgTextGrey),
            onTap: () {},
          ),
          const Divider(),
          _buildSectionHeader('Account & Security'),
          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: const Text('Privacy and Security'),
            trailing: const Icon(Icons.chevron_right, color: tgTextGrey),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.storage_outlined),
            title: const Text('Data and Storage'),
            trailing: const Icon(Icons.chevron_right, color: tgTextGrey),
            onTap: () {},
          ),
          const Divider(),
          _buildSectionHeader('Support'),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Pharmacy App FAQ'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('App Version'),
            subtitle: const Text('1.0.0 (Stable)'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: Color(0xFF2481cc),
          fontSize: 13,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
