import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/providers/theme_provider.dart' as theme_provider;

/// A provider for the AI mode setting
final aiModeProvider = StateProvider<bool>((ref) {
  // Use Hive to persist the setting
  final settingsBox = Hive.box('settings');
  return settingsBox.get('ai_mode_enabled', defaultValue: false);
});

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(theme_provider.themeModeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          // Theme Settings
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Appearance',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.brightness_6),
            title: const Text('Theme Mode'),
            subtitle: const Text('Change app theme'),
            trailing: DropdownButton<ThemeMode>(
              value: themeMode,
              onChanged: (ThemeMode? newThemeMode) {
                if (newThemeMode != null) {
                  ref.read(theme_provider.themeModeProvider.notifier).state =
                      newThemeMode;
                }
              },
              items: const [
                DropdownMenuItem(
                  value: ThemeMode.system,
                  child: Text('System'),
                ),
                DropdownMenuItem(value: ThemeMode.light, child: Text('Light')),
                DropdownMenuItem(value: ThemeMode.dark, child: Text('Dark')),
              ],
            ),
          ),

          const Divider(),

          // Data Management
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Data Management',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline, color: Colors.red),
            title: const Text('Clear Data'),
            subtitle: const Text('Delete all app data'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showClearDataDialog(context),
          ),

          const Divider(),

          // About
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'About',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About'),
            subtitle: const Text('About BizzyBuddy'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'BizzyBuddy',
                applicationVersion: '1.0.0',
                applicationIcon: Image.asset(
                  'assets/icon/icon.png',
                  width: 48,
                  height: 48,
                  errorBuilder: (ctx, obj, st) => const Icon(Icons.business),
                ),
                children: const [
                  Text(
                    'BizzyBuddy is a comprehensive business management app for small businesses and entrepreneurs.',
                  ),
                  SizedBox(height: 16),
                  Text('© 2024 BizzyBuddy Team'),
                ],
              );
            },
          ),

          const Divider(),

          // Server information
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Server Information',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.cloud),
            title: const Text('API Server'),
            subtitle: const Text('https://bizzy-buddy-backend.onrender.com'),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                'Online',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Note: API calls can take up to 50 seconds due to server constraints.',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Help & Support'),
            subtitle: const Text('Get assistance with the app'),
            onTap: () {
              // TODO: Add help screen
            },
          ),
          ListTile(
            leading: const Icon(Icons.headset),
            title: const Text('Audio Rooms'),
            subtitle: const Text('Join or create voice chat rooms'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.go('/audio-rooms'),
          ),
        ],
      ),
    );
  }

  Future<void> _showClearDataDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap button to close dialog
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Clear All Data'),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text('Are you sure you want to clear all app data?'),
                SizedBox(height: 8),
                Text(
                  'This action will delete all your products, sales, expenses, and settings. This cannot be undone.',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text(
                'Clear All Data',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () async {
                await _clearAllData(context);
                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('All data has been cleared'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  // Navigate to home/dashboard after clearing data
                  if (context.mounted) {
                    context.go('/dashboard');
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _clearAllData(BuildContext context) async {
    try {
      // Clear all Hive boxes
      await Hive.box<dynamic>('products').clear();
      await Hive.box<dynamic>('sales').clear();
      await Hive.box<dynamic>('expenses').clear();
      await Hive.box<dynamic>('settings').clear();

      // You might want to keep some default settings
      final settingsBox = Hive.box('settings');
      await settingsBox.put('ai_mode_enabled', false);

      // Reset any other state if needed
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error clearing data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
