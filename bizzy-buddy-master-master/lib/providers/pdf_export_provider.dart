import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/pdf_export.dart';
import '../utils/pdf_translator.dart';
import '../providers/translator_provider.dart' as provider;

final pdfTranslatorProvider =
    Provider.family<PdfTranslator, String>((ref, language) {
  final translatorService = ref.watch(provider.translatorServiceProvider);
  return PdfTranslator(
    targetLanguage: language,
    translatorService: translatorService,
  );
});

final pdfExportProvider = Provider.family<PdfExport, String>((ref, language) {
  return PdfExport();
});
