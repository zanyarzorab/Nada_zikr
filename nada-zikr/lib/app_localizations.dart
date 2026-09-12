import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppLocalizations {
  Locale locale;
  late Map<String, String> _localizedStrings;
  static String _languageCode = 'ku';
  static Map<String, String> _currentStrings = {};
  static final ValueNotifier<String> languageCodeNotifier =
      ValueNotifier<String>(_languageCode);

  AppLocalizations(this.locale);

  static void setLanguageCode(String languageCode) {
    if (!['en', 'ku', 'ar'].contains(languageCode)) return;
    _languageCode = languageCode;
    languageCodeNotifier.value = languageCode;
  }

  static String get languageCode => _languageCode;

  static String translateStatic(String key) {
    return _currentStrings[key] ?? _fallbackStrings[key] ?? key;
  }

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  Future<bool> load() async {
    final resolvedLanguageCode = _languageCode;
    locale = Locale(resolvedLanguageCode);

    final path = 'assets/lang/$resolvedLanguageCode.json';
    final jsonString = await rootBundle.loadString(path);
    final Map<String, dynamic> jsonMap = json.decode(jsonString);
    _localizedStrings = jsonMap.map((key, value) => MapEntry(key, value.toString()));
    _currentStrings = _localizedStrings;
    return true;
  }

  String translate(String key) {
    return _localizedStrings[key] ?? key;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const Map<String, String> _fallbackStrings = {
    'prayerNotificationTitle': 'Prayer time',
    'prayerNotificationBody': '{prayer} - {location}',
    'zikrReminderTitle': 'Zikr reminder',
    'zikrReminderBody': 'Take a moment for remembrance',
  };
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'ku', 'ar'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    final localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
