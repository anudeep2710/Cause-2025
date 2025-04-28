import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/translator_service.dart';

final translatorServiceProvider = Provider((ref) => TranslatorService());
