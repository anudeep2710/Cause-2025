// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:stream_video_flutter/stream_video_flutter.dart';
// import '../providers/call_provider.dart';
// import '../services/video_call_service.dart';

// class AudioCallScreen extends ConsumerStatefulWidget {
//   final String? callId;

//   const AudioCallScreen({super.key, this.callId});

//   @override
//   ConsumerState<AudioCallScreen> createState() => _AudioCallScreenState();
// }

// class _AudioCallScreenState extends ConsumerState<AudioCallScreen> {
//   bool _isMuted = false;
//   bool _isSpeakerOn = true;

//   @override
//   void initState() {
//     super.initState();
//     _initializeCall();
//   }

//   Future<void> _initializeCall() async {
//     if (widget.callId != null) {
//       await ref.read(callStateProvider.notifier).joinCall(widget.callId!);
//     } else {
//       await ref.read(callStateProvider.notifier).createCall();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final callState = ref.watch(callStateProvider);

//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: SafeArea(
//         child: callState.when(
//           data: (call) {
//             if (call == null) {
//               return const Center(
//                 child: CircularProgressIndicator(),
//               );
//             }

//             return Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 // Call status
//                 Text(
//                   call.state.value.status == CallStatus.connected
//                       ? 'Call in progress'
//                       : 'Connecting...',
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 20),

//                 // Call controls
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     // Mute button
//                     IconButton(
//                       icon: Icon(
//                         _isMuted ? Icons.mic_off : Icons.mic,
//                         color: Colors.white,
//                         size: 32,
//                       ),
//                       onPressed: () {
//                         setState(() {
//                           _isMuted = !_isMuted;
//                         });
//                         call.setMicrophoneEnabled(enabled: !_isMuted);
//                       },
//                     ),
//                     const SizedBox(width: 40),

//                     // End call button
//                     IconButton(
//                       icon: const Icon(
//                         Icons.call_end,
//                         color: Colors.red,
//                         size: 32,
//                       ),
//                       onPressed: () async {
//                         await ref.read(callStateProvider.notifier).endCall();
//                         if (mounted) {
//                           Navigator.pop(context);
//                         }
//                       },
//                     ),
//                     const SizedBox(width: 40),

//                     // Speaker button
//                     IconButton(
//                       icon: Icon(
//                         _isSpeakerOn ? Icons.volume_up : Icons.volume_off,
//                         color: Colors.white,
//                         size: 32,
//                       ),
//                       onPressed: () {
//                         setState(() {
//                           _isSpeakerOn = !_isSpeakerOn;
//                         });
//                         // Note: Speaker control is handled by the system
//                         // We just update the UI state
//                       },
//                     ),
//                   ],
//                 ),
//               ],
//             );
//           },
//           loading: () => const Center(
//             child: CircularProgressIndicator(),
//           ),
//           error: (error, stack) => Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 const Text(
//                   'Error joining call',
//                   style: TextStyle(color: Colors.white, fontSize: 24),
//                 ),
//                 const SizedBox(height: 16),
//                 Text(
//                   error.toString(),
//                   style: const TextStyle(color: Colors.white),
//                 ),
//                 const SizedBox(height: 16),
//                 ElevatedButton(
//                   onPressed: () {
//                     Navigator.pop(context);
//                   },
//                   child: const Text('Go Back'),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     super.dispose();
//   }
// }
