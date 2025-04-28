// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:stream_video_flutter/stream_video_flutter.dart';
// import '../models/api_models.dart';
// import '../services/video_call_service.dart';

// // Provider for the current call state
// final callStateProvider =
//     StateNotifierProvider<CallStateNotifier, AsyncValue<Call?>>((ref) {
//   return CallStateNotifier(ref);
// });

// // Provider for call settings
// final callSettingsProvider =
//     StateNotifierProvider<CallSettingsNotifier, CallSettings>((ref) {
//   return CallSettingsNotifier(ref);
// });

// class CallSettings {
//   final bool isVideoEnabled;
//   final bool isMicrophoneEnabled;

//   const CallSettings({
//     this.isVideoEnabled = true,
//     this.isMicrophoneEnabled = true,
//   });

//   CallSettings copyWith({
//     bool? isVideoEnabled,
//     bool? isMicrophoneEnabled,
//   }) {
//     return CallSettings(
//       isVideoEnabled: isVideoEnabled ?? this.isVideoEnabled,
//       isMicrophoneEnabled: isMicrophoneEnabled ?? this.isMicrophoneEnabled,
//     );
//   }
// }

// class CallSettingsNotifier extends StateNotifier<CallSettings> {
//   final Ref _ref;

//   CallSettingsNotifier(this._ref) : super(const CallSettings());

//   void toggleVideo() {
//     state = state.copyWith(isVideoEnabled: !state.isVideoEnabled);
//     _ref.read(videoCallServiceProvider).toggleVideo();
//   }

//   void toggleMicrophone() {
//     state = state.copyWith(isMicrophoneEnabled: !state.isMicrophoneEnabled);
//     _ref.read(videoCallServiceProvider).toggleMicrophone();
//   }
// }

// class CallStateNotifier extends StateNotifier<AsyncValue<Call?>> {
//   final Ref _ref;
//   final VideoCallService _videoCallService;

//   CallStateNotifier(this._ref)
//       : _videoCallService = _ref.read(videoCallServiceProvider),
//         super(const AsyncValue.data(null));

//   // Create a new call
//   // Future<void> createCall() async {
//   //   state = const AsyncValue.loading();
//   //   try {
//   //     final call = await _videoCallService.createCall();
//   //     state = AsyncValue.data(call);
//   //   } catch (error, stackTrace) {
//   //     state = AsyncValue.error(error, stackTrace);
//   //   }
//   // }

//   // Join an existing call
//   Future<void> joinCall(String callId) async {
//     state = const AsyncValue.loading();
//     try {
//       final call = await _videoCallService.joinCall(callId);
//       state = AsyncValue.data(call);
//     } catch (error, stackTrace) {
//       state = AsyncValue.error(error, stackTrace);
//     }
//   }

//   // End the current call
//   Future<void> endCall() async {
//     try {
//       await _videoCallService.endCall();
//       state = const AsyncValue.data(null);
//     } catch (error, stackTrace) {
//       state = AsyncValue.error(error, stackTrace);
//     }
//   }

//   // Get the current call
//   Call? get currentCall => state.value;

//   // Dispose resources
//   @override
//   void dispose() {
//     _videoCallService.dispose();
//     super.dispose();
//   }
// }
