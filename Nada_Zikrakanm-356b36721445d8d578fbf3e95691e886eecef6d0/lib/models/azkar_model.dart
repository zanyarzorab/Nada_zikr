import 'package:flutter/material.dart';

class Mood {
  final String id;
  final String label; // Arabic
  final String english;
  final String kurdish;
  final String emoji;

  Mood({
    required this.id,
    required this.label,
    required this.english,
    required this.kurdish,
    required this.emoji,
  });

  IconData get iconData {
    switch (id) {
      case 'grateful':
        return Icons.spa_rounded;
      case 'anxious':
        return Icons.cloud_rounded;
      case 'hopeful':
        return Icons.auto_awesome_rounded;
      case 'tired':
        return Icons.bedtime_rounded;
      case 'joyful':
        return Icons.sentiment_very_satisfied_rounded;
      case 'sad':
        return Icons.water_drop_rounded;
      default:
        return Icons.favorite_rounded;
    }
  }

  String getDisplay(String lang) {
    if (lang == 'ku') return kurdish;
    if (lang == 'en') return english;
    return label;
  }
}

class AzkarCategory {
  final String id;
  final String label; // Arabic
  final String english;
  final String kurdish;
  final String icon;
  final int count;
  final String color;

  AzkarCategory({
    required this.id,
    required this.label,
    required this.english,
    required this.kurdish,
    required this.icon,
    required this.count,
    required this.color,
  });

  IconData get iconData {
    switch (id) {
      case 'morning':
        return Icons.wb_sunny_rounded;
      case 'evening':
        return Icons.nights_stay_rounded;
      case 'sleep':
        return Icons.bedtime_rounded;
      case 'wakeup':
        return Icons.wb_twilight_rounded;
      case 'prayer':
        return Icons.mosque_rounded;
      case 'quran':
        return Icons.menu_book_rounded;
      case 'ayat_kursi':
        return Icons.verified_user_rounded;
      case 'surah_mulk':
        return Icons.stars_rounded;
      case 'surah_kahf':
        return Icons.auto_stories_rounded;
      case 'hadith':
        return Icons.format_quote_rounded;
      case 'general':
        return Icons.auto_awesome_rounded;
      default:
        return Icons.auto_stories_rounded;
    }
  }

  String getTitle(String lang) {
    if (lang == 'ku') return kurdish;
    if (lang == 'en') return english;
    return label;
  }
}

class Azkar {
  final int? id;
  final String arabic;
  final String translation; // English translation
  final String kurdishTranslation;
  final int repeat;
  final String source;

  Azkar({
    this.id,
    required this.arabic,
    required this.translation,
    required this.kurdishTranslation,
    required this.repeat,
    required this.source,
  });

  String get displayArabic {
    final sanitized = _stripRepeatSuffix(arabic);
    return sanitized.trim();
  }

  String get repeatLabel => repeat.toString();

  String getTranslation(String lang) {
    if (lang == 'ku') return kurdishTranslation;
    if (lang == 'ar') return kurdishTranslation;
    return translation.isNotEmpty ? translation : kurdishTranslation;
  }

  static String _stripRepeatSuffix(String value) {
    final normalized = value.trim();
    if (normalized.isEmpty) return normalized;

    final suffixPattern = RegExp(
      r'\s*\((?:[\p{L}\p{N}\s]+(?:\s+(?:مَرَّة|مرات|مرة|مرات|times|time|times\s*or|مرة واحدة|ثلاث|أربع|سبع|عشر|مائة|واحدة|مرتين|مرات\s*أو|مرة\s*واحدة|ثلاثة|أربعة|سبعة|عشرة|مائة|مئه|مئة|العدد))?)\)\s*$',
      unicode: true,
    );

    return normalized.replaceFirst(suffixPattern, '').trim();
  }
}

class NameOfAllah {
  final int id;
  final String arabic;
  final String transliteration;
  final String english;
  final String kurdish;

  NameOfAllah({
    required this.id,
    required this.arabic,
    this.transliteration = '',
    required this.english,
    required this.kurdish,
  });

  String getMeaning(String lang) {
    if (lang == 'ku') return kurdish;
    if (lang == 'ar') return arabic;
    return english;
  }
}

class UserProfile {
  final String name;
  final int dailyGoal;
  final int currentStreak;
  final int bestStreak;
  final int totalSessions;
  final DateTime lastSessionDate;

  UserProfile({
    required this.name,
    required this.dailyGoal,
    required this.currentStreak,
    required this.bestStreak,
    required this.totalSessions,
    required this.lastSessionDate,
  });

  UserProfile copyWith({
    String? name,
    int? dailyGoal,
    int? currentStreak,
    int? bestStreak,
    int? totalSessions,
    DateTime? lastSessionDate,
  }) {
    return UserProfile(
      name: name ?? this.name,
      dailyGoal: dailyGoal ?? this.dailyGoal,
      currentStreak: currentStreak ?? this.currentStreak,
      bestStreak: bestStreak ?? this.bestStreak,
      totalSessions: totalSessions ?? this.totalSessions,
      lastSessionDate: lastSessionDate ?? this.lastSessionDate,
    );
  }
}

class AppStatistics {
  final int currentStreak;
  final int bestStreak;
  final int totalSessions;
  final List<int> heatmapData;

  AppStatistics({
    required this.currentStreak,
    required this.bestStreak,
    required this.totalSessions,
    required this.heatmapData,
  });

  factory AppStatistics.initial() {
    return AppStatistics(
      currentStreak: 0,
      bestStreak: 0,
      totalSessions: 0,
      heatmapData: List.generate(84, (i) {
        final seed = (i * 7 + 13) % 17;
        return seed < 5
            ? 0
            : seed < 9
                ? 1
                : seed < 13
                    ? 2
                    : seed < 16
                        ? 3
                        : 4;
      }),
    );
  }
}
