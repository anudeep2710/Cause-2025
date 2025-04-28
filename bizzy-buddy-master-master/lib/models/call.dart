// import 'api_user.dart';

// class Call {
//   final String id;
//   final ApiUser createdBy;
//   final List<CallParticipant> participants;
//   final String status;
//   final String streamCallId;
//   final DateTime startedAt;
//   final DateTime? endedAt;

//   Call({
//     required this.id,
//     required this.createdBy,
//     required this.participants,
//     required this.status,
//     required this.streamCallId,
//     required this.startedAt,
//     this.endedAt,
//   });

//   factory Call.fromJson(Map<String, dynamic> json) {
//     return Call(
//       id: json['_id'] as String,
//       createdBy: ApiUser.fromJson(json['createdBy'] as Map<String, dynamic>),
//       participants: (json['participants'] as List)
//           .map((p) => CallParticipant.fromJson(p as Map<String, dynamic>))
//           .toList(),
//       status: json['status'] as String,
//       streamCallId: json['streamCallId'] as String,
//       startedAt: DateTime.parse(json['startedAt'] as String),
//       endedAt: json['endedAt'] != null
//           ? DateTime.parse(json['endedAt'] as String)
//           : null,
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       '_id': id,
//       'createdBy': createdBy.toJson(),
//       'participants': participants.map((p) => p.toJson()).toList(),
//       'status': status,
//       'streamCallId': streamCallId,
//       'startedAt': startedAt.toIso8601String(),
//       if (endedAt != null) 'endedAt': endedAt!.toIso8601String(),
//     };
//   }
// }

// class CallParticipant {
//   final ApiUser userId;
//   final DateTime joinedAt;

//   CallParticipant({
//     required this.userId,
//     required this.joinedAt,
//   });

//   factory CallParticipant.fromJson(Map<String, dynamic> json) {
//     return CallParticipant(
//       userId: ApiUser.fromJson(json['userId'] as Map<String, dynamic>),
//       joinedAt: DateTime.parse(json['joinedAt'] as String),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'userId': userId.toJson(),
//       'joinedAt': joinedAt.toIso8601String(),
//     };
//   }
// }
