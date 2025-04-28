import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class StreamConfig {
  static String get apiKey {
    final key = dotenv.env['STREAM_API_KEY'];
    if (key == null || key.isEmpty) {
      throw Exception('STREAM_API_KEY not found in environment variables');
    }
    return key;
  }

  static String get apiSecret {
    final secret = dotenv.env['STREAM_API_SECRET'];
    if (secret == null || secret.isEmpty) {
      throw Exception('STREAM_API_SECRET not found in environment variables');
    }
    return secret;
  }

  static String get baseUrl {
    // For local development
    // Android Emulator: 'http://10.0.2.2:3000'
    // iOS Simulator: 'http://localhost:3000'
    // Physical device: 'http://YOUR_LOCAL_IP:3000'

    if (kIsWeb) {
      return dotenv.env['API_BASE_URL'] ?? 'http://localhost:3000';
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      return dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:3000';
    } else {
      return dotenv.env['API_BASE_URL'] ?? 'http://localhost:3000';
    }
  }
}
