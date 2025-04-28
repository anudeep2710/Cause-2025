import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/audio_room_provider.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get active audio rooms count
    final audioRooms = ref.watch(audioRoomsProvider);
    final hasActiveRooms = audioRooms.isNotEmpty;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _createHeader(context),
          _createDrawerItem(
            icon: Icons.dashboard,
            text: 'Dashboard',
            onTap: () {
              Navigator.pop(context);
              GoRouter.of(context).go('/');
            },
          ),
          ListTile(
            leading: const Icon(Icons.inventory_2_outlined),
            title: const Text('Products'),
            onTap: () {
              Navigator.pop(context);
              GoRouter.of(context).go('/products');
            },
          ),
          ListTile(
            leading: const Icon(Icons.analytics_outlined),
            title: const Text('Analytics'),
            onTap: () {
              Navigator.pop(context);
              GoRouter.of(context).go('/analytics');
            },
          ),
          ListTile(
            leading: const Icon(Icons.receipt_long_outlined),
            title: const Text('Expenses'),
            onTap: () {
              Navigator.pop(context);
              GoRouter.of(context).go('/expenses');
            },
          ),
          ListTile(
            leading: const Icon(Icons.image_outlined),
            title: const Text('Poster Editor'),
            onTap: () {
              Navigator.pop(context);
              GoRouter.of(context).go('/poster');
            },
          ),
          ListTile(
            leading: const Icon(Icons.headset),
            title: const Text('Audio Rooms'),
            trailing: hasActiveRooms
                ? Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      audioRooms.length.toString(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : null,
            onTap: () {
              Navigator.pop(context);
              GoRouter.of(context).go('/audio-rooms');
            },
          ),
          const Spacer(),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              GoRouter.of(context).go('/settings');
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _createHeader(BuildContext context) {
    return DrawerHeader(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.store_rounded,
              size: 48,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
            const SizedBox(height: 8),
            Text(
              'BizzyBuddy',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _createDrawerItem({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(text),
      onTap: onTap,
    );
  }
}
