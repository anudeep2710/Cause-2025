// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:zego_uikit_prebuilt_live_audio_room/zego_uikit_prebuilt_live_audio_room.dart';
// import '../templates/lib/models/audio_room.dart';
// import '../../models/api_user.dart';

// // Zego Cloud credentials
// const int ZEGO_APP_ID = 1194585494;
// const String ZEGO_APP_SIGN =
//     'f200a2c50a48180fdb5e629c979477de4fde753c6d19750d197f2acd03fd5e74';

// class AudioRoomScreen extends ConsumerStatefulWidget {
//   final ApiRoom room;
//   final bool isHost;

//   const AudioRoomScreen({super.key, required this.room, required this.isHost});

//   @override
//   ConsumerState<AudioRoomScreen> createState() => _AudioRoomScreenState();
// }

// class _AudioRoomScreenState extends ConsumerState<AudioRoomScreen> {
//   late final ApiUser currentUser;
//   bool _isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _setup();
//   }

//   Future<void> _setup() async {
//     setState(() => _isLoading = true);
//     try {
//       // Use the host user as the current user for simplicity
//       currentUser = widget.isHost
//           ? widget.room.host
//           : ApiUser(
//               id: DateTime.now().millisecondsSinceEpoch.toString(),
//               name: 'User ${DateTime.now().millisecondsSinceEpoch % 1000}',
//               email: 'user@example.com',
//               role: 'user',
//               createdAt: DateTime.now(),
//             );

//       setState(() => _isLoading = false);
//     } catch (e) {
//       debugPrint('Error in setup: $e');
//       if (mounted) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text('Error: $e')));
//         setState(() => _isLoading = false);
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_isLoading) {
//       return const Scaffold(body: Center(child: CircularProgressIndicator()));
//     }

//     return SafeArea(
//       child: ZegoUIKitPrebuiltLiveAudioRoom(
//         appID: ZEGO_APP_ID,
//         appSign: ZEGO_APP_SIGN,
//         userID: currentUser.id,
//         userName: currentUser.name,
//         roomID: widget.room.id,
//         config: widget.isHost
//             ? ZegoUIKitPrebuiltLiveAudioRoomConfig.host()
//             : ZegoUIKitPrebuiltLiveAudioRoomConfig.audience(),
//         events: ZegoUIKitPrebuiltLiveAudioRoomEvents(),
//       ),
//     );
//   }
// }
