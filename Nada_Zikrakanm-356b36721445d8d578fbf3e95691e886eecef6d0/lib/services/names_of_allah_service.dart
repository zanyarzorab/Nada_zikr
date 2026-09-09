import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/azkar_model.dart';
import '../models/app_data.dart';

class NamesOfAllahService {
  static final NamesOfAllahService _instance = NamesOfAllahService._internal();

  List<NameOfAllah>? _names;

  NamesOfAllahService._internal();

  factory NamesOfAllahService() {
    return _instance;
  }

  static NamesOfAllahService get instance {
    return _instance;
  }

  /// Load all 99 Names of Allah from imanikurd package with fallback to app data
  Future<List<NameOfAllah>> loadAllNames() async {
    try {
      final raw = await rootBundle.loadString('node_modules/imanikurd/data/names_of_allah.json');
      final data = json.decode(raw) as List<dynamic>;
      final names = <NameOfAllah>[];

      for (final item in data) {
        final map = item as Map<String, dynamic>;
        final id = int.tryParse(map['id'].toString());
        final arabic = map['arabic']?.toString().trim() ?? '';
        final english = map['english']?.toString().trim() ?? '';
        final kurdish = map['kurdish']?.toString().trim() ?? '';

        if (id == null || arabic.isEmpty || english.isEmpty || kurdish.isEmpty) {
          continue;
        }

        names.add(NameOfAllah(
          id: id,
          arabic: arabic,
          english: english,
          kurdish: kurdish,
          transliteration: map['transliteration']?.toString().trim() ?? '',
        ));
      }

      _names = names;
      return names;
    } on Exception {
      // Fallback to app data if package not available
      return AppData.namesOfAllah;
    }
  }

  /// Get a specific Name of Allah by ID
  Future<NameOfAllah?> getNameById(int id) async {
    if (_names == null) {
      await loadAllNames();
    }
    try {
      return _names!.firstWhere((name) => name.id == id);
    } on StateError {
      return null;
    }
  }

  /// Search Names of Allah by text in any language
  Future<List<NameOfAllah>> searchNames(String query) async {
    if (_names == null) {
      await loadAllNames();
    }
    final lowerQuery = query.toLowerCase();
    return _names!.where((name) {
      return name.arabic.contains(query) ||
          name.english.toLowerCase().contains(lowerQuery) ||
          name.kurdish.toLowerCase().contains(lowerQuery) ||
          name.transliteration.toLowerCase().contains(lowerQuery);
    }).toList();
  }
}
