// import 'package:flutter/material.dart';
// import 'package:stream_video_flutter/stream_video_flutter.dart';

// class CallScreen extends StatefulWidget {
//   final Call call;

//   const CallScreen({
//     super.key,
//     required this.call,
//   });

//   @override
//   State<CallScreen> createState() => _CallScreenState();
// }

// class _CallScreenState extends State<CallScreen> {
//   bool _videoEnabled = true;
//   bool _audioEnabled = true;
//   bool _inCall = false;

//   @override
//   Widget build(BuildContext context) {
//     if (_inCall) {
//       return Scaffold(
//         body: StreamCallContainer(
//           call: widget.call,
//         ),
//       );
//     }

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Call Settings'),
//         backgroundColor: Theme.of(context).primaryColor,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Call details card
//             Card(
//               elevation: 4,
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Call ID: ${widget.call.id}',
//                       style: const TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     const Text(
//                       'Type: Default Call',
//                       style: TextStyle(fontSize: 16),
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       'Created: ${DateTime.now().toString().split('.')[0]}',
//                       style: const TextStyle(fontSize: 16),
//                     ),
//                   ],
//                 ),
//               ),
//             ),

//             const SizedBox(height: 24),

//             // Call settings
//             const Text(
//               'Call Settings',
//               style: TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),

//             const SizedBox(height: 16),

//             // Video toggle
//             SwitchListTile(
//               title: const Text('Enable Video'),
//               subtitle: const Text('Turn your camera on or off before joining'),
//               value: _videoEnabled,
//               onChanged: (value) {
//                 setState(() {
//                   _videoEnabled = value;
//                 });
//               },
//             ),

//             // Audio toggle
//             SwitchListTile(
//               title: const Text('Enable Audio'),
//               subtitle:
//                   const Text('Mute or unmute your microphone before joining'),
//               value: _audioEnabled,
//               onChanged: (value) {
//                 setState(() {
//                   _audioEnabled = value;
//                 });
//               },
//             ),

//             const SizedBox(height: 32),

//             // Join call button
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   padding: const EdgeInsets.symmetric(vertical: 16),
//                   backgroundColor: Theme.of(context).primaryColor,
//                 ),
//                 onPressed: () async {
//                   setState(() {
//                     _inCall = true;
//                   });
//                 },
//                 child: const Text(
//                   'Join Call',
//                   style: TextStyle(fontSize: 18),
//                 ),
//               ),
//             ),

//             const SizedBox(height: 16),

//             // Cancel button
//             SizedBox(
//               width: double.infinity,
//               child: OutlinedButton(
//                 style: OutlinedButton.styleFrom(
//                   padding: const EdgeInsets.symmetric(vertical: 16),
//                 ),
//                 onPressed: () {
//                   Navigator.of(context).pop();
//                 },
//                 child: const Text('Cancel', style: TextStyle(fontSize: 18)),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
