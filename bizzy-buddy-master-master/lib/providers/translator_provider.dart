import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/translator_service.dart';

/// Provider for the translator service
final translatorServiceProvider = Provider<TranslatorService>((ref) {
  return TranslatorService();
});
