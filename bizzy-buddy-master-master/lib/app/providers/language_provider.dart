import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_language.dart';

final supportedLanguagesProvider = Provider<List<AppLanguage>>((ref) {
  return [
    const AppLanguage(
      code: 'en',
      name: 'English',
      nativeName: 'English',
    ),
    const AppLanguage(
      code: 'es',
      name: 'Spanish',
      nativeName: 'Español',
    ),
    const AppLanguage(
      code: 'fr',
      name: 'French',
      nativeName: 'Français',
    ),
    const AppLanguage(
      code: 'de',
      name: 'German',
      nativeName: 'Deutsch',
    ),
    const AppLanguage(
      code: 'hi',
      name: 'Hindi',
      nativeName: 'हिन्दी',
    ),
    const AppLanguage(
      code: 'zh',
      name: 'Chinese',
      nativeName: '中文',
    ),
  ];
});

final selectedLanguageProvider = StateProvider<AppLanguage>((ref) {
  return ref.read(supportedLanguagesProvider).first;
});

class LanguageNotifier extends StateNotifier<AppLanguage> {
  LanguageNotifier()
      : super(const AppLanguage(
          code: 'en',
          name: 'English',
          nativeName: 'English',
        ));

  void setLanguage(AppLanguage language) {
    state = language;
  }
}

final languageProvider =
    StateNotifierProvider<LanguageNotifier, AppLanguage>((ref) {
  return LanguageNotifier();
});
