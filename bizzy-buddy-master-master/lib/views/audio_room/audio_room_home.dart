import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/audio_room.dart';
import '../../models/api_user.dart';
import '../../providers/audio_room_provider.dart';

class AudioRoomHome extends ConsumerWidget {
  const AudioRoomHome({Key? key}) : super(key: key);

  void _showJoinByIdDialog(BuildContext context, WidgetRef ref) {
    final TextEditingController roomIdController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Join Room by ID'),
        content: TextField(
          controller: roomIdController,
          decoration: const InputDecoration(
            labelText: 'Room ID',
            hintText: 'Enter the room ID to join',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final roomId = roomIdController.text.trim();
              if (roomId.isEmpty) return;

              Navigator.pop(context);

              // Try to find the room in our local list
              final rooms = ref.read(audioRoomsProvider);
              final room = rooms.where((r) => r.id == roomId).toList();

              if (room.isNotEmpty) {
                // Room found, navigate to it
                context.go('/audio-rooms/$roomId?isHost=false',
                    extra: room.first);
              } else {
                // Create a temporary room with this ID
                final tempUser = ApiUser(
                  id: 'temp_host',
                  name: 'Unknown Host',
                  email: 'unknown@example.com',
                  role: 'user',
                  createdAt: DateTime.now(),
                );

                final tempRoom = ApiRoom(
                  id: roomId,
                  roomName: 'Room $roomId',
                  host: tempUser,
                  participants: [tempUser],
                  streamCallId: 'stream_$roomId',
                  channelId: 'channel_$roomId',
                  settings: RoomSettings(audio: true, video: false),
                  status: 'active',
                  createdAt: DateTime.now(),
                );

                // Show feedback to user
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Joining room $roomId directly...'),
                    duration: Duration(seconds: 2),
                  ),
                );

                context.go('/audio-rooms/$roomId?isHost=false',
                    extra: tempRoom);
              }
            },
            child: const Text('Join'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rooms = ref.watch(audioRoomsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Audio Rooms'),
        actions: [
          IconButton(
            icon: const Icon(Icons.input),
            tooltip: 'Join by ID',
            onPressed: () => _showJoinByIdDialog(context, ref),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: () => context.go('/settings'),
          ),
        ],
      ),
      body: rooms.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('No audio rooms available'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.go('/audio-rooms/create'),
                    child: const Text('Create Room'),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: rooms.length,
              itemBuilder: (context, index) {
                final room = rooms[index];
                return ListTile(
                  title: Text(room.roomName),
                  subtitle: Text('Hosted by ${room.host.name}'),
                  trailing: Text('${room.participants.length} listeners'),
                  onTap: () {
                    context.go('/audio-rooms/${room.id}?isHost=false',
                        extra: room);
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/audio-rooms/create'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
