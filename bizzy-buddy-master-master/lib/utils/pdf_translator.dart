import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/translator_provider.dart' as provider;
import '../services/translator_service.dart';
import 'package:flutter/foundation.dart';

/// Utility class for translating PDF content
///
/// This class handles translation of text for PDF export, including:
/// - Single text translation with numeric value preservation
/// - Batch translation of multiple texts
/// - Map translation with key preservation
class PdfTranslator {
  final String targetLanguage;
  final TranslatorService _translatorService;

  PdfTranslator({
    required this.targetLanguage,
    required TranslatorService translatorService,
  }) : _translatorService = translatorService;

  /// Translates text to the target language
  ///
  /// Features:
  /// - Skips translation for empty text or when target is English
  /// - Preserves numeric/currency values during translation
  /// - Uses placeholders to maintain formatting
  /// - Falls back to original text on error
  Future<String> translateText(String text, String targetLanguage) async {
    try {
      // Skip translation if text is empty or target language is English
      if (text.isEmpty || targetLanguage == 'en') {
        return text;
      }

      // Check if the text contains only numbers and/or symbols
      if (RegExp(r'^[0-9₹$€£¥%.,\- ]+$').hasMatch(text)) {
        debugPrint(
            'PDF Translator: Skipping translation for numeric/symbol content: "$text"');
        return text; // Don't translate numbers and symbols
      }

      // Extract numeric parts to preserve during translation
      final RegExp numericPattern = RegExp(r'(₹[0-9,.]+|\d+(\.\d+)?)');
      final matches = numericPattern.allMatches(text).toList();

      // Replace numeric parts with placeholders for translation
      String textToTranslate = text;
      List<String> numericParts = [];

      for (int i = 0; i < matches.length; i++) {
        final match = matches[i];
        final numericPart = match.group(0)!;
        numericParts.add(numericPart);
        textToTranslate =
            textToTranslate.replaceFirst(numericPart, '{{NUM_$i}}');
      }

      // Log translation request for debugging
      debugPrint(
          'PDF Translator: Translating "$textToTranslate" to $targetLanguage');

      final response = await _translatorService.translate(
        text: textToTranslate,
        targetLanguage: targetLanguage,
        sourceLanguage: 'en', // Always assume English as source
      );

      // Extract the translated text from the response
      var translatedText = response['translated_text'] as String;

      // Restore numeric parts after translation
      for (int i = 0; i < numericParts.length; i++) {
        translatedText =
            translatedText.replaceFirst('{{NUM_$i}}', numericParts[i]);
      }

      debugPrint('PDF Translator: Result for "$text" => "$translatedText"');
      return translatedText;
    } catch (e) {
      // Log error and return original text if translation fails
      debugPrint('PDF Translator: Error translating "$text": $e');
      return text;
    }
  }

  /// Translates a list of texts to the target language
  Future<List<String>> translateTexts(
      List<String> texts, String targetLanguage) async {
    // Skip translation if target language is English
    if (targetLanguage == 'en') {
      return texts;
    }

    try {
      debugPrint(
          'PDF Translator: Translating ${texts.length} texts to $targetLanguage');

      // Use batch translation if available
      try {
        final responses = await _translatorService.batchTranslate(
          texts: texts,
          targetLanguage: targetLanguage,
          sourceLanguage: 'en',
        );

        return responses
            .map((resp) => resp['translated_text'] as String)
            .toList();
      } catch (batchError) {
        debugPrint(
            'PDF Translator: Batch translation failed, falling back to individual: $batchError');

        // Fall back to individual translation
        final translatedTexts = <String>[];
        for (final text in texts) {
          final translatedText = await translateText(text, targetLanguage);
          translatedTexts.add(translatedText);
        }
        return translatedTexts;
      }
    } catch (e) {
      // Log error and return original texts if translation fails
      debugPrint('PDF Translator: Error translating texts: $e');
      return texts;
    }
  }

  /// Translates a map of texts to the target language
  Future<Map<String, String>> translateMap(Map<String, String> texts) async {
    if (targetLanguage == 'en') {
      return texts; // No translation needed for English
    }

    try {
      debugPrint(
          'PDF Translator: Translating map with ${texts.length} entries');

      // First collect all the values that need translation
      final values = texts.values.toList();

      // Translate all values at once
      final translatedValues = await translateTexts(values, targetLanguage);

      // Rebuild the map with translated values
      final result = <String, String>{};
      int i = 0;
      for (final key in texts.keys) {
        result[key] = translatedValues[i];
        i++;
      }

      return result;
    } catch (e) {
      // Return original map if translation fails
      debugPrint('PDF Translator: Error translating map: $e');
      return texts;
    }
  }
}

/// Provider for creating a PdfTranslator instance
final pdfTranslatorProvider =
    Provider.family<PdfTranslator, String>((ref, targetLanguage) {
  final translatorService = ref.watch(provider.translatorServiceProvider);
  return PdfTranslator(
    targetLanguage: targetLanguage,
    translatorService: translatorService,
  );
});
