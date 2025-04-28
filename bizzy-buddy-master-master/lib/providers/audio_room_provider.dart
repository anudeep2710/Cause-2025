import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/audio_room.dart';
import '../models/api_user.dart';

// Simple in-memory room provider with real-time updates
class AudioRoomsNotifier extends StateNotifier<List<ApiRoom>> {
  AudioRoomsNotifier() : super([]) {
    // Seed with initial rooms for demo
    _seedInitialRooms();
  }

  void _seedInitialRooms() {
    // Start with an empty list of rooms instead of seeded mock rooms
    state = [];

    // Log initial state
    debugPrint('Initial rooms: ${state.length}');
  }

  // Get a room by ID
  ApiRoom? getRoomById(String roomId) {
    try {
      return state.firstWhere((room) => room.id == roomId);
    } catch (e) {
      return null;
    }
  }

  // Add a new room
  void addRoom(ApiRoom room) {
    debugPrint('Adding room: ${room.roomName} (${room.id})');
    state = [...state, room];
    _notifyRoomChange('Room added: ${room.roomName}');
  }

  // Remove a room
  void removeRoom(String roomId) {
    debugPrint('Removing room: $roomId');
    final roomToRemove = getRoomById(roomId);
    if (roomToRemove != null) {
      state = state.where((room) => room.id != roomId).toList();
      _notifyRoomChange('Room removed: ${roomToRemove.roomName}');
    }
  }

  // Update a room
  void updateRoom(ApiRoom updatedRoom) {
    debugPrint('Updating room: ${updatedRoom.roomName} (${updatedRoom.id})');
    state = state
        .map((room) => room.id == updatedRoom.id ? updatedRoom : room)
        .toList();
    _notifyRoomChange('Room updated: ${updatedRoom.roomName}');
  }

  // Add a participant to a room
  void addParticipant(String roomId, ApiUser participant) {
    debugPrint(
        'Adding participant to room $roomId: ${participant.name} (${participant.id})');

    final updatedRooms = state.map((room) {
      if (room.id == roomId) {
        // Check if participant already exists
        final exists = room.participants.any((p) => p.id == participant.id);
        if (!exists) {
          final updated = [...room.participants, participant];
          return room.copyWith(participants: updated);
        }
      }
      return room;
    }).toList();

    state = updatedRooms;
    _notifyParticipantChange(roomId, 'joined', participant.name);
  }

  // Remove a participant from a room
  void removeParticipant(String roomId, String participantId) {
    debugPrint('Removing participant from room $roomId: $participantId');

    String? participantName;

    final updatedRooms = state.map((room) {
      if (room.id == roomId) {
        // Find participant name before removing
        final participant = room.participants.firstWhere(
          (p) => p.id == participantId,
          orElse: () => ApiUser(id: '', name: 'Unknown', email: ''),
        );

        participantName = participant.name;

        final updated =
            room.participants.where((p) => p.id != participantId).toList();
        return room.copyWith(participants: updated);
      }
      return room;
    }).toList();

    state = updatedRooms;

    if (participantName != null) {
      _notifyParticipantChange(roomId, 'left', participantName!);
    }
  }

  // Helper to log room changes
  void _notifyRoomChange(String message) {
    debugPrint('ROOM UPDATE: $message | Total rooms: ${state.length}');
  }

  // Helper to log participant changes
  void _notifyParticipantChange(String roomId, String action, String name) {
    final room = getRoomById(roomId);
    if (room != null) {
      debugPrint(
          'PARTICIPANT UPDATE: $name $action ${room.roomName} | Total participants: ${room.participants.length}');
    }
  }
}

// State provider for audio rooms
final audioRoomsProvider =
    StateNotifierProvider<AudioRoomsNotifier, List<ApiRoom>>((ref) {
  return AudioRoomsNotifier();
});
