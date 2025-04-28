import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/audio_room.dart';
import '../../models/api_user.dart';
import '../../providers/audio_room_provider.dart';

class CreateAudioRoomScreen extends ConsumerStatefulWidget {
  const CreateAudioRoomScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CreateAudioRoomScreen> createState() =>
      _CreateAudioRoomScreenState();
}

class _CreateAudioRoomScreenState extends ConsumerState<CreateAudioRoomScreen> {
  final _formKey = GlobalKey<FormState>();
  final _roomNameController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _roomNameController.dispose();
    super.dispose();
  }

  Future<void> _createRoom() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Create a mock room with unique ID
      final mockUser = ApiUser(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: 'Current User',
        email: 'user@example.com',
        role: 'user',
        createdAt: DateTime.now(),
      );

      final room = ApiRoom(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        roomName: _roomNameController.text,
        host: mockUser,
        participants: [mockUser],
        streamCallId: 'stream_${DateTime.now().millisecondsSinceEpoch}',
        channelId: 'channel_${DateTime.now().millisecondsSinceEpoch}',
        settings: const RoomSettings(audio: true, video: false),
        status: 'active',
        createdAt: DateTime.now(),
      );

      // Add the room to the provider
      ref.read(audioRoomsProvider.notifier).addRoom(room);

      if (mounted) {
        context.go('/audio-rooms/${room.id}?isHost=true', extra: room);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create room: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Audio Room'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _roomNameController,
                decoration: const InputDecoration(
                  labelText: 'Room Name',
                  hintText: 'Enter a name for your audio room',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a room name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _createRoom,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Create Room'),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => context.go('/audio-rooms'),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
