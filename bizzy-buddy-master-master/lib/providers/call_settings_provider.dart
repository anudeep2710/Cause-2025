class CallSettings {
  final bool isMuted;
  final bool isVideoEnabled;
  final bool isSpeakerEnabled;

  const CallSettings({
    this.isMuted = false,
    this.isVideoEnabled = true,
    this.isSpeakerEnabled = true,
  });

  CallSettings copyWith({
    bool? isMuted,
    bool? isVideoEnabled,
    bool? isSpeakerEnabled,
  }) {
    return CallSettings(
      isMuted: isMuted ?? this.isMuted,
      isVideoEnabled: isVideoEnabled ?? this.isVideoEnabled,
      isSpeakerEnabled: isSpeakerEnabled ?? this.isSpeakerEnabled,
    );
  }
}
