import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../views/dashboard/dashboard_screen.dart';
import '../../views/settings/settings_screen.dart';
import '../../views/splash/splash_screen.dart';
import '../../views/walkthrough/walkthrough_screen.dart';
import '../../views/products/products_screen.dart';
import '../../views/products/smart_input_screen.dart';
import '../../views/auth/login_screen.dart';
import '../../views/auth/register_screen.dart';
import '../../views/audio_room/audio_room_home.dart';
import '../../views/audio_room/audio_room_screen.dart';
import '../../views/audio_room/create_audio_room_screen.dart';
import '../../views/analytics/analytics_screen.dart';
import '../../views/poster_editor_screen.dart';
import '../../models/audio_room.dart';
import '../../providers/audio_room_provider.dart';
import '../../providers/auth_provider.dart';
import '../../views/employees/employees_screen.dart';
import '../../views/chat/chat_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  // Listen to auth state changes
  final isLoggedIn = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final isGoingToAuth = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';
      final isGoingToSplash = state.matchedLocation == '/splash' ||
          state.matchedLocation == '/walkthrough';

      // Skip redirection for auth and splash screens
      if (isGoingToAuth || isGoingToSplash) {
        return null;
      }

      // Redirect to login if not logged in and trying to access protected route
      if (!isLoggedIn) {
        return '/login';
      }

      return null;
    },
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Successfully logged in',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              textAlign: TextAlign.center,
              'Go to dashboard',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/dashboard'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
              child: const Text('Go to Dashboard'),
            ),
          ],
        ),
      ),
    ),
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),

      GoRoute(
        path: '/walkthrough',
        builder: (context, state) => const WalkthroughScreen(),
      ),

      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),

      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      // GoRoute(
      //   path: '/debug/test-call',
      //   builder: (context, state) => const TestCallScreen(),
      // ),
      // GoRoute(
      //   path: '/join-call/:callId',
      //   builder: (context, state) {
      //     final callId = state.pathParameters['callId']!;
      //     final videoProvider = ref.read(videoCallProvider);

      //     return FutureBuilder(
      //       future: () async {
      //         await videoProvider.initialize();
      //         final call = await videoProvider.joinCallById(callId);
      //         return call;
      //       }(),
      //       builder: (context, snapshot) {
      //         if (snapshot.connectionState == ConnectionState.waiting) {
      //           return const Scaffold(
      //             body: Center(
      //               child: CircularProgressIndicator(),
      //             ),
      //           );
      //         }

      //         if (snapshot.hasError) {
      //           return Scaffold(
      //             body: Center(
      //               child: Text('Error joining call: ${snapshot.error}'),
      //             ),
      //           );
      //         }

      //         return CallScreen(call: snapshot.data!);
      //       },
      //     );
      //   },
      // ),
      ShellRoute(
        builder: (context, state, child) {
          return Scaffold(
            body: Stack(
              children: [
                child,
                Positioned(
                  left: 20,
                  bottom: 10,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => context.go('/chat'),
                        borderRadius: BorderRadius.circular(25),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.smart_toy,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer,
                                size: 22,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            bottomNavigationBar: NavigationBar(
              selectedIndex: _calculateSelectedIndex(state),
              onDestinationSelected: (index) {
                switch (index) {
                  case 0:
                    context.go('/dashboard');
                    break;
                  case 1:
                    context.go('/products');
                    break;
                  case 2:
                    context.go('/analytics');
                    break;
                  case 3:
                    context.go('/poster');
                    break;
                  case 4:
                    context.go('/settings');
                    break;
                }
              },
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  selectedIcon: Icon(Icons.dashboard),
                  label: 'Dashboard',
                ),
                NavigationDestination(
                  icon: Icon(Icons.inventory_2_outlined),
                  selectedIcon: Icon(Icons.inventory_2),
                  label: 'Products',
                ),
                NavigationDestination(
                  icon: Icon(Icons.analytics_outlined),
                  selectedIcon: Icon(Icons.analytics),
                  label: 'Analytics',
                ),
                NavigationDestination(
                  icon: Icon(Icons.image_outlined),
                  selectedIcon: Icon(Icons.image),
                  label: 'Poster',
                ),
                NavigationDestination(
                  icon: Icon(Icons.settings_outlined),
                  selectedIcon: Icon(Icons.settings),
                  label: 'Settings',
                ),
              ],
            ),
          );
        },
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const DashboardScreen(),
            routes: [
              GoRoute(
                path: 'employees',
                builder: (context, state) => const EmployeesScreen(),
              ),
            ],
          ),
          GoRoute(
            path: '/products',
            builder: (context, state) => const ProductsScreen(),
            routes: [
              GoRoute(
                path: 'add',
                builder: (context, state) => const SmartInputScreen(),
              ),
            ],
          ),
          GoRoute(
            path: '/analytics',
            builder: (context, state) => AnalyticsScreen(),
          ),
          GoRoute(
            path: '/poster',
            builder: (context, state) => const PosterEditorScreen(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
      // GoRoute(
      //   path: '/call',
      //   builder: (context, state) {
      //     final call = state.extra as stream_video.Call;
      //     return CallScreen(call: call);
      //   },
      // ),
      GoRoute(
        path: '/audio-rooms',
        name: 'audioRooms',
        builder: (context, state) => const AudioRoomHome(),
        routes: [
          GoRoute(
            path: 'create',
            name: 'createAudioRoom',
            builder: (context, state) => const CreateAudioRoomScreen(),
          ),
          GoRoute(
            path: ':roomId',
            name: 'audioRoom',
            builder: (context, state) {
              final roomId = state.pathParameters['roomId'];
              final isHost = state.uri.queryParameters['isHost'] == 'true';
              final room = state.extra as ApiRoom?;

              if (room != null) {
                return AudioRoomScreen(
                  room: room,
                  isHost: isHost,
                );
              }

              // If we don't have the room as extra, fetch it from provider
              final rooms = ref.read(audioRoomsProvider);
              final foundRoom = rooms.firstWhere(
                (r) => r.id == roomId,
                orElse: () => throw Exception('Room not found'),
              );

              return AudioRoomScreen(
                room: foundRoom,
                isHost: isHost,
              );
            },
          ),
        ],
      ),
      GoRoute(
        path: '/chat',
        builder: (context, state) => const ChatScreen(),
      ),
    ],
  );
});

int _calculateSelectedIndex(GoRouterState state) {
  final String location = state.uri.toString();
  if (location.startsWith('/dashboard')) return 0;
  if (location.startsWith('/products')) return 1;
  if (location.startsWith('/analysis')) return 2;
  if (location.startsWith('/poster')) return 3;
  if (location.startsWith('/settings')) return 4;
  return 0;
}
