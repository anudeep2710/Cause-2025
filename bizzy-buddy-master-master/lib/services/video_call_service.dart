// import 'package:flutter/foundation.dart';
// import 'package:stream_video_flutter/stream_video_flutter.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../models/api_models.dart';
// import 'api_service.dart';

// final videoCallServiceProvider = Provider<VideoCallService>((ref) {
//   return VideoCallService(ref);
// });

// class VideoCallService {
//   final Ref _ref;
//   StreamVideo? _client;
//   Call? _currentCall;
//   bool _isInitialized = false;
//   bool _isVideoEnabled = true;
//   bool _isMicrophoneEnabled = true;

//   VideoCallService(this._ref);

//   // Initialize the Stream client
//   Future<void> initialize() async {
//     if (_isInitialized) return;

//     try {
//       final apiService = _ref.read(apiServiceProvider);
//       final tokenResponse = await apiService.getStreamToken();

//       _client = StreamVideo(
//         const String.fromEnvironment('STREAM_API_KEY',
//             defaultValue: 'YOUR_API_KEY'),
//         user: User.regular(
//           userId: tokenResponse['userId'],
//           role: 'user',
//           name: tokenResponse['userName'],
//         ),
//         userToken: tokenResponse['token'],
//       );

//       _isInitialized = true;
//     } catch (e) {
//       debugPrint('Failed to initialize Stream client: $e');
//       rethrow;
//     }
//   }

//   // Create a new call
//   // Future<Call> createCall() async {
//   //   if (!_isInitialized) await initialize();

//   //   try {
//   //     final apiService = _ref.read(apiServiceProvider);
//   //     final apiCall = await apiService.createCall();

//   //     _currentCall = _client!.makeCall(
//   //       callType: StreamCallType(),
//   //       id: apiCall.streamCallId,
//   //     );

//   //     await _currentCall!.getOrCreate();

//   //     // Set initial call settings
//   //     await _currentCall!.setMicrophoneEnabled(enabled: _isMicrophoneEnabled);
//   //     await _currentCall!.setCameraEnabled(enabled: _isVideoEnabled);

//   //     return _currentCall!;
//   //   } catch (e) {
//   //     debugPrint('Failed to create call: $e');
//   //     rethrow;
//   //   }
//   // }

//   // Join an existing call
//   Future<Call> joinCall(String callId) async {
//     if (!_isInitialized) await initialize();

//     try {
//       final apiService = _ref.read(apiServiceProvider);
//       final apiCall = await apiService.joinCall(callId);

//       _currentCall = _client!.makeCall(
//         callType: StreamCallType(),
//         id: apiCall.streamCallId,
//       );

//       await _currentCall!.getOrCreate();

//       // Set initial call settings
//       await _currentCall!.setMicrophoneEnabled(enabled: _isMicrophoneEnabled);
//       await _currentCall!.setCameraEnabled(enabled: _isVideoEnabled);

//       return _currentCall!;
//     } catch (e) {
//       debugPrint('Failed to join call: $e');
//       rethrow;
//     }
//   }

//   // Toggle video
//   Future<void> toggleVideo() async {
//     if (_currentCall == null) return;

//     try {
//       _isVideoEnabled = !_isVideoEnabled;
//       await _currentCall!.setCameraEnabled(enabled: _isVideoEnabled);
//     } catch (e) {
//       debugPrint('Failed to toggle video: $e');
//       rethrow;
//     }
//   }

//   // Toggle microphone
//   Future<void> toggleMicrophone() async {
//     if (_currentCall == null) return;

//     try {
//       _isMicrophoneEnabled = !_isMicrophoneEnabled;
//       await _currentCall!.setMicrophoneEnabled(enabled: _isMicrophoneEnabled);
//     } catch (e) {
//       debugPrint('Failed to toggle microphone: $e');
//       rethrow;
//     }
//   }

//   // End the current call
//   // Future<void> endCall() async {
//   //   if (_currentCall == null) return;

//   //   try {
//   //     final apiService = _ref.read(apiServiceProvider);
//   //     await apiService.endCall(_currentCall!.id);
//   //     await _currentCall!.end();
//   //     _currentCall = null;

//   //     // Reset call settings
//   //     _isVideoEnabled = true;
//   //     _isMicrophoneEnabled = true;
//   //   } catch (e) {
//   //     debugPrint('Failed to end call: $e');
//   //     rethrow;
//   //   }
//   // }

//   // Get the current call
//   Call? get currentCall => _currentCall;

//   // Get call settings
//   bool get isVideoEnabled => _isVideoEnabled;
//   bool get isMicrophoneEnabled => _isMicrophoneEnabled;

//   // Dispose resources
//   void dispose() {
//     _currentCall?.end();
//     _currentCall = null;
//     _client?.dispose();
//     _client = null;
//     _isInitialized = false;
//   }
// }
