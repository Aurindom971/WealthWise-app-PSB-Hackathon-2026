import 'package:flutter/material.dart';
import '../services/local_db_service.dart';

class LanguageProvider extends ChangeNotifier {
  static final LanguageProvider instance = LanguageProvider._internal();
  LanguageProvider._internal();

  Locale _locale = const Locale('en');

  Locale get locale => _locale;
  String get languageCode => _locale.languageCode;

  static const List<Map<String, String>> supportedLanguages = [
    {'code': 'en', 'name': 'English'},
    {'code': 'hi', 'name': 'हिन्दी'},
    {'code': 'pa', 'name': 'ਪੰਜਾਬੀ'},
  ];

  Future<void> initialize() async {
    try {
      final settings = await LocalDbService.getSettings('app_language');
      if (settings != null && settings['code'] != null) {
        final code = settings['code'] as String;
        _locale = Locale(code);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error initializing language: $e');
    }
  }

  Future<void> setLanguage(String code) async {
    if (_locale.languageCode == code) return;
    _locale = Locale(code);
    notifyListeners();
    try {
      await LocalDbService.saveSettings('app_language', {'code': code});
    } catch (e) {
      debugPrint('Error saving language: $e');
    }
  }
}
