import 'dart:convert';

import 'package:flutter/services.dart';

class PrayerTimesService {
  static const assetPath = 'node_modules/imanikurd-prayer/data/prayer_times.json';

  static Future<PrayerTimesCatalog> load() async {
    final raw = await rootBundle.loadString(assetPath);
    final decoded = json.decode(raw) as Map<String, dynamic>;
    final cities = <String, List<PrayerDay>>{};

    for (final entry in decoded.entries) {
      final records = (entry.value as List)
          .map((item) => PrayerDay.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList(growable: false);
      cities[entry.key] = records;
    }

    return PrayerTimesCatalog(cities);
  }
}

class PrayerTimesCatalog {
  final Map<String, List<PrayerDay>> cities;

  const PrayerTimesCatalog(this.cities);

  List<String> get cityNames => cities.keys.toList(growable: false);

  PrayerDay forDate(String city, DateTime date) {
    final records = cities[city] ?? cities.values.first;
    final key = '${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    return records.firstWhere(
      (item) => item.date == key,
      orElse: () => records.first,
    );
  }
}

class PrayerDay {
  final String date;
  final String fajr;
  final String sunrise;
  final String dhuhr;
  final String asr;
  final String maghrib;
  final String isha;

  const PrayerDay({
    required this.date,
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
  });

  factory PrayerDay.fromJson(Map<String, dynamic> json) {
    return PrayerDay(
      date: json['date']?.toString() ?? '01-01',
      fajr: json['fajr']?.toString() ?? '--:--',
      sunrise: json['sunrise']?.toString() ?? '--:--',
      dhuhr: json['dhuhr']?.toString() ?? '--:--',
      asr: json['asr']?.toString() ?? '--:--',
      maghrib: json['maghrib']?.toString() ?? '--:--',
      isha: json['isha']?.toString() ?? '--:--',
    );
  }
}
