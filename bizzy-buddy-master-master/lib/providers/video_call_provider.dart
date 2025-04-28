// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:stream_video_flutter/stream_video_flutter.dart';
// import 'dart:math';
// import 'dart:async';
// import '../services/api_service.dart';
// import '../models/api_models.dart';
// import '../models/api_user.dart';
// import '../services/video_call_service.dart';

// final videoCallProvider = Provider<VideoCallProvider>((ref) {
//   return VideoCallProvider(ref);
// });

// class VideoCallProvider {
//   final Ref _ref;
//   late StreamVideo _streamVideo;
//   bool _isInitialized = false;
//   late final ApiService _apiService;
//   late final VideoCallService _service;

//   // Stream API credentials
//   final String _apiKey = 'mmhfdzb5evj2';
//   final String _defaultUserId = 'Jango_Fett';
//   final String _defaultToken =
//       'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJodHRwczovL3Byb250by5nZXRzdHJlYW0uaW8iLCJzdWIiOiJ1c2VyL0phbmdvX0ZldHQiLCJ1c2VyX2lkIjoiSmFuZ29fRmV0dCIsInZhbGlkaXR5X2luX3NlY29uZHMiOjYwNDgwMCwiaWF0IjoxNzQ0NjU1ODgxLCJleHAiOjE3NDUyNjA2ODF9.XrGvYEmBPFlLoeIsFJuiuNsb_FxXHz9Mtqn3TbYQ-ac';

//   VideoCallProvider(this._ref) {
//     _apiService = _ref.read(apiServiceProvider);
//     _service = _ref.read(videoCallServiceProvider);
//   }

//   // Execute future with timeout
//   Future<T> _executeWithTimeout<T>({
//     required Future<T> Function() action,
//     int timeoutSeconds = 60,
//   }) async {
//     try {
//       final completer = Completer<T>();

//       // Create timeout that completes with an exception
//       final timeoutTimer = Timer(Duration(seconds: timeoutSeconds), () {
//         if (!completer.isCompleted) {
//           completer.completeError(TimeoutException(
//               'Operation timed out after $timeoutSeconds seconds'));
//         }
//       });

//       // Start operation
//       action().then((result) {
//         if (!completer.isCompleted) {
//           completer.complete(result);
//         }
//       }).catchError((error) {
//         if (!completer.isCompleted) {
//           completer.completeError(error);
//         }
//       });

//       // Wait for either response or timeout
//       final result = await completer.future;
//       timeoutTimer.cancel();

//       return result;
//     } catch (e) {
//       debugPrint('Operation failed with error: $e');
//       rethrow;
//     }
//   }

//   Future<void> initialize() async {
//     if (_isInitialized) return;

//     try {
//       // Try to reset any existing instance to avoid conflicts
//       try {
//         StreamVideo.reset();
//       } catch (e) {
//         debugPrint('No previous instance to reset: $e');
//       }

//       // Get user data from server
//       ApiUser userData;

//       try {
//         userData = await _executeWithTimeout(
//           action: () => _apiService.getCurrentUser(),
//           timeoutSeconds: 60, // Long timeout for slow API
//         );

//         if (userData.streamToken == null) {
//           throw Exception('Stream token not available');
//         }

//         // Create Stream Video instance
//         _streamVideo = StreamVideo(
//           _apiKey,
//           user: User.regular(
//               userId: userData.id, role: userData.role, name: userData.name),
//           userToken: userData.streamToken!,
//         );
//       } catch (e) {
//         debugPrint('Error getting current user: $e');
//         throw Exception('Failed to initialize Stream client: $e');
//       }

//       _isInitialized = true;
//       debugPrint('Video call provider initialized successfully');
//     } catch (e) {
//       debugPrint('Error initializing video call provider: $e');
//       throw Exception('Failed to initialize video call provider: $e');
//     }
//   }

//   StreamVideo get streamVideo {
//     if (!_isInitialized) {
//       throw Exception(
//           'Video call provider not initialized. Call initialize() first.');
//     }
//     return _streamVideo;
//   }

//   Future<Call> createCall() async {
//     if (!_isInitialized) {
//       await initialize();
//     }
//     return _service.createCall();
//   }

//   Future<Call> joinCallById(String callId) async {
//     if (!_isInitialized) {
//       await initialize();
//     }
//     return _service.joinCall(callId);
//   }

//   // Future<void> endCall() async {
//   //   if (!_isInitialized) {
//   //     await initialize();
//   //   }
//   //   await _service.endCall();
//   // }

//   // Generate a random call ID if none is provided (fallback method)
//   String _generateCallId() {
//     const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
//     final random = Random();
//     return String.fromCharCodes(
//       Iterable.generate(
//         10,
//         (_) => chars.codeUnitAt(random.nextInt(chars.length)),
//       ),
//     );
//   }
// }
