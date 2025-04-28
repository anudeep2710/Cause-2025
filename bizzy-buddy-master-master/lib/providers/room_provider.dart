// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../services/api_service.dart';
// import '../models/api_models.dart';

// final roomsProvider =
//     StateNotifierProvider<RoomsNotifier, AsyncValue<List<ApiRoom>>>((ref) {
//   return RoomsNotifier(ref.watch(apiServiceProvider));
// });

// class RoomsNotifier extends StateNotifier<AsyncValue<List<ApiRoom>>> {
//   final ApiService _apiService;

//   RoomsNotifier(this._apiService) : super(const AsyncValue.loading()) {
//     loadRooms();
//   }

//   Future<void> loadRooms() async {
//     try {
//       state = const AsyncValue.loading();
//       final rooms = await _apiService.getAudioRooms();
//       state = AsyncValue.data(rooms);
//     } catch (e) {
//       state = AsyncValue.error(e, StackTrace.current);
//     }
//   }

//   Future<ApiRoom> createRoom({
//     required String roomName,
//     Map<String, dynamic>? settings,
//   }) async {
//     try {
//       final room = await _apiService.createAudioRoom(
//         roomName: roomName,
//         settings: settings,
//       );

//       // Update state with new room
//       state.whenData((rooms) {
//         state = AsyncValue.data([...rooms, room]);
//       });

//       return room;
//     } catch (e) {
//       state = AsyncValue.error(e, StackTrace.current);
//       rethrow;
//     }
//   }

//   Future<ApiRoom> joinRoom(String roomId) async {
//     try {
//       final room = await _apiService.joinRoom(roomId);

//       // Update state with joined room
//       state.whenData((rooms) {
//         final updatedRooms = rooms.map((r) {
//           if (r.id == roomId) {
//             return room;
//           }
//           return r;
//         }).toList();
//         state = AsyncValue.data(updatedRooms);
//       });

//       return room;
//     } catch (e) {
//       state = AsyncValue.error(e, StackTrace.current);
//       rethrow;
//     }
//   }

//   Future<ApiRoom> leaveRoom(String roomId) async {
//     try {
//       final room = await _apiService.leaveRoom(roomId);

//       // Update state with left room
//       state.whenData((rooms) {
//         final updatedRooms = rooms.map((r) {
//           if (r.id == roomId) {
//             return room;
//           }
//           return r;
//         }).toList();
//         state = AsyncValue.data(updatedRooms);
//       });

//       return room;
//     } catch (e) {
//       state = AsyncValue.error(e, StackTrace.current);
//       rethrow;
//     }
//   }

//   Future<ApiRoom> getRoomDetails(String roomId) async {
//     try {
//       final room = await _apiService.getRoomDetails(roomId);

//       // Update state with room details
//       state.whenData((rooms) {
//         final updatedRooms = rooms.map((r) {
//           if (r.id == roomId) {
//             return room;
//           }
//           return r;
//         }).toList();
//         state = AsyncValue.data(updatedRooms);
//       });

//       return room;
//     } catch (e) {
//       state = AsyncValue.error(e, StackTrace.current);
//       rethrow;
//     }
//   }
// }
