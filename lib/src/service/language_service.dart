import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:martfury/src/model/language.dart';
import 'package:martfury/src/service/base_service.dart';
import 'dart:ui' as ui;

class LanguageService extends BaseService {
  static const String selectedLanguageKey = 'selected_language';

  Future<List<Language>> getLanguages() async {
    try {
      final response = await get('/api/v1/languages');

      final List<dynamic> languagesList = response as List<dynamic>;
      return languagesList
          .map((language) => Language.fromJson(language))
          .toList();
    } catch (e) {
      throw Exception('Failed to connect to server: $e');
    }
  }

  static Future<void> saveSelectedLanguage(Language language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(selectedLanguageKey, jsonEncode(language.toJson()));
  }

  static Future<Language?> getSelectedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final languageJson = jsonDecode(
      prefs.getString(selectedLanguageKey) ?? '{}',
    );

    if (languageJson.isNotEmpty) {
      return Language(
        id: languageJson['id'],
        name: languageJson['name'],
        code: languageJson['code'],
        langLocale: languageJson['langLocale'] ?? '',
        flag: languageJson['flag'],
        isDefault: languageJson['isDefault'] ?? false,
        isRtl: languageJson['isRtl'] ?? false,
        order: languageJson['order'] ?? 0,
      );
    }
    return null;
  }

  /// Get the text direction based on the selected language
  static Future<ui.TextDirection> getTextDirection() async {
    final selectedLanguage = await getSelectedLanguage();
    return selectedLanguage?.isRtl == true
        ? ui.TextDirection.rtl
        : ui.TextDirection.ltr;
  }

  /// Check if the current language is RTL
  static Future<bool> isCurrentLanguageRtl() async {
    final selectedLanguage = await getSelectedLanguage();
    return selectedLanguage?.isRtl ?? false;
  }
}
