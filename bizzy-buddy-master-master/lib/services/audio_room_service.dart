import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zego_uikit_prebuilt_live_audio_room/zego_uikit_prebuilt_live_audio_room.dart';
import 'package:zego_express_engine/zego_express_engine.dart';
import '../models/audio_room.dart';
import '../models/api_user.dart';

// Constants for ZegoCloud integration - replace with your actual credentials
const int ZEGO_APP_ID = 1194585494; // Replace with your actual App ID
const String ZEGO_APP_SIGN =
    'f200a2c50a48180fdb5e629c979477de4fde753c6d19750d197f2acd03fd5e74'; // Replace with your actual App Sign

final audioRoomServiceProvider = Provider<AudioRoomService>((ref) {
  return AudioRoomService();
});

class AudioRoomService {
  bool _isInitialized = false;

  /// Initialize the ZEGO SDK with app ID and app sign
  Future<void> initializeZEGO() async {
    if (_isInitialized) return;

    try {
      debugPrint('Initializing ZEGO SDK');

      // Create ZEGO engine with profile
      final profile = ZegoEngineProfile(
        ZEGO_APP_ID,
        ZegoScenario.Default,
        appSign: ZEGO_APP_SIGN,
      );
      await ZegoExpressEngine.createEngineWithProfile(profile);

      // Set up event listeners directly
      ZegoExpressEngine.onRoomStateChanged = (String roomID,
          ZegoRoomStateChangedReason reason,
          int errorCode,
          Map<String, dynamic> extendedData) {
        debugPrint(
            'Room state changed: $roomID, reason: $reason, error: $errorCode');
      };

      ZegoExpressEngine.onRoomUserUpdate =
          (String roomID, ZegoUpdateType updateType, List<ZegoUser> userList) {
        if (updateType == ZegoUpdateType.Add) {
          debugPrint(
              'Users joined: \\${userList.map((e) => e.userID).toList()}');
        } else {
          debugPrint('Users left: \\${userList.map((e) => e.userID).toList()}');
        }
      };

      _isInitialized = true;
      debugPrint('ZEGO SDK initialized successfully');
    } catch (e) {
      debugPrint('Failed to initialize ZEGO SDK: $e');
      rethrow;
    }
  }

  /// Get configuration for a host user
  ZegoUIKitPrebuiltLiveAudioRoomConfig getHostConfig() {
    final config = ZegoUIKitPrebuiltLiveAudioRoomConfig.host();

    // Customize host settings
    config.turnOnMicrophoneWhenJoining = true;
    config.useSpeakerWhenJoining = true;

    // Enable seat capabilities
    config.seat.showSoundWaveInAudioMode = true;

    return config;
  }

  /// Get configuration for an audience member
  ZegoUIKitPrebuiltLiveAudioRoomConfig getAudienceConfig() {
    final config = ZegoUIKitPrebuiltLiveAudioRoomConfig.audience();

    // Customize audience settings
    config.turnOnMicrophoneWhenJoining = false;
    config.useSpeakerWhenJoining = true;

    // Enable seat capabilities for audience
    config.seat.showSoundWaveInAudioMode = true;

    // Configure audience-specific options
    // The apply button is enabled by default for audience

    return config;
  }

  /// Cleanup resources when not needed
  Future<void> dispose() async {
    if (!_isInitialized) return;

    try {
      await ZegoExpressEngine.destroyEngine();
      _isInitialized = false;
      debugPrint('ZEGO SDK destroyed successfully');
    } catch (e) {
      debugPrint('Failed to destroy ZEGO SDK: $e');
      rethrow;
    }
  }
}
