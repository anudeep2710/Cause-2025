// import 'dart:convert';
// import 'package:flutter/foundation.dart';
// import 'package:http/http.dart' as http;
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../models/api_models.dart';
// import 'dart:async';
// import 'package:dio/dio.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../models/api_user.dart';
// import '../models/call.dart';
// import '../models/audio_room.dart';
// import 'package:stream_chat_flutter/stream_chat_flutter.dart' as stream;
// import 'package:web_socket_channel/web_socket_channel.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// // Provider for the API service
// final apiServiceProvider = Provider<ApiService>((ref) {
//   return ApiService(baseUrl: 'https://bddy-buddy.onrender.com');
// });

// class ApiService {
//   final Dio _dio;
//   final String _baseUrl;
//   final _secureStorage = const FlutterSecureStorage();
//   String? _authToken;
//   Map<String, dynamic>? _currentUser;
//   late stream.StreamChatClient _streamClient;
//   bool _isStreamInitialized = false;
//   WebSocketChannel? _webSocketChannel;
//   String? _streamToken;
//   DateTime? _streamTokenExpiry;

//   // Keys for secure storage
//   static const String _authTokenKey = 'auth_token';
//   static const String _streamTokenKey = 'stream_token';
//   static const String _streamTokenExpiryKey = 'stream_token_expiry';
//   static const String _currentUserKey = 'current_user';

//   ApiService({required String baseUrl})
//       : _baseUrl = baseUrl,
//         _dio = Dio(BaseOptions(
//           baseUrl: baseUrl,
//           connectTimeout: const Duration(seconds: 10),
//           receiveTimeout: const Duration(seconds: 10),
//           sendTimeout: const Duration(seconds: 10),
//           headers: {
//             'Content-Type': 'application/json',
//             'Accept': 'application/json',
//           },
//           validateStatus: (status) {
//             return status != null && status < 500;
//           },
//         )) {
//     _initializeAuth();
//     _dio.interceptors.add(InterceptorsWrapper(
//       onRequest: (options, handler) {
//         debugPrint('Making request to: ${options.path}');
//         debugPrint('Request headers: ${options.headers}');
//         if (_authToken != null) {
//           options.headers['Authorization'] = 'Bearer $_authToken';
//         }
//         return handler.next(options);
//       },
//       onError: (error, handler) {
//         debugPrint('API Error: ${error.message}');
//         debugPrint('Error response: ${error.response?.data}');
//         debugPrint('Error status code: ${error.response?.statusCode}');

//         if (error.type == DioExceptionType.connectionTimeout ||
//             error.type == DioExceptionType.receiveTimeout ||
//             error.type == DioExceptionType.sendTimeout) {
//           debugPrint('Request timed out. Retrying...');
//           return handler.resolve(Response(
//             requestOptions: error.requestOptions,
//             statusCode: 408, // Request Timeout
//             statusMessage: 'Request timed out. Please try again.',
//           ));
//         }

//         if (error.response?.statusCode == 401) {
//           _authToken = null;
//           _currentUser = null;
//           debugPrint('Authentication failed. Clearing auth token.');
//         }
//         return handler.next(error);
//       },
//     ));
//   }

//   // Initialize auth state from secure storage
//   Future<void> _initializeAuth() async {
//     try {
//       _authToken = await _secureStorage.read(key: _authTokenKey);

//       final userJson = await _secureStorage.read(key: _currentUserKey);
//       if (userJson != null) {
//         _currentUser = jsonDecode(userJson) as Map<String, dynamic>;
//       }

//       _streamToken = await _secureStorage.read(key: _streamTokenKey);
//       final expiryString =
//           await _secureStorage.read(key: _streamTokenExpiryKey);
//       if (expiryString != null) {
//         _streamTokenExpiry = DateTime.parse(expiryString);
//       }
//     } catch (e) {
//       debugPrint('Error initializing auth state: $e');
//     }
//   }

//   // Initialize Stream client
//   Future<void> initializeStream() async {
//     if (_isStreamInitialized) {
//       debugPrint('Stream client already initialized');
//       return;
//     }

//     try {
//       debugPrint('Starting Stream client initialization...');

//       // Get current user first
//       final currentUser = await getCurrentUser();
//       debugPrint('Current user data: ${currentUser.toJson()}');
//       debugPrint('Current user ID: ${currentUser.id}');
//       debugPrint('Current user name: ${currentUser.name}');

//       // Validate required user fields
//       if (currentUser.id.isEmpty) {
//         throw Exception('Invalid user ID for Stream initialization');
//       }
//       if (currentUser.name.isEmpty) {
//         throw Exception('Invalid user name for Stream initialization');
//       }

//       // Get Stream token
//       debugPrint('Getting Stream token for initialization...');
//       final tokenResponse = await getStreamToken();
//       debugPrint('Token response: $tokenResponse');

//       final streamToken = parseString(tokenResponse['token']);
//       debugPrint('Extracted Stream token: $streamToken');

//       const streamKey = 'g3x8kaxfpzw8';
//       debugPrint('Stream key: $streamKey');

//       if (streamToken.isEmpty) {
//         throw Exception('No valid Stream token available');
//       }

//       // Initialize Stream Chat client
//       debugPrint('Creating Stream client...');
//       _streamClient = stream.StreamChatClient(
//         streamKey,
//         logLevel: stream.Level.INFO,
//       );

//       // Connect user with token
//       debugPrint('Preparing to connect user to Stream...');
//       debugPrint('- User ID: ${currentUser.id}');
//       debugPrint('- User Name: ${currentUser.name}');
//       debugPrint('- Stream Token: $streamToken');

//       try {
//         debugPrint('Attempting to connect user to Stream...');
//         await _streamClient.connectUser(
//           stream.User(
//             id: currentUser.id,
//             name: currentUser.name.isNotEmpty ? currentUser.name : 'Anonymous',
//             extraData: {
//               'email': currentUser.email,
//               'role': currentUser.role,
//             },
//           ),
//           streamToken,
//         );
//         debugPrint('User connected successfully to Stream');
//         _isStreamInitialized = true;
//         debugPrint('Stream client initialized successfully');
//       } catch (e, stackTrace) {
//         debugPrint('Failed to connect user to Stream:');
//         debugPrint('Error: $e');
//         debugPrint('Stack trace: $stackTrace');
//         _isStreamInitialized = false;
//         throw Exception('Failed to connect user to Stream: $e');
//       }
//     } catch (e, stackTrace) {
//       debugPrint('Stream initialization failed:');
//       debugPrint('Error: $e');
//       debugPrint('Stack trace: $stackTrace');
//       if (e is TypeError) {
//         debugPrint('Type error details:');
//         debugPrint('- Error: ${e.toString()}');
//         debugPrint('- Stack trace: ${e.stackTrace}');
//       }
//       _isStreamInitialized = false;
//       rethrow;
//     }
//   }

//   // Stream event handlers
//   void _handleUserPresenceChanged(stream.Event event) {
//     final user = event.user;
//     debugPrint('User ${user?.id} presence changed: ${user?.online}');
//   }

//   void _handleCallRinging(stream.Event event) {
//     final extraData = event.extraData as Map<String, dynamic>?;
//     final callData = extraData?['call'] as Map<String, dynamic>?;
//     debugPrint('Incoming call from ${callData?['callerId']}');
//   }

//   void _handleCallAccepted(stream.Event event) {
//     final extraData = event.extraData as Map<String, dynamic>?;
//     final callData = extraData?['call'] as Map<String, dynamic>?;
//     debugPrint('Call accepted by ${callData?['calleeId']}');
//   }

//   void _handleCallRejected(stream.Event event) {
//     final extraData = event.extraData as Map<String, dynamic>?;
//     final callData = extraData?['call'] as Map<String, dynamic>?;
//     debugPrint('Call rejected by ${callData?['calleeId']}');
//   }

//   void _handleCallEnded(stream.Event event) {
//     final extraData = event.extraData as Map<String, dynamic>?;
//     final callData = extraData?['call'] as Map<String, dynamic>?;
//     debugPrint('Call ended: ${callData?['id']}');
//   }

//   // Room settings management
//   // Future<ApiRoom> updateRoomSettings(
//   //     String roomId, Map<String, dynamic> settings) async {
//   //   try {
//   //     if (!settings.containsKey('audio') || !settings.containsKey('video')) {
//   //       throw Exception('Settings must include audio and video properties');
//   //     }

//   //     final response = await _executeWithRetry(
//   //       apiCall: () => _dio.put(
//   //         '/audio-rooms/$roomId/settings',
//   //         data: settings,
//   //       ),
//   //     );

//   //     return ApiRoom.fromJson(response as Map<String, dynamic>);
//   //   } catch (e) {
//   //     debugPrint('Failed to update room settings: $e');
//   //     rethrow;
//   //   }
//   // }

//   Future<Map<String, dynamic>> getRoomSettings(String roomId) async {
//     try {
//       final response = await _executeWithRetry(
//         apiCall: () => _dio.get('/audio-rooms/$roomId/settings'),
//       );

//       return response as Map<String, dynamic>;
//     } catch (e) {
//       debugPrint('Failed to get room settings: $e');
//       rethrow;
//     }
//   }

//   // Call settings management
//   // Future<ApiCall> updateCallSettings(
//   //     String callId, Map<String, dynamic> settings) async {
//   //   try {
//   //     if (!settings.containsKey('audio') || !settings.containsKey('video')) {
//   //       throw Exception('Settings must include audio and video properties');
//   //     }

//   //     final response = await _executeWithRetry(
//   //       apiCall: () => _dio.put(
//   //         '/calls/$callId/settings',
//   //         data: settings,
//   //       ),
//   //     );

//   //     return ApiCall.fromJson(response as Map<String, dynamic>);
//   //   } catch (e) {
//   //     debugPrint('Failed to update call settings: $e');
//   //     rethrow;
//   //   }
//   // }

//   // Future<Map<String, dynamic>> getCallSettings(String callId) async {
//   //   try {
//   //     final response = await _executeWithRetry(
//   //       apiCall: () => _dio.get('/calls/$callId/settings'),
//   //     );

//   //     return response as Map<String, dynamic>;
//   //   } catch (e) {
//   //     debugPrint('Failed to get call settings: $e');
//   //     rethrow;
//   //   }
//   // }

//   // WebSocket support
//   void setupWebSocketListeners() {
//     _setupRoomEventListeners();
//     _setupCallEventListeners();
//   }

//   void _setupRoomEventListeners() {
//     _dio.interceptors.add(InterceptorsWrapper(
//       onResponse: (response, handler) {
//         if (response.requestOptions.path.contains('/audio-rooms')) {
//           _handleRoomUpdate(response.data);
//         }
//         return handler.next(response);
//       },
//     ));
//   }

//   void _setupCallEventListeners() {
//     _dio.interceptors.add(InterceptorsWrapper(
//       onResponse: (response, handler) {
//         if (response.requestOptions.path.contains('/calls')) {
//           _handleCallUpdate(response.data);
//         }
//         return handler.next(response);
//       },
//     ));
//   }

//   void _handleRoomUpdate(dynamic data) {
//     debugPrint('Room updated: $data');
//   }

//   void _handleCallUpdate(dynamic data) {
//     debugPrint('Call updated: $data');
//   }

//   // Get the appropriate base URL based on platform
//   String get baseUrl {
//     // For local development
//     // Android Emulator: 'http://10.0.2.2:5000/api'
//     // iOS Simulator: 'http://localhost:5000/api'
//     // Physical device: 'http://YOUR_LOCAL_IP:5000/api'

//     if (kIsWeb) {
//       return 'https://bddy-buddy.onrender.com';
//     } else if (defaultTargetPlatform == TargetPlatform.android) {
//       return 'https://bddy-buddy.onrender.com';
//     } else {
//       return 'https://bddy-buddy.onrender.com';
//     }
//   }

//   // Set auth token
//   Future<void> setAuthToken(String token) async {
//     _authToken = token;
//     await _secureStorage.write(key: _authTokenKey, value: token);
//   }

//   // Set current user
//   Future<void> setCurrentUser(Map<String, dynamic> user) async {
//     _currentUser = user;
//     await _secureStorage.write(
//       key: _currentUserKey,
//       value: jsonEncode(user),
//     );
//   }

//   // Clear auth state
//   Future<void> clearAuth() async {
//     _authToken = null;
//     _currentUser = null;
//     await _secureStorage.delete(key: _authTokenKey);
//     await _secureStorage.delete(key: _currentUserKey);
//     await _secureStorage.delete(key: _streamTokenKey);
//     await _secureStorage.delete(key: _streamTokenExpiryKey);
//   }

//   // Headers
//   Map<String, String> _headers(String? token) {
//     return {
//       'Content-Type': 'application/json',
//       if (token != null) 'Authorization': 'Bearer $token',
//       // Use the stored token if available and none is provided
//       if (token == null && _authToken != null)
//         'Authorization': 'Bearer $_authToken',
//     };
//   }

//   // Execute API call with timeout and retries
//   Future<dynamic> _executeWithRetry({
//     required Future<dynamic> Function() apiCall,
//     int retries = 3,
//     int timeoutSeconds = 30,
//   }) async {
//     int attempts = 0;

//     while (attempts <= retries) {
//       attempts++;
//       try {
//         final responseCompleter = Completer<dynamic>();

//         final timeoutTimer = Timer(Duration(seconds: timeoutSeconds), () {
//           if (!responseCompleter.isCompleted) {
//             responseCompleter.completeError(TimeoutException(
//                 'API request timed out after $timeoutSeconds seconds'));
//           }
//         });

//         apiCall().then((response) {
//           if (!responseCompleter.isCompleted) {
//             responseCompleter.complete(response);
//           }
//         }).catchError((error) {
//           if (!responseCompleter.isCompleted) {
//             responseCompleter.completeError(error);
//           }
//         });

//         final response = await responseCompleter.future;
//         timeoutTimer.cancel();

//         // Log the response for debugging
//         debugPrint('API Response: ${response.toString()}');

//         return _handleResponse(response);
//       } catch (e) {
//         debugPrint('API call attempt $attempts failed: $e');

//         // Log detailed error information
//         if (e is DioException) {
//           debugPrint('Error type: ${e.type}');
//           debugPrint('Error message: ${e.message}');
//           debugPrint('Error response: ${e.response?.data}');
//           debugPrint('Error status code: ${e.response?.statusCode}');
//         }

//         if (attempts > retries) {
//           if (e is DioException &&
//               e.type == DioExceptionType.connectionTimeout) {
//             throw Exception(
//                 'Connection timed out. Please check your internet connection and try again.');
//           } else if (e is DioException &&
//               e.type == DioExceptionType.receiveTimeout) {
//             throw Exception('Server response timed out. Please try again.');
//           } else {
//             throw Exception('API call failed after $retries retries: $e');
//           }
//         }

//         // Exponential backoff
//         final delay = Duration(seconds: attempts * 2);
//         debugPrint('Retrying in ${delay.inSeconds} seconds...');
//         await Future.delayed(delay);
//       }
//     }

//     throw Exception('API call failed');
//   }

//   // Handle API response
//   dynamic _handleResponse(Response response) {
//     final statusCode = response.statusCode;
//     final responseBody = response.data;

//     // Log the response for debugging
//     debugPrint('Response status code: $statusCode');
//     debugPrint('Response body: $responseBody');

//     if (statusCode != null && statusCode >= 200 && statusCode < 300) {
//       return responseBody;
//     } else {
//       String errorMessage;
//       if (responseBody is Map) {
//         errorMessage = responseBody['message'] ?? 'Unknown error occurred';
//       } else if (responseBody is String) {
//         errorMessage = responseBody;
//       } else {
//         errorMessage = 'Unknown error occurred';
//       }
//       throw Exception('API Error ($statusCode): $errorMessage');
//     }
//   }

//   // Register a new user
//   Future<ApiUser> register({
//     required String name,
//     required String email,
//     required String password,
//   }) async {
//     try {
//       debugPrint('Attempting registration for: $email');

//       final response = await _executeWithRetry(
//         apiCall: () async {
//           final result = await _dio.post(
//             '/api/auth/register',
//             data: {
//               'name': name,
//               'email': email,
//               'password': password,
//             },
//           );

//           debugPrint('Registration response: ${result.data}');
//           return result;
//         },
//       );

//       if (response == null) {
//         throw Exception('Registration failed: Empty response');
//       }

//       final responseData = response as Map<String, dynamic>;
//       final userData = responseData['user'] as Map<String, dynamic>;
//       final token = responseData['token'] as String;
//       final streamToken = responseData['streamToken'] as String;

//       debugPrint('Storing Stream token: $streamToken');

//       final user = ApiUser(
//         id: userData['id'] as String,
//         name: userData['name'] as String,
//         email: userData['email'] as String,
//         role: 'user',
//         createdAt: DateTime.now(),
//         token: token,
//         streamToken: streamToken,
//       );

//       // Store auth state securely
//       await setAuthToken(token);
//       await setCurrentUser(userData);
//       await _secureStorage.write(key: _streamTokenKey, value: streamToken);
//       await _secureStorage.write(
//         key: _streamTokenExpiryKey,
//         value: DateTime.now().add(const Duration(days: 1)).toIso8601String(),
//       );

//       return user;
//     } catch (e) {
//       debugPrint('Registration error: $e');
//       rethrow;
//     }
//   }

//   // Login a user
//   Future<ApiUser> login({
//     required String email,
//     required String password,
//   }) async {
//     try {
//       debugPrint('Attempting login for: $email');

//       final response = await _executeWithRetry(
//         apiCall: () async {
//           final result = await _dio.post(
//             '/api/auth/login',
//             data: {
//               'email': email,
//               'password': password,
//             },
//           );

//           debugPrint('Login response: ${result.data}');
//           return result;
//         },
//       );

//       if (response == null) {
//         throw Exception('Login failed: Empty response');
//       }

//       final responseData = response as Map<String, dynamic>;
//       final userData = responseData['user'] as Map<String, dynamic>;
//       final token = responseData['token'] as String;
//       final streamToken = responseData['streamToken'] as String;

//       debugPrint('Storing Stream token: $streamToken');

//       final user = ApiUser(
//         id: userData['id'] as String,
//         name: userData['name'] as String,
//         email: userData['email'] as String,
//         role: 'user',
//         createdAt: DateTime.now(),
//         token: token,
//         streamToken: streamToken,
//       );

//       // Store auth state securely
//       await setAuthToken(token);
//       await setCurrentUser(userData);
//       await _secureStorage.write(key: _streamTokenKey, value: streamToken);
//       await _secureStorage.write(
//         key: _streamTokenExpiryKey,
//         value: DateTime.now().add(const Duration(days: 1)).toIso8601String(),
//       );

//       return user;
//     } catch (e) {
//       debugPrint('Login error: $e');
//       rethrow;
//     }
//   }

//   // Validate token
//   Future<bool> validateToken(String token) async {
//     try {
//       await _executeWithRetry(
//         apiCall: () => _dio.post(
//           '/auth/validate',
//         ),
//       );
//       return true;
//     } catch (e) {
//       return false;
//     }
//   }

//   // Helper method for safe string parsing
//   String parseString(dynamic value, {String defaultValue = ''}) {
//     if (value == null) return defaultValue;
//     return value.toString();
//   }

//   // Get current user
//   Future<ApiUser> getCurrentUser() async {
//     try {
//       debugPrint('Getting current user from secure storage...');

//       // Get stored user data
//       final userJson = await _secureStorage.read(key: _currentUserKey);
//       if (userJson == null) {
//         throw Exception('No user data found. Please login first.');
//       }

//       try {
//         final userData = jsonDecode(userJson) as Map<String, dynamic>;

//         // Validate required fields with safe parsing
//         final id = parseString(userData['id']);
//         final name = parseString(userData['name']);
//         final email = parseString(userData['email']);

//         if (id.isEmpty || name.isEmpty || email.isEmpty) {
//           throw Exception('Invalid user data in storage');
//         }

//         // Get stored tokens
//         final authToken = await _secureStorage.read(key: _authTokenKey);
//         final streamToken = await _secureStorage.read(key: _streamTokenKey);

//         if (authToken == null) {
//           throw Exception('No auth token found. Please login again.');
//         }

//         // Create ApiUser with stored data using safe parsing
//         return ApiUser(
//           id: id,
//           name: name,
//           email: email,
//           role: parseString(userData['role'], defaultValue: 'user'),
//           createdAt: DateTime.parse(parseString(
//             userData['createdAt'],
//             defaultValue: DateTime.now().toIso8601String(),
//           )),
//           token: authToken,
//           streamToken: streamToken ?? parseString(userData['streamToken']),
//         );
//       } catch (e) {
//         debugPrint('Error parsing stored user data: $e');
//         throw Exception('Invalid user data format in storage');
//       }
//     } catch (e) {
//       debugPrint('Get current user error: $e');
//       rethrow;
//     }
//   }

//   // User Management

//   // Get all users (Dummy implementation)
//   Future<List<ApiUser>> getAllUsers() async {
//     // Dummy implementation
//     await Future.delayed(const Duration(seconds: 1)); // Simulate network delay

//     return [
//       ApiUser.fromJson({
//         'id': 'dummy_user_1',
//         'name': 'Test User 1',
//         'email': 'test1@example.com',
//         'role': 'user',
//         'createdAt': DateTime.now().toIso8601String(),
//       }),
//       ApiUser.fromJson({
//         'id': 'dummy_user_2',
//         'name': 'Test User 2',
//         'email': 'test2@example.com',
//         'role': 'user',
//         'createdAt': DateTime.now().toIso8601String(),
//       }),
//     ];
//   }

//   // Call Management Methods

//   // // Create a new call
//   // Future<ApiCall> createCall() async {
//   //   try {
//   //     debugPrint('Creating new call...');

//   //     final response = await _executeWithRetry(
//   //       apiCall: () async {
//   //         final result = await _dio.post(
//   //           '/api/calls',
//   //           options: Options(
//   //             headers: {
//   //               if (_authToken != null) 'Authorization': 'Bearer $_authToken',
//   //             },
//   //           ),
//   //         );

//   //         debugPrint('Create call response: ${result.data}');
//   //         return result;
//   //       },
//   //     );

//   //     if (response == null) {
//   //       throw Exception('Failed to create call: Empty response');
//   //     }

//   //     return ApiCall.fromJson(response as Map<String, dynamic>);
//   //   } catch (e) {
//   //     debugPrint('Create call error: $e');
//   //     rethrow;
//   //   }
//   // }

//   // // Get user's calls
//   // Future<List<ApiCall>> getUserCalls() async {
//   //   try {
//   //     debugPrint('Getting call history...');

//   //     final response = await _executeWithRetry(
//   //       apiCall: () async {
//   //         final result = await _dio.get(
//   //           '/api/calls',
//   //           options: Options(
//   //             headers: {
//   //               if (_authToken != null) 'Authorization': 'Bearer $_authToken',
//   //             },
//   //           ),
//   //         );

//   //         debugPrint('Get call history response: ${result.data}');
//   //         return result;
//   //       },
//   //     );

//   //     if (response == null) {
//   //       throw Exception('Failed to get call history: Empty response');
//   //     }

//   //     return (response as List)
//   //         .map((call) => ApiCall.fromJson(call as Map<String, dynamic>))
//   //         .toList();
//   //   } catch (e) {
//   //     debugPrint('Get call history error: $e');
//   //     rethrow;
//   //   }
//   // }

//   // // Join a call
//   // Future<ApiCall> joinCall(String callId) async {
//   //   final response = await _executeWithRetry(
//   //     apiCall: () => _dio.post(
//   //       '/calls/$callId/join',
//   //       data: {
//   //         'userId': _currentUser?['id'],
//   //         'joinedAt': DateTime.now().toIso8601String(),
//   //       },
//   //     ),
//   //   );

//   //   return ApiCall.fromJson(response as Map<String, dynamic>);
//   // }

//   // // Leave a call
//   // Future<ApiCall> leaveCall(String callId) async {
//   //   final response = await _executeWithRetry(
//   //     apiCall: () => _dio.post(
//   //       '/calls/$callId/leave',
//   //       data: {
//   //         'userId': _currentUser?['id'],
//   //         'leftAt': DateTime.now().toIso8601String(),
//   //       },
//   //     ),
//   //   );

//   //   return ApiCall.fromJson(response as Map<String, dynamic>);
//   // }

//   // // End a call
//   // Future<ApiCall> endCall(String callId) async {
//   //   try {
//   //     debugPrint('Ending call: $callId');

//   //     final response = await _executeWithRetry(
//   //       apiCall: () async {
//   //         final result = await _dio.post(
//   //           '/api/calls/$callId/end',
//   //           options: Options(
//   //             headers: {
//   //               if (_authToken != null) 'Authorization': 'Bearer $_authToken',
//   //             },
//   //           ),
//   //         );

//   //         debugPrint('End call response: ${result.data}');
//   //         return result;
//   //       },
//   //     );

//   //     if (response == null) {
//   //       throw Exception('Failed to end call: Empty response');
//   //     }

//   //     return ApiCall.fromJson(response as Map<String, dynamic>);
//   //   } catch (e) {
//   //     debugPrint('End call error: $e');
//   //     rethrow;
//   //   }
//   // }

//   // Get Stream token
//   Future<Map<String, dynamic>> getStreamToken() async {
//     try {
//       debugPrint('Getting Stream token...');

//       // Try to get stored token first
//       final storedToken = await _secureStorage.read(key: _streamTokenKey);
//       final storedExpiry =
//           await _secureStorage.read(key: _streamTokenExpiryKey);

//       debugPrint('Stored Stream token: $storedToken');
//       debugPrint('Stored Stream token expiry: $storedExpiry');

//       if (storedToken != null && storedExpiry != null) {
//         final expiryDate = DateTime.parse(storedExpiry);
//         if (expiryDate.isAfter(DateTime.now())) {
//           debugPrint('Using stored valid Stream token');
//           return {
//             'token': storedToken,
//             'expiresAt': storedExpiry,
//           };
//         } else {
//           debugPrint('Stored Stream token expired on $expiryDate');
//         }
//       }

//       debugPrint('Getting new Stream token from API...');

//       if (_authToken == null) {
//         debugPrint('No auth token available, generating fallback token');
//         final fallbackToken =
//             'fallback-token-${DateTime.now().millisecondsSinceEpoch}';
//         final fallbackExpiry =
//             DateTime.now().add(const Duration(days: 1)).toIso8601String();

//         await _secureStorage.write(key: _streamTokenKey, value: fallbackToken);
//         await _secureStorage.write(
//             key: _streamTokenExpiryKey, value: fallbackExpiry);

//         return {
//           'token': fallbackToken,
//           'expiresAt': fallbackExpiry,
//         };
//       }

//       try {
//         final response = await _executeWithRetry(
//           apiCall: () async {
//             final result = await _dio.post(
//               '/api/users/stream-token',
//               options: Options(
//                 headers: {
//                   'Authorization': 'Bearer $_authToken',
//                 },
//               ),
//             );
//             debugPrint('Stream token API response: ${result.data}');
//             return result;
//           },
//         );

//         if (response == null) {
//           throw Exception('Empty response from Stream token API');
//         }

//         final streamToken = response['streamToken'] ?? response['token'];
//         debugPrint('Extracted token from API response: $streamToken');

//         if (streamToken == null || streamToken.isEmpty) {
//           throw Exception('No Stream token in API response');
//         }

//         debugPrint('Successfully retrieved new Stream token');

//         final expiry =
//             DateTime.now().add(const Duration(days: 1)).toIso8601String();
//         await _secureStorage.write(key: _streamTokenKey, value: streamToken);
//         await _secureStorage.write(key: _streamTokenExpiryKey, value: expiry);

//         return {
//           'token': streamToken,
//           'expiresAt': expiry,
//         };
//       } catch (e) {
//         debugPrint('Failed to get Stream token from API: $e');
//         debugPrint('Generating fallback token...');

//         final fallbackToken =
//             'fallback-token-${DateTime.now().millisecondsSinceEpoch}';
//         final fallbackExpiry =
//             DateTime.now().add(const Duration(days: 1)).toIso8601String();

//         await _secureStorage.write(key: _streamTokenKey, value: fallbackToken);
//         await _secureStorage.write(
//             key: _streamTokenExpiryKey, value: fallbackExpiry);

//         debugPrint('Using fallback Stream token');
//         return {
//           'token': fallbackToken,
//           'expiresAt': fallbackExpiry,
//         };
//       }
//     } catch (e) {
//       debugPrint('Error in getStreamToken: $e');
//       rethrow;
//     }
//   }

//   // Clear Stream token
//   Future<void> clearStreamToken() async {
//     await _secureStorage.delete(key: _streamTokenKey);
//     await _secureStorage.delete(key: _streamTokenExpiryKey);
//     _isStreamInitialized = false;
//   }

//   // Error handling interceptor
//   void _handleError(dynamic error) {
//     if (error is http.ClientException) {
//       throw Exception('Network error: ${error.message}');
//     } else if (error is TimeoutException) {
//       throw Exception('Request timed out');
//     } else if (error is FormatException) {
//       throw Exception('Invalid response format');
//     } else {
//       throw Exception('An unexpected error occurred: $error');
//     }
//   }

//   // Token refresh logic (Dummy implementation)
//   Future<void> _refreshToken() async {
//     // Dummy implementation
//     await Future.delayed(
//         const Duration(milliseconds: 500)); // Simulate network delay
//     return; // Always succeed for dummy implementation
//   }

//   // Dispose method
//   Future<void> dispose() async {
//     _dio.close();
//     if (_isStreamInitialized) {
//       _streamClient.disconnectUser();
//     }
//     _webSocketChannel?.sink.close();
//     await clearAuth();
//   }

//   // Audio Room Methods

//   // // Get all audio rooms
//   // Future<List<ApiRoom>> getAudioRooms() async {
//   //   try {
//   //     debugPrint('Getting all audio rooms...');

//   //     final response = await _executeWithRetry(
//   //       apiCall: () async {
//   //         final result = await _dio.get(
//   //           '/api/audio-rooms',
//   //           options: Options(
//   //             headers: {
//   //               if (_authToken != null) 'Authorization': 'Bearer $_authToken',
//   //             },
//   //             validateStatus: (status) {
//   //               // Accept 200 and 404 status codes
//   //               return status != null && (status == 200 || status == 404);
//   //             },
//   //           ),
//   //         );

//   //         debugPrint('Get rooms response: ${result.data}');
//   //         return result;
//   //       },
//   //     );

//   //     if (response == null) {
//   //       debugPrint('No rooms available');
//   //       return [];
//   //     }

//   //     // Handle 404 response
//   //     if (response is Response && response.statusCode == 404) {
//   //       debugPrint('No rooms available');
//   //       return [];
//   //     }

//   //     // Handle empty response
//   //     if (response is! List) {
//   //       debugPrint('Invalid response format for rooms');
//   //       return [];
//   //     }

//   //     return response
//   //         .map((room) => ApiRoom.fromJson(room as Map<String, dynamic>))
//   //         .toList();
//   //   } catch (e) {
//   //     debugPrint('Get rooms error: $e');
//   //     if (e is DioException) {
//   //       if (e.response?.statusCode == 404) {
//   //         debugPrint('No rooms available');
//   //         return [];
//   //       }
//   //     }
//   //     rethrow;
//   //   }
//   // }

//   // Create a new audio room
//   // Future<ApiRoom> createAudioRoom({
//   //   required String roomName,
//   //   Map<String, dynamic>? settings,
//   // }) async {
//   //   try {
//   //     debugPrint('Creating new audio room: $roomName');

//   //     if (_authToken == null) {
//   //       throw Exception('Authentication required. Please login first.');
//   //     }

//   //     // 1. Create room in backend
//   //     final response = await _executeWithRetry(
//   //       apiCall: () async {
//   //         final result = await _dio.post(
//   //           '/api/audio-rooms',
//   //           data: {
//   //             'roomName': roomName,
//   //             'settings': settings ?? {'audio': true, 'video': false},
//   //           },
//   //           options: Options(
//   //             headers: {
//   //               'Content-Type': 'application/json',
//   //               'Authorization': 'Bearer $_authToken',
//   //             },
//   //           ),
//   //         );

//   //         debugPrint('Create room response: ${result.data}');
//   //         return result;
//   //       },
//   //     );

//   //     if (response == null) {
//   //       throw Exception('Failed to create room: Empty response');
//   //     }

//   //     // 2. Parse response data
//   //     final roomData = response as Map<String, dynamic>;
//   //     final createdBy = roomData['host'] as Map<String, dynamic>;
//   //     final participants =
//   //         (roomData['participants'] as List).cast<Map<String, dynamic>>();

//   // 3. Create ApiRoom object
//   //     final room = ApiRoom(
//   //       id: roomData['_id'] as String,
//   //       roomName: roomData['roomName'] as String,
//   //       host: ApiUser(
//   //         id: createdBy['_id'] as String,
//   //         name: createdBy['name'] as String,
//   //         email: createdBy['email'] as String,
//   //         role: 'user',
//   //         createdAt: DateTime.parse(roomData['createdAt'] as String),
//   //       ),
//   //       participants: participants.map((p) {
//   //         return ApiUser(
//   //           id: p['_id'] as String,
//   //           name: p['name'] as String,
//   //           email: p['email'] as String,
//   //           role: 'user',
//   //           createdAt: DateTime.parse(roomData['createdAt'] as String),
//   //         );
//   //       }).toList(),
//   //       streamCallId: roomData['streamCallId'] as String,
//   //       channelId: roomData['channelId'] as String,
//   //       settings: RoomSettings(
//   //         audio: roomData['settings']['audio'] as bool,
//   //         video: roomData['settings']['video'] as bool,
//   //       ),
//   //       status: roomData['status'] as String,
//   //       createdAt: DateTime.parse(roomData['createdAt'] as String),
//   //     );

//   //     debugPrint('Room created successfully');
//   //     return room;
//   //   } catch (e) {
//   //     debugPrint('Create room error: $e');
//   //     if (e is DioException) {
//   //       debugPrint('Error type: ${e.type}');
//   //       debugPrint('Error message: ${e.message}');
//   //       debugPrint('Error response: ${e.response?.data}');
//   //       debugPrint('Error status code: ${e.response?.statusCode}');

//   //       if (e.response?.statusCode == 401) {
//   //         throw Exception('Unauthorized: Please login again');
//   //       } else if (e.response?.statusCode == 404) {
//   //         throw Exception('Audio rooms endpoint not found');
//   //       }
//   //     }
//   //     rethrow;
//   //   }
//   // }

//   // // Join an audio room
//   // Future<ApiRoom> joinRoom(String roomId) async {
//   //   try {
//   //     debugPrint('Joining room: $roomId');

//   //     final response = await _executeWithRetry(
//   //       apiCall: () async {
//   //         final result = await _dio.post(
//   //           '/api/audio-rooms/$roomId/join',
//   //           options: Options(
//   //             headers: {
//   //               if (_authToken != null) 'Authorization': 'Bearer $_authToken',
//   //             },
//   //           ),
//   //         );

//   //         debugPrint('Join room response: ${result.data}');
//   //         return result;
//   //       },
//   //     );

//   //     if (response == null) {
//   //       throw Exception('Failed to join room: Empty response');
//   //     }

//   //     return ApiRoom.fromJson(response as Map<String, dynamic>);
//   //   } catch (e) {
//   //     debugPrint('Join room error: $e');
//   //     rethrow;
//   //   }
//   // }

//   // Leave an audio room
//   // Future<ApiRoom> leaveRoom(String roomId) async {
//   //   try {
//   //     debugPrint('Leaving room: $roomId');

//   //     final response = await _executeWithRetry(
//   //       apiCall: () async {
//   //         final result = await _dio.post(
//   //           '/api/audio-rooms/$roomId/leave',
//   //           options: Options(
//   //             headers: {
//   //               if (_authToken != null) 'Authorization': 'Bearer $_authToken',
//   //             },
//   //           ),
//   //         );

//   //         debugPrint('Leave room response: ${result.data}');
//   //         return result;
//   //       },
//   //     );

//   //     if (response == null) {
//   //       throw Exception('Failed to leave room: Empty response');
//   //     }

//   //     return ApiRoom.fromJson(response as Map<String, dynamic>);
//   //   } catch (e) {
//   //     debugPrint('Leave room error: $e');
//   //     if (e is DioException) {
//   //       if (e.response?.statusCode == 401) {
//   //         throw Exception('Unauthorized: Please login again');
//   //       } else if (e.response?.statusCode == 404) {
//   //         throw Exception('Leave room endpoint not found');
//   //       }
//   //     }
//   //     rethrow;
//   //   }
//   // }

//   // Get room details
//   // Future<ApiRoom> getRoomDetails(String roomId) async {
//   //   try {
//   //     debugPrint('Getting details for room: $roomId');

//   //     final response = await _executeWithRetry(
//   //       apiCall: () async {
//   //         final result = await _dio.get(
//   //           '/api/audio-rooms/$roomId',
//   //           options: Options(
//   //             headers: {
//   //               if (_authToken != null) 'Authorization': 'Bearer $_authToken',
//   //             },
//   //           ),
//   //         );

//   //         debugPrint('Get room details response: ${result.data}');
//   //         return result;
//   //       },
//   //     );

//   //     if (response == null) {
//   //       throw Exception('Failed to get room details: Empty response');
//   //     }

//   //     return ApiRoom.fromJson(response as Map<String, dynamic>);
//   //   } catch (e) {
//   //     debugPrint('Get room details error: $e');
//   //     rethrow;
//   //   }
//   // }

//   // // Check API health
//   // Future<Map<String, dynamic>> checkHealth() async {
//   //   try {
//   //     debugPrint('Checking API health...');

//   //     final response = await _executeWithRetry(
//   //       apiCall: () async {
//   //         final result = await _dio.get('/health');
//   //         debugPrint('Health check response: ${result.data}');
//   //         return result;
//   //       },
//   //     );

//   //     if (response == null) {
//   //       throw Exception('Failed to check health: Empty response');
//   //     }

//   //     return response as Map<String, dynamic>;
//   //   } catch (e) {
//   //     debugPrint('Health check error: $e');
//   //     rethrow;
//   //   }
//   // }
// }
