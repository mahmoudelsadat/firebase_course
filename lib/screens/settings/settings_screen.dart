import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          _buildSectionHeader(context, 'Notifications'),
          SwitchListTile(
            title: const Text('Message Notifications'),
            subtitle: const Text('Alerts for new chat messages'),
            value: true,
            activeThumbColor: Theme.of(context).primaryColor,
            onChanged: (val) {},
          ),
          SwitchListTile(
            title: const Text('News Updates'),
            subtitle: const Text('Get notified about pharmacy news'),
            value: false,
            activeThumbColor: Theme.of(context).primaryColor,
            onChanged: (val) {},
          ),
          const Divider(),
          _buildSectionHeader(context, 'Appearance'),
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: const Text('Theme'),
            subtitle: Text(themeProvider.isDarkMode ? 'Dark Mode (Deep Dark)' : 'Light Mode'),
            trailing: Switch(
              value: themeProvider.isDarkMode,
              activeThumbColor: Theme.of(context).primaryColor,
              onChanged: (val) {
                themeProvider.toggleTheme();
              },
            ),
            onTap: () {
              themeProvider.toggleTheme();
            },
          ),
          ListTile(
            leading: const Icon(Icons.text_fields),
            title: const Text('Text Size'),
            subtitle: const Text('Medium'),
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
            onTap: () {},
          ),
          const Divider(),
          _buildSectionHeader(context, 'Account & Security'),
          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: const Text('Privacy and Security'),
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.storage_outlined),
            title: const Text('Data and Storage'),
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
            onTap: () {},
          ),
          const Divider(),
          _buildSectionHeader(context, 'Support'),
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

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: Theme.of(context).primaryColor,
          fontSize: 13,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}