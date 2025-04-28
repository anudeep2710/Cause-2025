import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_credential.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// Current user provider
final currentUserProvider = StateProvider<UserCredential?>((ref) => null);

// Authentication state
final authStateProvider = StateProvider<bool>((ref) {
  // Watch the currentUserProvider to automatically update when user changes
  final currentUser = ref.watch(currentUserProvider);
  return currentUser != null;
});

// User credentials list
class UserCredentialsNotifier extends StateNotifier<List<UserCredential>> {
  UserCredentialsNotifier() : super([]) {
    // Load stored credentials when initialized
    _loadCredentials();
  }

  // Load credentials from SharedPreferences
  Future<void> _loadCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedCredentials = prefs.getStringList('user_credentials') ?? [];

      final loadedCredentials = storedCredentials.map((jsonStr) {
        final map = json.decode(jsonStr) as Map<String, dynamic>;
        return UserCredential.fromJson(map);
      }).toList();

      state = loadedCredentials;
      debugPrint('Loaded ${loadedCredentials.length} credentials from storage');
    } catch (e) {
      debugPrint('Error loading credentials: $e');
    }
  }

  // Save credentials to SharedPreferences
  Future<void> _saveCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = state.map((cred) => json.encode(cred.toJson())).toList();
      await prefs.setStringList('user_credentials', jsonList);
      debugPrint('Saved ${state.length} credentials to storage');
    } catch (e) {
      debugPrint('Error saving credentials: $e');
    }
  }

  void addUser(UserCredential user) {
    state = [...state, user];
    _saveCredentials(); // Save after adding
  }

  UserCredential? findUserByEmail(String email) {
    try {
      return state.firstWhere((user) => user.email == email);
    } catch (e) {
      return null;
    }
  }

  bool isEmailTaken(String email) {
    return state.any((user) => user.email == email);
  }
}

final userCredentialsProvider =
    StateNotifierProvider<UserCredentialsNotifier, List<UserCredential>>(
  (ref) => UserCredentialsNotifier(),
);

// Auth service
class AuthService {
  final Ref _ref;

  AuthService(this._ref);

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    // Check if email is already taken
    if (_ref.read(userCredentialsProvider.notifier).isEmailTaken(email)) {
      throw Exception('Email already in use');
    }

    // Create new user
    final newUser = UserCredential(
      name: name,
      email: email,
      password: password,
    );

    // Add user to list
    _ref.read(userCredentialsProvider.notifier).addUser(newUser);

    // Log in the user
    _ref.read(currentUserProvider.notifier).state = newUser;

    return true;
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    // Find user by email
    final user =
        _ref.read(userCredentialsProvider.notifier).findUserByEmail(email);

    if (user == null) {
      throw Exception('User not found');
    }

    // Check password
    if (user.password != password) {
      throw Exception('Invalid password');
    }

    // Set current user
    _ref.read(currentUserProvider.notifier).state = user;

    return true;
  }

  void logout() {
    _ref.read(currentUserProvider.notifier).state = null;
  }
}

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref);
});
