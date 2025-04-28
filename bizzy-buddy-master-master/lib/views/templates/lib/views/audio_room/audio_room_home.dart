import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/audio_room.dart';
import '../../../../../models/api_user.dart';

// Provider for audio rooms (in memory for this demo)
final audioRoomsProvider =
    StateNotifierProvider<AudioRoomsNotifier, List<ApiRoom>>((ref) {
  return AudioRoomsNotifier();
});

class AudioRoomsNotifier extends StateNotifier<List<ApiRoom>> {
  AudioRoomsNotifier() : super([]);

  void addRoom(ApiRoom room) {
    state = [...state, room];
  }

  void removeRoom(String roomId) {
    state = state.where((room) => room.id != roomId).toList();
  }

  void updateRoom(ApiRoom updatedRoom) {
    state = state
        .map((room) => room.id == updatedRoom.id ? updatedRoom : room)
        .toList();
  }
}

class AudioRoomHome extends ConsumerStatefulWidget {
  const AudioRoomHome({super.key});

  @override
  ConsumerState<AudioRoomHome> createState() => _AudioRoomHomeState();
}

class _AudioRoomHomeState extends ConsumerState<AudioRoomHome> {
  @override
  Widget build(BuildContext context) {
    final rooms = ref.watch(audioRoomsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Audio Rooms'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showInfoDialog(context),
          ),
        ],
      ),
      body: rooms.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              itemCount: rooms.length,
              itemBuilder: (context, index) {
                final room = rooms[index];
                return _buildRoomCard(room);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/audio-rooms/create'),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.headset_off,
            size: 64,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No active audio rooms',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Create a new room or join one when available',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => context.go('/audio-rooms/create'),
            icon: const Icon(Icons.add),
            label: const Text('Create Room'),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomCard(ApiRoom room) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () {
          context.go('/audio-rooms/${room.id}?isHost=false', extra: room);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'LIVE',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${room.participants.length} listeners',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                room.roomName,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              Text(
                'Hosted by ${room.host.name}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FilledButton.tonal(
                    onPressed: () {
                      context.go(
                        '/audio-rooms/${room.id}?isHost=false',
                        extra: room,
                      );
                    },
                    child: const Text('Join Room'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Audio Rooms'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Audio rooms allow you to have voice conversations with other users.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              'Features:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('• Create your own room as a host'),
            Text('• Join other rooms as a listener'),
            Text('• Real-time voice communication'),
            SizedBox(height: 16),
            Text(
              'Powered by Zego Cloud',
              style: TextStyle(fontStyle: FontStyle.italic, fontSize: 14),
            ),
          ],
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
}
