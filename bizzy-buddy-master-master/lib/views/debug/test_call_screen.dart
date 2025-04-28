// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../../services/video_call_service.dart';
// import '../../providers/call_provider.dart';
// import '../../views/call/call_screen.dart';

// class TestCallScreen extends ConsumerStatefulWidget {
//   const TestCallScreen({super.key});

//   @override
//   ConsumerState<TestCallScreen> createState() => _TestCallScreenState();
// }

// class _TestCallScreenState extends ConsumerState<TestCallScreen> {
//   final TextEditingController _callIdController = TextEditingController();
//   bool _isInitializing = false;
//   bool _isInitialized = false;
//   bool _isCreatingCall = false;
//   bool _isJoiningCall = false;
//   String _errorMessage = '';
//   String _statusMessage = '';

//   @override
//   void initState() {
//     super.initState();
//     _initializeVideoService();
//   }

//   @override
//   void dispose() {
//     _callIdController.dispose();
//     super.dispose();
//   }

//   Future<void> _initializeVideoService() async {
//     setState(() {
//       _isInitializing = true;
//       _statusMessage = 'Initializing video service...';
//       _errorMessage = '';
//     });

//     try {
//       final videoService = ref.read(videoCallServiceProvider);
//       await videoService.initialize();
//       setState(() {
//         _isInitialized = true;
//         _statusMessage = 'Video service initialized successfully';
//       });
//     } catch (e) {
//       setState(() {
//         _errorMessage = 'Failed to initialize: $e';
//         _statusMessage = 'Initialization failed';
//       });
//     } finally {
//       setState(() {
//         _isInitializing = false;
//       });
//     }
//   }

//   Future<void> _createCall() async {
//     if (!_isInitialized) {
//       setState(() {
//         _errorMessage = 'Service not initialized yet';
//       });
//       return;
//     }

//     setState(() {
//       _isCreatingCall = true;
//       _statusMessage = 'Creating call...';
//       _errorMessage = '';
//     });

//     try {
//       final callState = ref.read(callStateProvider.notifier);
//       await callState.createCall();

//       final currentCall = ref.read(callStateProvider).value;
//       if (currentCall != null) {
//         setState(() {
//           _statusMessage = 'Call created with ID: ${currentCall.id}';
//           _callIdController.text = currentCall.id;
//         });

//         if (mounted) {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (_) => CallScreen(call: currentCall),
//             ),
//           );
//         }
//       }
//     } catch (e) {
//       setState(() {
//         _errorMessage = 'Failed to create call: $e';
//         _statusMessage = 'Call creation failed';
//       });
//     } finally {
//       setState(() {
//         _isCreatingCall = false;
//       });
//     }
//   }

//   Future<void> _joinCall() async {
//     final callId = _callIdController.text.trim();
//     if (callId.isEmpty) {
//       setState(() {
//         _errorMessage = 'Please enter a call ID';
//       });
//       return;
//     }

//     if (!_isInitialized) {
//       setState(() {
//         _errorMessage = 'Service not initialized yet';
//       });
//       return;
//     }

//     setState(() {
//       _isJoiningCall = true;
//       _statusMessage = 'Joining call...';
//       _errorMessage = '';
//     });

//     try {
//       final callState = ref.read(callStateProvider.notifier);
//       await callState.joinCall(callId);

//       final currentCall = ref.read(callStateProvider).value;
//       if (currentCall != null) {
//         setState(() {
//           _statusMessage = 'Joined call with ID: ${currentCall.id}';
//         });

//         if (mounted) {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (_) => CallScreen(call: currentCall),
//             ),
//           );
//         }
//       }
//     } catch (e) {
//       setState(() {
//         _errorMessage = 'Failed to join call: $e';
//         _statusMessage = 'Call join failed';
//       });
//     } finally {
//       setState(() {
//         _isJoiningCall = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Test Call (Debug)'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.refresh),
//             onPressed: _isInitializing ? null : _initializeVideoService,
//             tooltip: 'Reinitialize',
//           ),
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             // Status card
//             Card(
//               color: _errorMessage.isNotEmpty
//                   ? Colors.red.shade50
//                   : Colors.green.shade50,
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Status: ${_isInitialized ? 'Ready' : 'Not Initialized'}',
//                       style: const TextStyle(fontWeight: FontWeight.bold),
//                     ),
//                     const SizedBox(height: 8),
//                     Text(_statusMessage),
//                     if (_errorMessage.isNotEmpty) ...[
//                       const SizedBox(height: 8),
//                       Text(
//                         'Error: $_errorMessage',
//                         style: const TextStyle(color: Colors.red),
//                       ),
//                     ],
//                   ],
//                 ),
//               ),
//             ),

//             const SizedBox(height: 24),

//             // Call ID input
//             TextField(
//               controller: _callIdController,
//               decoration: const InputDecoration(
//                 labelText: 'Call ID',
//                 hintText: 'Enter call ID to join',
//                 border: OutlineInputBorder(),
//               ),
//             ),

//             const SizedBox(height: 24),

//             // Action buttons
//             Row(
//               children: [
//                 Expanded(
//                   child: ElevatedButton(
//                     onPressed:
//                         (_isInitialized && !_isCreatingCall && !_isJoiningCall)
//                             ? _createCall
//                             : null,
//                     child: _isCreatingCall
//                         ? const CircularProgressIndicator(strokeWidth: 2)
//                         : const Text('Create New Call'),
//                   ),
//                 ),
//                 const SizedBox(width: 16),
//                 Expanded(
//                   child: ElevatedButton(
//                     onPressed: (_isInitialized &&
//                             !_isJoiningCall &&
//                             !_isCreatingCall &&
//                             _callIdController.text.isNotEmpty)
//                         ? _joinCall
//                         : null,
//                     child: _isJoiningCall
//                         ? const CircularProgressIndicator(strokeWidth: 2)
//                         : const Text('Join Call'),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
