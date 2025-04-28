import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';

/// Service for handling translations using the Indian Languages API
class TranslatorService {
  /// Base URL for the Indian Languages Translator API
  final String _baseUrl = 'https://render2-vjk5.onrender.com';

  /// Get list of supported languages
  Future<Map<String, String>> getSupportedLanguages() async {
    try {
      debugPrint('Fetching supported languages from $_baseUrl');
      final response = await http.get(Uri.parse('$_baseUrl/'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final Map<String, dynamic> languagesMap = data['supported_languages'];
        debugPrint('Received ${languagesMap.length} supported languages');

        // Convert to Map<String, String>
        return languagesMap
            .map((key, value) => MapEntry(key, value.toString()));
      } else {
        debugPrint(
            'Failed to load supported languages: ${response.statusCode}');
        return _getDefaultLanguages();
      }
    } catch (e) {
      debugPrint('Error fetching supported languages: $e');
      return _getDefaultLanguages();
    }
  }

  /// Translate single text
  Future<Map<String, dynamic>> translate({
    required String text,
    required String targetLanguage,
    String sourceLanguage = 'en',
  }) async {
    // Skip empty text or same language
    if (text.isEmpty || targetLanguage == sourceLanguage) {
      return {
        'translated_text': text,
        'source_language': sourceLanguage,
        'target_language': targetLanguage,
      };
    }

    try {
      debugPrint('Translating "$text" from $sourceLanguage to $targetLanguage');
      final response = await http.post(
        Uri.parse('$_baseUrl/translate'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'text': text,
          'target_language': targetLanguage,
          'source_language': sourceLanguage,
        }),
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        debugPrint('Translation successful: ${result['translated_text']}');
        return result;
      } else {
        debugPrint('Translation failed: ${response.body}');
        return {
          'translated_text': text,
          'source_language': sourceLanguage,
          'target_language': targetLanguage,
        };
      }
    } catch (e) {
      debugPrint('Error during translation: $e');
      // Fallback to mock implementation for offline usage or during errors
      return {
        'translated_text': _mockTranslate(text, targetLanguage),
        'source_language': sourceLanguage,
        'target_language': targetLanguage,
      };
    }
  }

  /// Batch translate multiple texts
  Future<List<Map<String, dynamic>>> batchTranslate({
    required List<String> texts,
    required String targetLanguage,
    String sourceLanguage = 'en',
  }) async {
    try {
      debugPrint('Batch translating ${texts.length} texts to $targetLanguage');
      final response = await http.post(
        Uri.parse('$_baseUrl/translate/batch'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'texts': texts,
          'target_language': targetLanguage,
          'source_language': sourceLanguage,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['translations']);
      } else {
        debugPrint('Batch translation failed: ${response.body}');
        // Create fallback response
        return texts
            .map((text) => {
                  'translated_text': _mockTranslate(text, targetLanguage),
                  'source_language': sourceLanguage,
                  'target_language': targetLanguage,
                })
            .toList();
      }
    } catch (e) {
      debugPrint('Error during batch translation: $e');
      // Create fallback response
      return texts
          .map((text) => {
                'translated_text': _mockTranslate(text, targetLanguage),
                'source_language': sourceLanguage,
                'target_language': targetLanguage,
              })
          .toList();
    }
  }

  /// Export translations to a file format
  Future<String> exportTranslations({
    required List<String> texts,
    required String targetLanguage,
    String sourceLanguage = 'en',
    String format = 'json', // 'json' or 'csv'
  }) async {
    try {
      debugPrint('Exporting translations to $format format');
      final response = await http.post(
        Uri.parse('$_baseUrl/export?format=$format'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'texts': texts,
          'target_language': targetLanguage,
          'source_language': sourceLanguage,
        }),
      );

      if (response.statusCode == 200) {
        return response.body;
      } else {
        throw Exception('Failed to export translations: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error exporting translations: $e');
      throw Exception('Failed to export translations: $e');
    }
  }

  // Helper method to get default supported languages
  Map<String, String> _getDefaultLanguages() {
    return {
      'en': 'English',
      'hi': 'Hindi',
      'bn': 'Bengali',
      'te': 'Telugu',
      'ta': 'Tamil',
      'mr': 'Marathi',
      'gu': 'Gujarati',
      'kn': 'Kannada',
      'ml': 'Malayalam',
      'pa': 'Punjabi',
    };
  }

  /// Mock translation implementation for fallback
  String _mockTranslate(String text, String targetLanguage) {
    // Handle empty text
    if (text.isEmpty) return text;

    // Add a prefix to indicate translation
    final prefix = _getLanguagePrefix(targetLanguage);

    debugPrint('Using mock translation for "$text" to $targetLanguage');

    // Add some basic translations for common words
    final translations = {
      'hi': {
        'Sales Report': 'बिक्री रिपोर्ट',
        'Date': 'तारीख',
        'Product ID': 'उत्पाद आईडी',
        'Quantity': 'मात्रा',
        'Unit Price': 'इकाई मूल्य',
        'Total Amount': 'कुल राशि',
        'Daily Sales': 'दैनिक बिक्री',
        'Business Report': 'व्यवसाय रिपोर्ट',
      },
      'bn': {
        'Sales Report': 'বিক্রয় রিপোর্ট',
        'Date': 'তারিখ',
        'Product ID': 'পণ্য আইডি',
        'Quantity': 'পরিমাণ',
        'Unit Price': 'একক মূল্য',
        'Total Amount': 'মোট পরিমাণ',
        'Daily Sales': 'দৈনিক বিক্রয়',
        'Business Report': 'ব্যবসায় রিপোর্ট',
      },
      'te': {
        'Sales Report': 'విక్రయ నివేదిక',
        'Date': 'తేదీ',
        'Product ID': 'ఉత్పత్తి ఐడి',
        'Quantity': 'పరిమాణం',
        'Unit Price': 'యూనిట్ ధర',
        'Total Amount': 'మొత్తం మొత్తం',
        'Daily Sales': 'రోజువారీ విక్రయాలు',
        'Business Report': 'వ్యాపార నివేదిక',
      },
    };

    // Check if we have a translation for this text and language
    if (translations.containsKey(targetLanguage) &&
        translations[targetLanguage]!.containsKey(text)) {
      return translations[targetLanguage]![text]!;
    }

    // Otherwise, add a prefix to indicate translation
    return '$prefix $text';
  }

  /// Get language prefix for mock translations
  String _getLanguagePrefix(String languageCode) {
    switch (languageCode) {
      case 'hi':
        return '[Hindi]';
      case 'bn':
        return '[Bengali]';
      case 'te':
        return '[Telugu]';
      case 'ta':
        return '[Tamil]';
      case 'ml':
        return '[Malayalam]';
      case 'gu':
        return '[Gujarati]';
      case 'kn':
        return '[Kannada]';
      case 'mr':
        return '[Marathi]';
      case 'pa':
        return '[Punjabi]';
      default:
        return '[Translated]';
    }
  }
}

final translatorServiceProvider = Provider<TranslatorService>((ref) {
  return TranslatorService();
});
