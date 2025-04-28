import '../../../../models/api_user.dart';

class RoomSettings {
  final bool audio;
  final bool video;

  RoomSettings({required this.audio, required this.video});
}

class ApiRoom {
  final String id;
  final String roomName;
  final ApiUser host;
  final List<ApiUser> participants;
  final String streamCallId;
  final String channelId;
  final RoomSettings settings;
  final String status;
  final DateTime createdAt;

  ApiRoom({
    required this.id,
    required this.roomName,
    required this.host,
    required this.participants,
    required this.streamCallId,
    required this.channelId,
    required this.settings,
    required this.status,
    required this.createdAt,
  });
}
