import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class TranslationService {
  // This is a simple implementation using a public translation API
  // In production, you should use a more reliable service with API keys

  Future<String> translateText({
    required String text,
    required String targetLanguage,
    String sourceLanguage = 'en',
  }) async {
    if (text.isEmpty) return text;

    try {
      // Using LibreTranslate API as an example
      final url = Uri.parse('https://libretranslate.de/translate');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'q': text,
          'source': sourceLanguage,
          'target': targetLanguage,
          'format': 'text',
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return jsonResponse['translatedText'] as String;
      } else {
        debugPrint(
            'Translation error: ${response.statusCode} ${response.body}');
        return text; // Return original text on error
      }
    } catch (e) {
      debugPrint('Translation exception: $e');
      return text; // Return original text on error
    }
  }
}
