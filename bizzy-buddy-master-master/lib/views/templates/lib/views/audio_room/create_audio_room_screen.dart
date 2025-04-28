import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/audio_room.dart';
import '../../../../../models/api_user.dart';
import 'audio_room_home.dart';

class CreateAudioRoomScreen extends ConsumerStatefulWidget {
  const CreateAudioRoomScreen({super.key});

  @override
  ConsumerState<CreateAudioRoomScreen> createState() =>
      _CreateAudioRoomScreenState();
}

class _CreateAudioRoomScreenState extends ConsumerState<CreateAudioRoomScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _createRoom() {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Create mock user for the host
      final currentUser = ApiUser(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: 'User ${DateTime.now().millisecondsSinceEpoch % 1000}',
        email: 'user@example.com',
        role: 'host',
        createdAt: DateTime.now(),
      );

      // Create room with the provided name
      final room = ApiRoom(
        id: 'room-${DateTime.now().millisecondsSinceEpoch}',
        roomName: _nameController.text.trim(),
        host: currentUser,
        participants: [currentUser],
        streamCallId: 'stream-${DateTime.now().millisecondsSinceEpoch}',
        channelId: 'channel-${DateTime.now().millisecondsSinceEpoch}',
        settings: RoomSettings(audio: true, video: false),
        status: 'active',
        createdAt: DateTime.now(),
      );

      // Add the room to the provider
      ref.read(audioRoomsProvider.notifier).addRoom(room);

      // Navigate to the room screen as host
      if (mounted) {
        context.go('/audio-rooms/${room.id}?isHost=true', extra: room);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error creating room: $e')));
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Audio Room')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Room Details',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Room Name',
                  hintText: 'Enter a name for your room',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.meeting_room),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a room name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _isLoading ? null : _createRoom,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Create Room'),
              ),
              const SizedBox(height: 24),
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'About Audio Rooms',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'As a host, you will be able to:',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                      SizedBox(height: 8),
                      Text('• Control who can speak'),
                      Text('• Invite others to join'),
                      Text('• End the room when finished'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
