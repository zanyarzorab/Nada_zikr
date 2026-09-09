import 'package:hive/hive.dart';
import 'package:flutter/foundation.dart';
import '../models/azkar_model.dart';
import '../models/weekly_activity_model.dart';
import '../models/zikr_session.dart';
import 'quran_mood_service.dart';

class StorageService {
  static const String settingsBox = 'settings';
  static const String profileBox = 'profile';
  static const String statsBox = 'statistics';
  static const String favoriteMoodCardsKey = 'favoriteMoodCards';
  static final ValueNotifier<int> dailyPathChanges = ValueNotifier<int>(0);

  static Future<void> initialize() async {
    await Hive.openBox(settingsBox);
    await Hive.openBox(profileBox);
    await Hive.openBox(statsBox);
  }

  static Future<bool> isFirstLaunch() async {
    final box = Hive.box(settingsBox);
    return box.get('is_first_launch', defaultValue: true);
  }

  static Future<void> setFirstLaunchCompleted() async {
    final box = Hive.box(settingsBox);
    await box.put('is_first_launch', false);
  }

  // User Profile Management
  static Future<void> saveUserProfile(UserProfile profile) async {
    final box = Hive.box(profileBox);
    await box.put('name', profile.name);
    await box.put('dailyGoal', profile.dailyGoal);
    await box.put('currentStreak', profile.currentStreak);
    await box.put('bestStreak', profile.bestStreak);
    await box.put('totalSessions', profile.totalSessions);
    await box.put('lastSessionDate', profile.lastSessionDate.toIso8601String());
  }

  static Future<UserProfile> getUserProfile() async {
    final box = Hive.box(profileBox);
    final rawName = box.get('name', defaultValue: '') as String?;
    final name = (rawName == null || rawName == 'Beloved' || rawName == 'موسڵمان')
        ? ''
        : rawName;

    return UserProfile(
      name: name,
      dailyGoal: box.get('dailyGoal', defaultValue: 3),
      currentStreak: box.get('currentStreak', defaultValue: 0),
      bestStreak: box.get('bestStreak', defaultValue: 0),
      totalSessions: box.get('totalSessions', defaultValue: 0),
      lastSessionDate: DateTime.parse(
        box.get('lastSessionDate',
            defaultValue: DateTime.now().toIso8601String()),
      ),
    );
  }

  static Future<void> _safeBoxPut(Box box, dynamic key, dynamic value) async {
    try {
      await box.put(key, value).timeout(const Duration(milliseconds: 15));
    } catch (_) {}
  }

  static Future<void> _safeBoxDelete(Box box, dynamic key) async {
    try {
      await box.delete(key).timeout(const Duration(milliseconds: 15));
    } catch (_) {}
  }

  // Settings
  static Future<void> saveSetting(String key, dynamic value) async {
    final box = Hive.box(settingsBox);
    await _safeBoxPut(box, key, value);
  }

  static Future<dynamic> readSetting(String key, {dynamic defaultValue}) async {
    final box = Hive.box(settingsBox);
    return box.get(key, defaultValue: defaultValue);
  }

  static bool isHapticEnabled() {
    try {
      final box = Hive.box(settingsBox);
      return box.get('haptic', defaultValue: true) as bool? ?? true;
    } catch (_) {
      return true;
    }
  }

  static bool isNotificationsEnabled() {
    try {
      final box = Hive.box(settingsBox);
      return box.get('notifications', defaultValue: true) as bool? ?? true;
    } catch (_) {
      return true;
    }
  }

  static String _dailyPathKey(DateTime date) =>
      'daily_path_${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  static Map<String, bool> getDailyPathCompletion({DateTime? date}) {
    final raw =
        Hive.box(settingsBox).get(_dailyPathKey(date ?? DateTime.now()));
    if (raw is! Map) return {};
    return raw.map((key, value) => MapEntry(key.toString(), value == true));
  }

  static Future<void> markDailyPathComplete(String stepId,
      {DateTime? date}) async {
    final box = Hive.box(settingsBox);
    final key = _dailyPathKey(date ?? DateTime.now());
    final completion = getDailyPathCompletion(date: date);
    completion[stepId] = true;
    await box.put(key, completion);
    dailyPathChanges.value++;
  }

  // Quran Last Read Bookmark
  static Future<void> saveLastReadSurah({
    required int surahNumber,
    required String surahNameAr,
    required String surahNameKu,
    required String surahNameEn,
    int ayahNumber = 1,
  }) async {
    final box = Hive.box(settingsBox);
    await box.put('last_read_surah', {
      'surahNumber': surahNumber,
      'surahNameAr': surahNameAr,
      'surahNameKu': surahNameKu,
      'surahNameEn': surahNameEn,
      'ayahNumber': ayahNumber,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  static Future<Map<String, dynamic>?> getLastReadSurah() async {
    final box = Hive.box(settingsBox);
    final raw = box.get('last_read_surah');
    if (raw is Map) {
      return Map<String, dynamic>.from(raw);
    }
    return null;
  }

  static Future<void> saveQuranAyahBookmark({
    required int surahNumber,
    required int ayahNumber,
    required String surahNameAr,
    required String surahNameKu,
    required String surahNameEn,
    String note = '',
  }) async {
    final box = Hive.box(settingsBox);
    final bookmarks = await getQuranAyahBookmarks();
    bookmarks.removeWhere((bookmark) =>
        bookmark['surahNumber'] == surahNumber &&
        bookmark['ayahNumber'] == ayahNumber);
    bookmarks.add({
      'surahNumber': surahNumber,
      'ayahNumber': ayahNumber,
      'surahNameAr': surahNameAr,
      'surahNameKu': surahNameKu,
      'surahNameEn': surahNameEn,
      'note': note,
      'timestamp': DateTime.now().toIso8601String(),
    });
    await _safeBoxPut(box, 'quran_ayah_bookmarks', bookmarks);
    await _safeBoxDelete(box, 'quran_ayah_bookmark');
  }

  static Future<List<Map<String, dynamic>>> getQuranAyahBookmarks() async {
    final box = Hive.box(settingsBox);
    final raw =
        box.get('quran_ayah_bookmarks') ?? box.get('quran_ayah_bookmark');
    if (raw is List) {
      return raw
          .whereType<Map>()
          .map((bookmark) => Map<String, dynamic>.from(bookmark))
          .toList();
    }
    if (raw is Map) return [Map<String, dynamic>.from(raw)];
    return [];
  }

  static Future<void> removeQuranAyahBookmark({
    required int surahNumber,
    required int ayahNumber,
  }) async {
    final box = Hive.box(settingsBox);
    final bookmarks = await getQuranAyahBookmarks();
    bookmarks.removeWhere((bookmark) =>
        bookmark['surahNumber'] == surahNumber &&
        bookmark['ayahNumber'] == ayahNumber);
    await _safeBoxPut(box, 'quran_ayah_bookmarks', bookmarks);
    await _safeBoxDelete(box, 'quran_ayah_bookmark');
  }

  // Quran Audio Position (resume listening)
  static Future<void> saveAudioPosition({
    required int surahNumber,
    required String reciterId,
    required double positionSeconds,
  }) async {
    final box = Hive.box(settingsBox);
    await box.put('audio_pos_${surahNumber}_$reciterId', positionSeconds);
  }

  static Future<double?> getAudioPosition({
    required int surahNumber,
    required String reciterId,
  }) async {
    final box = Hive.box(settingsBox);
    final val = box.get('audio_pos_${surahNumber}_$reciterId');
    if (val is num) return val.toDouble();
    return null;
  }

  static Future<void> clearAudioPosition({
    required int surahNumber,
    required String reciterId,
  }) async {
    final box = Hive.box(settingsBox);
    await box.delete('audio_pos_${surahNumber}_$reciterId');
  }

  static const Set<String> _validAzanSoundIds = {
    'makkah',
    'haram_classic',
    'madinah',
    'aqsa',
    'abdulbasit',
    'mishary',
    'riyadh',
    'dubai',
    'azan_short',
    'azan_fajr',
    'vibrate',
    'silent',
  };

  static String normalizeAzanSoundId(String? soundId) {
    final normalized = soundId?.trim().toLowerCase() ?? 'makkah';
    if (_validAzanSoundIds.contains(normalized)) {
      return normalized;
    }
    return 'makkah';
  }

  // Azan Sound Preference
  static Future<void> saveAzanSound(String soundId) async {
    final box = Hive.box(settingsBox);
    final safeSoundId = normalizeAzanSoundId(soundId);
    await box.put('azan_sound', safeSoundId);
  }

  static Future<String> getAzanSound() async {
    final box = Hive.box(settingsBox);
    final storedValue = box.get('azan_sound', defaultValue: 'makkah');
    return normalizeAzanSoundId(storedValue?.toString());
  }

  // Prayer Settings & Preferences
  static const String keyPrayerMethod = 'prayer_method';
  static const String keyPrayerAsrSchool = 'prayer_asr_school';
  static const String keyPrayerHighLatRule = 'prayer_high_lat_rule';
  static const String keyPrayerLocationMode = 'prayer_location_mode';
  static const String keyPrayerSelectedCity = 'prayer_selected_city';
  static const String keyPrayerCustomLat = 'prayer_custom_lat';
  static const String keyPrayerCustomLng = 'prayer_custom_lng';
  static const String keyPrayerMinuteOffsets = 'prayer_minute_offsets';
  static const String keyPrayerNotifications = 'prayer_notifications';

  static String getPrayerMethod() {
    return Hive.box(settingsBox)
        .get(keyPrayerMethod, defaultValue: 'kurdistan_endowments');
  }

  static Future<void> savePrayerMethod(String methodId) async {
    await Hive.box(settingsBox).put(keyPrayerMethod, methodId);
  }

  static String getPrayerAsrSchool() {
    return Hive.box(settingsBox).get(keyPrayerAsrSchool, defaultValue: 'shafi');
  }

  static Future<void> savePrayerAsrSchool(String school) async {
    await Hive.box(settingsBox).put(keyPrayerAsrSchool, school);
  }

  static String getPrayerHighLatRule() {
    return Hive.box(settingsBox)
        .get(keyPrayerHighLatRule, defaultValue: 'night_middle');
  }

  static Future<void> savePrayerHighLatRule(String rule) async {
    await Hive.box(settingsBox).put(keyPrayerHighLatRule, rule);
  }

  static String getPrayerLocationMode() {
    return Hive.box(settingsBox)
        .get(keyPrayerLocationMode, defaultValue: 'gps');
  }

  static Future<void> savePrayerLocationMode(String mode) async {
    await Hive.box(settingsBox).put(keyPrayerLocationMode, mode);
  }

  static String getPrayerSelectedCity() {
    return Hive.box(settingsBox)
        .get(keyPrayerSelectedCity, defaultValue: 'Hawler');
  }

  static Future<void> savePrayerSelectedCity(String city) async {
    await Hive.box(settingsBox).put(keyPrayerSelectedCity, city);
  }

  static double? getPrayerCustomLat() {
    final v = Hive.box(settingsBox).get(keyPrayerCustomLat);
    return (v is num) ? v.toDouble() : null;
  }

  static double? getPrayerCustomLng() {
    final v = Hive.box(settingsBox).get(keyPrayerCustomLng);
    return (v is num) ? v.toDouble() : null;
  }

  static List<double>? getPrayerCustomCoordinates() {
    final lat = getPrayerCustomLat();
    final lng = getPrayerCustomLng();
    if (lat != null && lng != null) {
      return [lat, lng];
    }
    return null;
  }

  static Future<void> savePrayerCustomCoordinates(
      double lat, double lng) async {
    final box = Hive.box(settingsBox);
    await box.put(keyPrayerCustomLat, lat);
    await box.put(keyPrayerCustomLng, lng);
  }

  static Map<String, int> getPrayerMinuteOffsets() {
    final box = Hive.box(settingsBox);
    final raw = box.get(keyPrayerMinuteOffsets);
    if (raw is Map) {
      final result = <String, int>{};
      for (final entry in raw.entries) {
        if (entry.key is String && entry.value is num) {
          result[entry.key as String] = (entry.value as num).toInt();
        }
      }
      return result;
    }
    return const {};
  }

  static Future<void> savePrayerMinuteOffsets(Map<String, int> offsets) async {
    await Hive.box(settingsBox).put(keyPrayerMinuteOffsets, offsets);
  }

  static Map<String, bool> getPrayerNotifications() {
    final box = Hive.box(settingsBox);
    final raw = box.get(keyPrayerNotifications);
    if (raw is Map) {
      final result = <String, bool>{};
      for (final entry in raw.entries) {
        if (entry.key is String && entry.value is bool) {
          result[entry.key as String] = entry.value as bool;
        }
      }
      return result;
    }
    return <String, bool>{
      'fajr': true,
      'sunrise': false,
      'dhuhr': true,
      'asr': true,
      'maghrib': true,
      'isha': true,
    };
  }

  static Future<void> savePrayerNotifications(Map<String, bool> notifs) async {
    await Hive.box(settingsBox).put(keyPrayerNotifications, notifs);
  }

  static Future<void> savePrayerNotificationToggle(
      String prayerId, bool enabled) async {
    final notifs = Map<String, bool>.from(getPrayerNotifications());
    notifs[prayerId] = enabled;
    await savePrayerNotifications(notifs);
  }

  static const String keyPrayerNotificationModes = 'prayer_notification_modes';

  static Map<String, String> getPrayerNotificationModes() {
    final box = Hive.box(settingsBox);
    final raw = box.get(keyPrayerNotificationModes);
    final result = <String, String>{};
    if (raw is Map) {
      for (final entry in raw.entries) {
        if (entry.key is String && entry.value is String) {
          final mode = entry.value as String;
          if (mode == 'azan' || mode == 'silent' || mode == 'vibrate') {
            result[entry.key as String] = mode;
          }
        }
      }
    }

    final enabled = getPrayerNotifications();
    for (final prayerId in const [
      'fajr',
      'sunrise',
      'dhuhr',
      'asr',
      'maghrib',
      'isha',
    ]) {
      result.putIfAbsent(
        prayerId,
        () => enabled[prayerId] == false ? 'silent' : 'azan',
      );
    }
    return result;
  }

  static Future<void> savePrayerNotificationMode(
      String prayerId, String mode) async {
    if (mode != 'azan' && mode != 'silent' && mode != 'vibrate') return;
    final modes = Map<String, String>.from(getPrayerNotificationModes());
    modes[prayerId] = mode;
    await Hive.box(settingsBox).put(keyPrayerNotificationModes, modes);
    await savePrayerNotificationToggle(prayerId, mode != 'silent');
  }

  // Prayer Hijri Offset, Pre-Azan Reminder & Fajr Custom Sound
  static const String keyPrayerHijriOffset = 'prayer_hijri_offset';
  static const String keyPreAzanReminderMinutes = 'pre_azan_reminder_minutes';
  static const String keyFajrAzanSound = 'fajr_azan_sound';

  static int getPrayerHijriOffset() {
    final val = Hive.box(settingsBox).get(keyPrayerHijriOffset, defaultValue: 0);
    if (val is int) {
      return val.clamp(-2, 2);
    }
    return 0;
  }

  static Future<void> savePrayerHijriOffset(int offset) async {
    await Hive.box(settingsBox).put(keyPrayerHijriOffset, offset.clamp(-2, 2));
  }

  static int getPreAzanReminderMinutes() {
    final val = Hive.box(settingsBox).get(keyPreAzanReminderMinutes, defaultValue: 0);
    if (val is int) {
      return val.clamp(0, 60);
    }
    return 0;
  }

  static Future<void> savePreAzanReminderMinutes(int minutes) async {
    await Hive.box(settingsBox).put(keyPreAzanReminderMinutes, minutes.clamp(0, 60));
  }

  static String getFajrAzanSound() {
    final val = Hive.box(settingsBox).get(keyFajrAzanSound, defaultValue: 'azan_fajr');
    return val?.toString() ?? 'azan_fajr';
  }

  static Future<void> saveFajrAzanSound(String soundId) async {
    await Hive.box(settingsBox).put(keyFajrAzanSound, soundId);
  }

  // Preferred Quran Tafsir & Reciter
  static const String keyPreferredTafsir = 'preferred_quran_tafsir';
  static const String keyPreferredReciter = 'selected_reciter_id';

  static String getPreferredTafsir() {
    return Hive.box(settingsBox)
        .get(keyPreferredTafsir, defaultValue: 'asan')
        ?.toString() ?? 'asan';
  }

  static Future<void> savePreferredTafsir(String tafsirId) async {
    await Hive.box(settingsBox).put(keyPreferredTafsir, tafsirId);
  }

  static String getPreferredReciter() {
    return Hive.box(settingsBox)
        .get(keyPreferredReciter, defaultValue: 'raad_kurdi')
        ?.toString() ?? 'raad_kurdi';
  }

  static Future<void> savePreferredReciter(String reciterId) async {
    await Hive.box(settingsBox).put(keyPreferredReciter, reciterId);
  }

  // Statistics
  static Future<void> saveStatistics(AppStatistics stats) async {
    final box = Hive.box(statsBox);
    await box.put('currentStreak', stats.currentStreak);
    await box.put('bestStreak', stats.bestStreak);
    await box.put('totalSessions', stats.totalSessions);
    await box.put('heatmapData', stats.heatmapData);
  }

  static Future<AppStatistics> getStatistics() async {
    final box = Hive.box(statsBox);
    final rawHistory = box.get('history', defaultValue: []);
    final historyList = <Map<String, dynamic>>[];
    if (rawHistory is List) {
      for (final e in rawHistory) {
        if (e is Map) {
          historyList.add(Map<String, dynamic>.from(e));
        }
      }
    }

    final heatmap = historyList.isEmpty
        ? List<int>.from(
            box.get('heatmapData',
                defaultValue: List.generate(84, (i) {
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
                })),
          )
        : _computeRealHeatmap(historyList);

    return AppStatistics(
      currentStreak: box.get('currentStreak', defaultValue: 0),
      bestStreak: box.get('bestStreak', defaultValue: 0),
      totalSessions: box.get('totalSessions', defaultValue: 0),
      heatmapData: heatmap,
    );
  }

  static List<int> _computeRealHeatmap(List<Map<String, dynamic>> history) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dayCounts = <int, int>{};

    for (final item in history) {
      final dateStr = item['date'] as String?;
      if (dateStr == null) continue;
      final date = DateTime.parse(dateStr);
      final day = DateTime(date.year, date.month, date.day);
      final diff = today.difference(day).inDays;
      if (diff >= 0 && diff < 84) {
        final cnt = (item['count'] as num?)?.toInt() ?? 1;
        dayCounts[diff] = (dayCounts[diff] ?? 0) + cnt;
      }
    }

    return List.generate(84, (i) {
      final daysAgo = 83 - i;
      final count = dayCounts[daysAgo] ?? 0;
      if (count == 0) return 0;
      if (count < 5) return 1;
      if (count < 20) return 2;
      if (count < 50) return 3;
      return 4;
    });
  }

  static Future<WeeklyActivityReport> getWeeklyActivityReport({
    bool startOnSaturday = true,
  }) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final int daysAgo;
    if (startOnSaturday) {
      daysAgo = (now.weekday % 7 + 1) % 7;
    } else {
      daysAgo = now.weekday - 1;
    }

    final weekStart = today.subtract(Duration(days: daysAgo));
    final sessions = await readSessions();

    final List<DailyActivitySummary> days = [];
    int totalCount = 0;
    int totalSessions = 0;
    int activeDaysCount = 0;
    int maxDayCount = 0;
    int bestDayIndex = 0;

    final List<Map<String, String>> dayDefinitions = startOnSaturday
        ? const [
            {
              'nameKu': 'شەممە',
              'nameAr': 'السبت',
              'nameEn': 'Saturday',
              'shortKu': 'شەم',
              'shortAr': 'سبت',
              'shortEn': 'Sat',
            },
            {
              'nameKu': 'یەکشەممە',
              'nameAr': 'الأحد',
              'nameEn': 'Sunday',
              'shortKu': 'یەک',
              'shortAr': 'أحد',
              'shortEn': 'Sun',
            },
            {
              'nameKu': 'دووشەممە',
              'nameAr': 'الإثنين',
              'nameEn': 'Monday',
              'shortKu': 'دوو',
              'shortAr': 'إثنين',
              'shortEn': 'Mon',
            },
            {
              'nameKu': 'سێشەممە',
              'nameAr': 'الثلاثاء',
              'nameEn': 'Tuesday',
              'shortKu': 'سێ',
              'shortAr': 'ثلاثاء',
              'shortEn': 'Tue',
            },
            {
              'nameKu': 'چوارشەممە',
              'nameAr': 'الأربعاء',
              'nameEn': 'Wednesday',
              'shortKu': 'چوار',
              'shortAr': 'أربعاء',
              'shortEn': 'Wed',
            },
            {
              'nameKu': 'پێنجشەممە',
              'nameAr': 'الخميس',
              'nameEn': 'Thursday',
              'shortKu': 'پێنج',
              'shortAr': 'خميس',
              'shortEn': 'Thu',
            },
            {
              'nameKu': 'هەینی',
              'nameAr': 'الجمعة',
              'nameEn': 'Friday',
              'shortKu': 'هەینی',
              'shortAr': 'جمعة',
              'shortEn': 'Fri',
            },
          ]
        : const [
            {
              'nameKu': 'دووشەممە',
              'nameAr': 'الإثنين',
              'nameEn': 'Monday',
              'shortKu': 'دوو',
              'shortAr': 'إثنين',
              'shortEn': 'Mon',
            },
            {
              'nameKu': 'سێشەممە',
              'nameAr': 'الثلاثاء',
              'nameEn': 'Tuesday',
              'shortKu': 'سێ',
              'shortAr': 'ثلاثاء',
              'shortEn': 'Tue',
            },
            {
              'nameKu': 'چوارشەممە',
              'nameAr': 'الأربعاء',
              'nameEn': 'Wednesday',
              'shortKu': 'چوار',
              'shortAr': 'أربعاء',
              'shortEn': 'Wed',
            },
            {
              'nameKu': 'پێنجشەممە',
              'nameAr': 'الخميس',
              'nameEn': 'Thursday',
              'shortKu': 'پێنج',
              'shortAr': 'خميس',
              'shortEn': 'Thu',
            },
            {
              'nameKu': 'هەینی',
              'nameAr': 'الجمعة',
              'nameEn': 'Friday',
              'shortKu': 'هەینی',
              'shortAr': 'جمعة',
              'shortEn': 'Fri',
            },
            {
              'nameKu': 'شەممە',
              'nameAr': 'السبت',
              'nameEn': 'Saturday',
              'shortKu': 'شەم',
              'shortAr': 'سبت',
              'shortEn': 'Sat',
            },
            {
              'nameKu': 'یەکشەممە',
              'nameAr': 'الأحد',
              'nameEn': 'Sunday',
              'shortKu': 'یەک',
              'shortAr': 'أحد',
              'shortEn': 'Sun',
            },
          ];

    for (int i = 0; i < 7; i++) {
      final dayDate = weekStart.add(Duration(days: i));
      final isToday = dayDate.year == today.year &&
          dayDate.month == today.month &&
          dayDate.day == today.day;
      final isFuture = dayDate.isAfter(today);

      final daySessions = sessions.where((s) {
        final d = s.timestamp;
        return d.year == dayDate.year &&
            d.month == dayDate.month &&
            d.day == dayDate.day;
      }).toList();

      int dayCount = 0;
      final Map<String, int> zikrFrequencies = {};
      for (final s in daySessions) {
        dayCount += s.count;
        zikrFrequencies[s.itemId] = (zikrFrequencies[s.itemId] ?? 0) + s.count;
      }

      final sortedZikrs = zikrFrequencies.keys.toList()
        ..sort((a, b) =>
            (zikrFrequencies[b] ?? 0).compareTo(zikrFrequencies[a] ?? 0));
      final topZikrs = sortedZikrs.take(3).toList();

      if (dayCount > 0) {
        activeDaysCount++;
      }
      totalCount += dayCount;
      totalSessions += daySessions.length;

      if (dayCount > maxDayCount) {
        maxDayCount = dayCount;
        bestDayIndex = i;
      }

      final def = dayDefinitions[i];
      days.add(DailyActivitySummary(
        date: dayDate,
        dayNameKu: def['nameKu']!,
        dayNameAr: def['nameAr']!,
        dayNameEn: def['nameEn']!,
        dayShortKu: def['shortKu']!,
        dayShortAr: def['shortAr']!,
        dayShortEn: def['shortEn']!,
        totalCount: dayCount,
        sessionsCount: daySessions.length,
        isToday: isToday,
        isFuture: isFuture,
        topZikrs: topZikrs,
      ));
    }

    final double dailyAverage = totalCount > 0
        ? (totalCount / (daysAgo + 1)).clamp(0.0, totalCount.toDouble())
        : 0.0;
    final int consistencyPercent = ((activeDaysCount / 7.0) * 100).round();

    final bestDayDef = dayDefinitions[bestDayIndex];

    return WeeklyActivityReport(
      days: days,
      totalCount: totalCount,
      totalSessions: totalSessions,
      activeDaysCount: activeDaysCount,
      dailyAverage: dailyAverage,
      maxDayCount: maxDayCount,
      bestDayIndex: bestDayIndex,
      bestDayNameKu: bestDayDef['nameKu']!,
      bestDayNameAr: bestDayDef['nameAr']!,
      bestDayNameEn: bestDayDef['nameEn']!,
      consistencyPercent: consistencyPercent,
    );
  }

  static Future<List<int>> getWeeklyActivityCounts({
    bool startOnSaturday = true,
  }) async {
    final report =
        await getWeeklyActivityReport(startOnSaturday: startOnSaturday);
    return report.days.map((d) => d.totalCount).toList();
  }

  static Future<List<ZikrSession>> readSessions() async {
    final box = Hive.box(statsBox);
    final raw = box.get('history', defaultValue: []);
    if (raw is List) {
      final list = <ZikrSession>[];
      for (final item in raw) {
        if (item is Map) {
          final map = Map<String, dynamic>.from(item);
          list.add(ZikrSession.fromMap(map));
        }
      }
      return list;
    }
    return <ZikrSession>[];
  }

  static Future<Map<String, int>> readAllZikr() async {
    final box = Hive.box(statsBox);
    final raw = box.get('counts', defaultValue: <String, int>{});
    return Map<String, int>.from(raw);
  }

  static Future<List<Map<String, dynamic>>> readFavoriteMoodCards() async {
    final box = Hive.box(settingsBox);
    final raw =
        box.get(favoriteMoodCardsKey, defaultValue: <Map<String, dynamic>>[]);
    if (raw is List) {
      return raw.map((item) => Map<String, dynamic>.from(item as Map)).toList();
    }
    return <Map<String, dynamic>>[];
  }

  static Future<void> saveFavoriteMoodCards(
      List<Map<String, dynamic>> cards) async {
    final box = Hive.box(settingsBox);
    await _safeBoxPut(box, favoriteMoodCardsKey, cards);
  }

  static String getCardId(Map<String, dynamic> card) {
    if (card['id'] != null && card['id'].toString().isNotEmpty) {
      return card['id'].toString();
    }
    final moodId = card['moodId'] ?? '';
    final title = card['title'] ?? card['arabicText'] ?? '';
    final type = card['cardType'] ?? 'card';
    return '${type}_${moodId}_$title';
  }

  static Future<bool> isFavoriteMoodCard(QuranMoodSuggestion suggestion) async {
    final cards = await readFavoriteMoodCards();
    return cards.any((card) => card['moodId'] == suggestion.moodId);
  }

  static Future<bool> isGenericCardSaved(Map<String, dynamic> cardData) async {
    final cards = await readFavoriteMoodCards();
    final targetId = getCardId(cardData);
    return cards.any((c) => getCardId(c) == targetId);
  }

  static Future<bool> toggleGenericCard(Map<String, dynamic> cardData) async {
    final cards = await readFavoriteMoodCards();
    final targetId = getCardId(cardData);
    final index = cards.indexWhere((c) => getCardId(c) == targetId);
    if (index >= 0) {
      cards.removeAt(index);
      await saveFavoriteMoodCards(cards);
      return false; // Now unsaved
    } else {
      final payload = Map<String, dynamic>.from(cardData);
      payload['createdAt'] ??= DateTime.now().toIso8601String();
      payload['schemaVersion'] ??= 2;
      cards.add(payload);
      await saveFavoriteMoodCards(cards);
      return true; // Now saved
    }
  }

  static Future<bool> toggleFavoriteMoodCard(
      QuranMoodSuggestion suggestion) async {
    final cards = await readFavoriteMoodCards();
    final index =
        cards.indexWhere((card) => card['moodId'] == suggestion.moodId);
    if (index >= 0) {
      cards.removeAt(index);
      await saveFavoriteMoodCards(cards);
      return false; // Now unsaved
    } else {
      final payload = {
        'schemaVersion': 2,
        'tafsirId': 'asan',
        'moodId': suggestion.moodId,
        'title': suggestion.title,
        'shortMessage': suggestion.shortMessage,
        'createdAt': DateTime.now().toIso8601String(),
        'verses': suggestion.verses
            .map((verse) => {
                  'surah': verse.surah,
                  'ayah': verse.ayah,
                  'arabicText': verse.arabicText,
                  'englishMeaning': verse.englishMeaning,
                  'kurdishMeaning': verse.kurdishMeaning,
                  'reflection': verse.reflection,
                })
            .toList(),
      };
      cards.add(payload);
      await saveFavoriteMoodCards(cards);
      return true; // Now saved
    }
  }

  static Future<void> saveFavoriteMoodCard(
      QuranMoodSuggestion suggestion) async {
    final isSaved = await isFavoriteMoodCard(suggestion);
    if (!isSaved) {
      await toggleFavoriteMoodCard(suggestion);
    }
  }

  static Future<void> deleteFavoriteMoodCard(int index) async {
    final cards = await readFavoriteMoodCards();
    if (index < 0 || index >= cards.length) return;
    cards.removeAt(index);
    await saveFavoriteMoodCards(cards);
  }

  static Future<void> insertFavoriteMoodCardAt(
      int index, Map<String, dynamic> card) async {
    final cards = await readFavoriteMoodCards();
    if (index <= 0) {
      cards.insert(0, card);
    } else if (index >= cards.length) {
      cards.add(card);
    } else {
      cards.insert(index, card);
    }
    await saveFavoriteMoodCards(cards);
  }

  static Future<void> clearAllFavoriteMoodCards() async {
    final box = Hive.box(settingsBox);
    await box.put(favoriteMoodCardsKey, <Map<String, dynamic>>[]);
  }

  static Future<void> saveZikrCounts(Map<String, int> counts) async {
    final box = Hive.box(statsBox);
    await box.put('counts', counts);
  }

  static Future<void> incrementZikrCount(
      {required String zikrKey, int count = 1}) async {
    final raw = await readAllZikr();
    final Map<String, int> counts = Map<String, int>.from(raw);
    counts[zikrKey] = (counts[zikrKey] ?? 0) + count;
    await saveZikrCounts(counts);

    // Save history entry for weekly bar chart and heatmap
    final box = Hive.box(statsBox);
    final rawHistory =
        box.get('history', defaultValue: <Map<String, dynamic>>[]);
    final historyList = List<Map<String, dynamic>>.from(
      (rawHistory as List).map((e) => Map<String, dynamic>.from(e as Map)),
    );
    historyList.add({
      'title': zikrKey,
      'count': count,
      'date': DateTime.now().toIso8601String(),
    });
    await box.put('history', historyList);

    final heatmap = _computeRealHeatmap(historyList);
    final stats = await getStatistics();
    await saveStatistics(AppStatistics(
      currentStreak: stats.currentStreak,
      bestStreak: stats.bestStreak,
      totalSessions: stats.totalSessions,
      heatmapData: heatmap,
    ));
  }

  static int calculateNextStreak(UserProfile profile, DateTime currentDate) {
    final today =
        DateTime(currentDate.year, currentDate.month, currentDate.day);
    final last = DateTime(
      profile.lastSessionDate.year,
      profile.lastSessionDate.month,
      profile.lastSessionDate.day,
    );
    final yesterday = today.subtract(const Duration(days: 1));

    if (_isSameDate(last, today)) {
      return profile.currentStreak;
    }

    if (_isSameDate(last, yesterday)) {
      return profile.currentStreak + 1;
    }

    return 1;
  }

  static Future<void> recordSessionCompletion(
      {String title = 'Dhikr', int count = 1}) async {
    final stats = await getStatistics();
    final profile = await getUserProfile();
    final today = DateTime.now();

    final nextCurrentStreak = calculateNextStreak(profile, today);
    final nextBestStreak = nextCurrentStreak > profile.bestStreak
        ? nextCurrentStreak
        : profile.bestStreak;

    final updatedStats = AppStatistics(
      currentStreak: nextCurrentStreak,
      bestStreak: nextBestStreak,
      totalSessions: stats.totalSessions + 1,
      heatmapData: stats.heatmapData,
    );
    await saveStatistics(updatedStats);

    final updatedProfile = profile.copyWith(
      currentStreak: nextCurrentStreak,
      bestStreak: nextBestStreak,
      totalSessions: profile.totalSessions + 1,
      lastSessionDate: today,
    );
    await saveUserProfile(updatedProfile);
  }

  static bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static Future<void> saveSession(String title, int count) async {
    await recordSessionCompletion(title: title, count: count);
  }

  // Clear all data
  static Future<void> clearAllData() async {
    await Hive.box(settingsBox).clear();
    await Hive.box(profileBox).clear();
    await Hive.box(statsBox).clear();
  }
}
