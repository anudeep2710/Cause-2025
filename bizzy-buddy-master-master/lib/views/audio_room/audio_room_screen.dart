import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zego_uikit_prebuilt_live_audio_room/zego_uikit_prebuilt_live_audio_room.dart';
import '../../models/audio_room.dart';
import '../../models/api_user.dart';
import '../../providers/audio_room_provider.dart';
import '../../services/audio_room_service.dart' as audio_service;
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

class AudioRoomScreen extends ConsumerStatefulWidget {
  final ApiRoom room;
  final bool isHost;

  const AudioRoomScreen({
    Key? key,
    required this.room,
    this.isHost = false,
  }) : super(key: key);

  @override
  ConsumerState<AudioRoomScreen> createState() => _AudioRoomScreenState();
}

class _AudioRoomScreenState extends ConsumerState<AudioRoomScreen> {
  late final ZegoUIKitPrebuiltLiveAudioRoomConfig _config;
  late final ApiUser _currentUser;
  bool _isLoading = true;
  String? _errorMessage;
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    _initializeRoom();
  }

  @override
  void dispose() {
    _leaveRoom();
    super.dispose();
  }

  Future<void> _leaveRoom() async {
    if (_isConnected) {
      // Update the room in provider to remove current user
      try {
        final roomsNotifier = ref.read(audioRoomsProvider.notifier);
        if (widget.isHost) {
          // If host leaves, remove the room
          roomsNotifier.removeRoom(widget.room.id);
        } else {
          // If audience leaves, just remove the participant
          roomsNotifier.removeParticipant(widget.room.id, _currentUser.id);
        }
      } catch (e) {
        debugPrint('Error leaving room: $e');
      }
    }
  }

  Future<void> _initializeRoom() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Use the host as the current user for simplicity in this demo
      // In a real app, you would use the actual logged-in user
      _currentUser = widget.isHost
          ? widget.room.host
          : ApiUser(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              name: 'Audience User',
              email: 'audience@example.com',
            );

      // Initialize ZEGO SDK
      final audioRoomService = ref.read(audio_service.audioRoomServiceProvider);
      await audioRoomService.initializeZEGO();

      // Prepare config with advanced settings
      _config = widget.isHost
          ? audioRoomService.getHostConfig()
          : audioRoomService.getAudienceConfig();

      // Configure some basic settings
      _config.turnOnMicrophoneWhenJoining = widget.isHost;
      _config.useSpeakerWhenJoining = true;

      // If not the host, add current user to the room in provider
      if (!widget.isHost) {
        ref.read(audioRoomsProvider.notifier).addParticipant(
              widget.room.id,
              _currentUser,
            );
      }

      _isConnected = true;
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.room.roomName),
              Row(
                children: [
                  Text(
                    'Room ID: ${widget.room.id}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(width: 4),
                  InkWell(
                    onTap: () {
                      // Copy room ID to clipboard
                      final data = ClipboardData(text: widget.room.id);
                      Clipboard.setData(data);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Room ID copied to clipboard'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    child: Icon(
                      Icons.copy,
                      size: 14,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/audio-rooms'),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.room.roomName),
              Row(
                children: [
                  Text(
                    'Room ID: ${widget.room.id}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(width: 4),
                  InkWell(
                    onTap: () {
                      // Copy room ID to clipboard
                      final data = ClipboardData(text: widget.room.id);
                      Clipboard.setData(data);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Room ID copied to clipboard'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    child: Icon(
                      Icons.copy,
                      size: 14,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/audio-rooms'),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: $_errorMessage'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _initializeRoom,
                child: const Text('Retry'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => context.go('/audio-rooms'),
                child: const Text('Back to Audio Rooms'),
              ),
            ],
          ),
        ),
      );
    }

    return WillPopScope(
      onWillPop: () async {
        context.go('/audio-rooms');
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.room.roomName),
              Row(
                children: [
                  Text(
                    'Room ID: ${widget.room.id}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(width: 4),
                  InkWell(
                    onTap: () {
                      // Copy room ID to clipboard
                      final data = ClipboardData(text: widget.room.id);
                      Clipboard.setData(data);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Room ID copied to clipboard'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    child: Icon(
                      Icons.copy,
                      size: 14,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              _leaveRoom();
              context.go('/audio-rooms');
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.people),
              onPressed: () {
                final participants = ref
                    .read(audioRoomsProvider)
                    .firstWhere((r) => r.id == widget.room.id)
                    .participants;

                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Participants'),
                    content: SizedBox(
                      width: double.maxFinite,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: participants.length,
                        itemBuilder: (context, index) {
                          final user = participants[index];
                          return ListTile(
                            leading: CircleAvatar(
                              child: Text(user.name[0]),
                            ),
                            title: Text(user.name),
                            subtitle: Text(user.id == widget.room.host.id
                                ? 'Host'
                                : 'Participant'),
                          );
                        },
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () => context.go('/settings'),
              tooltip: 'Settings',
            ),
          ],
        ),
        body: SafeArea(
          child: Consumer(
            builder: (context, ref, child) {
              // Check if room still exists in local state
              final rooms = ref.watch(audioRoomsProvider);
              final roomExists = rooms.any((r) => r.id == widget.room.id);

              // Check if this is a room we're joining directly by ID from another device
              final isDirectJoin = widget.room.host.id == 'temp_host';

              // Only show "room closed" message if:
              // 1. Room doesn't exist in local state
              // 2. We're not the host
              // 3. This is NOT a direct join by ID
              if (!roomExists && !widget.isHost && !isDirectJoin) {
                // Room was closed by host
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'This room has been closed by the host',
                        style: TextStyle(fontSize: 18),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => context.go('/audio-rooms'),
                        child: const Text('Back to Audio Rooms'),
                      ),
                    ],
                  ),
                );
              }

              return ZegoUIKitPrebuiltLiveAudioRoom(
                appID: audio_service.ZEGO_APP_ID,
                appSign: audio_service.ZEGO_APP_SIGN,
                roomID: widget.room.id,
                config: _config,
                userID: _currentUser.id,
                userName: _currentUser.name,
              );
            },
          ),
        ),
      ),
    );
  }
}
