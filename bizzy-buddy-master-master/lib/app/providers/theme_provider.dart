import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Provider for the app's theme mode
final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  final box = Hive.box('settings');
  final themeModeString = box.get('themeMode', defaultValue: 'system');

  ThemeMode initialTheme;
  switch (themeModeString) {
    case 'light':
      initialTheme = ThemeMode.light;
      break;
    case 'dark':
      initialTheme = ThemeMode.dark;
      break;
    default:
      initialTheme = ThemeMode.system;
  }

  return ThemeModeNotifier(initialTheme, box);
});

/// Notifier class to manage theme mode changes
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  final Box _settingsBox;

  ThemeModeNotifier(super.initialTheme, this._settingsBox);

  /// Set the app's theme mode and save it to storage
  void setThemeMode(ThemeMode themeMode) {
    // Update state
    state = themeMode;

    // Save to Hive box
    String themeModeString;
    switch (themeMode) {
      case ThemeMode.light:
        themeModeString = 'light';
        break;
      case ThemeMode.dark:
        themeModeString = 'dark';
        break;
      case ThemeMode.system:
      default:
        themeModeString = 'system';
    }
    _settingsBox.put('themeMode', themeModeString);
  }
}

/// Light theme data
final lightTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.blue,
    brightness: Brightness.light,
  ),
  appBarTheme: const AppBarTheme(
    centerTitle: true,
    elevation: 0,
  ),
  cardTheme: CardTheme(
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  ),
);

/// Dark theme data
final darkTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.blue,
    brightness: Brightness.dark,
  ),
  appBarTheme: const AppBarTheme(
    centerTitle: true,
    elevation: 0,
  ),
  cardTheme: CardTheme(
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  ),
);
