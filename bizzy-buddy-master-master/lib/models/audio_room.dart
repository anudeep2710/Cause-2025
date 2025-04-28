import 'api_user.dart';

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
    this.participants = const [],
    this.streamCallId = '',
    this.channelId = '',
    this.settings = const RoomSettings(),
    this.status = 'active',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  ApiRoom copyWith({
    String? id,
    String? roomName,
    ApiUser? host,
    List<ApiUser>? participants,
    String? streamCallId,
    String? channelId,
    RoomSettings? settings,
    String? status,
    DateTime? createdAt,
  }) {
    return ApiRoom(
      id: id ?? this.id,
      roomName: roomName ?? this.roomName,
      host: host ?? this.host,
      participants: participants ?? this.participants,
      streamCallId: streamCallId ?? this.streamCallId,
      channelId: channelId ?? this.channelId,
      settings: settings ?? this.settings,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory ApiRoom.fromJson(Map<String, dynamic> json) {
    return ApiRoom(
      id: json['_id'] as String,
      roomName: json['roomName'] as String,
      host: ApiUser.fromJson(json['host'] as Map<String, dynamic>),
      participants: (json['participants'] as List)
          .map((p) => ApiUser.fromJson(p as Map<String, dynamic>))
          .toList(),
      streamCallId: json['streamCallId'] as String,
      channelId: json['channelId'] as String,
      settings: RoomSettings.fromJson(json['settings'] as Map<String, dynamic>),
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'roomName': roomName,
      'host': host.toJson(),
      'participants': participants.map((p) => p.toJson()).toList(),
      'streamCallId': streamCallId,
      'channelId': channelId,
      'settings': settings.toJson(),
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class RoomSettings {
  final bool audio;
  final bool video;

  const RoomSettings({this.audio = true, this.video = false});

  RoomSettings copyWith({bool? audio, bool? video}) {
    return RoomSettings(
      audio: audio ?? this.audio,
      video: video ?? this.video,
    );
  }

  factory RoomSettings.fromJson(Map<String, dynamic> json) {
    return RoomSettings(
      audio: json['audio'] as bool,
      video: json['video'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'audio': audio,
      'video': video,
    };
  }
}
