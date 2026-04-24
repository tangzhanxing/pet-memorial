import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // App Info
          _buildSection(
            title: 'About',
            children: [
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('App Version'),
                subtitle: const Text('1.0.0'),
              ),
              ListTile(
                leading: const Icon(Icons.description_outlined),
                title: const Text('Privacy Policy'),
                trailing: const Icon(Icons.open_in_new, size: 18),
                onTap: () => _showPrivacyPolicy(context),
              ),
              ListTile(
                leading: const Icon(Icons.article_outlined),
                title: const Text('Terms of Service'),
                trailing: const Icon(Icons.open_in_new, size: 18),
                onTap: () {},
              ),
            ],
          ),

          // 3D Generation Settings
          _buildSection(
            title: '3D Model Generation',
            children: [
              ListTile(
                leading: const Icon(Icons.api),
                title: const Text('API Provider'),
                subtitle: const Text('Meshy AI (Default)'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showApiSettings(context),
              ),
              ListTile(
                leading: const Icon(Icons.precision_manufacturing),
                title: const Text('Model Quality'),
                subtitle: const Text('High'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
            ],
          ),

          // Sound Settings
          _buildSection(
            title: 'Sound',
            children: [
              ListTile(
                leading: const Icon(Icons.record_voice_over),
                title: const Text('Voice Clone Provider'),
                subtitle: const Text('ElevenLabs'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.volume_up),
                title: const Text('Sound Effects Volume'),
                subtitle: const Text('80%'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
            ],
          ),

          // Display Settings
          _buildSection(
            title: 'Display',
            children: [
              ListTile(
                leading: const Icon(Icons.animation),
                title: const Text('Auto Rotate Model'),
                trailing: Switch(
                  value: true,
                  onChanged: (value) {},
                ),
              ),
              ListTile(
                leading: const Icon(Icons.brightness_6),
                title: const Text('Theme'),
                subtitle: const Text('Light'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
            ],
          ),

          // Storage
          _buildSection(
            title: 'Storage',
            children: [
              ListTile(
                leading: const Icon(Icons.storage),
                title: const Text('Clear Cache'),
                subtitle: const Text('Free up space'),
                onTap: () => _showClearCacheDialog(context),
              ),
              ListTile(
                leading: const Icon(Icons.backup),
                title: const Text('Backup Data'),
                subtitle: const Text('Export your pets'),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.restore),
                title: const Text('Restore Data'),
                subtitle: const Text('Import backup'),
                onTap: () {},
              ),
            ],
          ),

          // Support
          _buildSection(
            title: 'Support',
            children: [
              ListTile(
                leading: const Icon(Icons.help_outline),
                title: const Text('Help & FAQ'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.feedback_outlined),
                title: const Text('Send Feedback'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.mail_outline),
                title: const Text('Contact Us'),
                subtitle: const Text('support@petmemorial.app'),
                onTap: () {},
              ),
            ],
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
        ),
        ...children,
        const Divider(),
      ],
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: const SingleChildScrollView(
          child: Text(
            'Pet Memorial respects your privacy.\n\n'
            '• Photos and data are stored locally on your device\n'
            '• 3D model generation uses cloud services (Meshy AI)\n'
            '• Voice cloning uses ElevenLabs API\n'
            '• We do not sell or share your personal data\n'
            '• All cloud APIs use encryption\n\n'
            'For more information, please visit our website.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showApiSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('API Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const TextField(
              decoration: InputDecoration(
                labelText: 'Meshy API Key',
                hintText: 'Enter your API key',
              ),
            ),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                labelText: 'ElevenLabs API Key',
                hintText: 'Enter your API key',
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Get your API keys:\n'
              '• Meshy: meshy.ai\n'
              '• ElevenLabs: elevenlabs.io',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showClearCacheDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache?'),
        content: const Text(
          'This will remove temporary files and cached data. '
          'Your pet profiles and 3D models will not be deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cache cleared')),
              );
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}