import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';
import '../app_localizations.dart';
import 'prayer_repository.dart';

/// Service for keeping Android & iOS Home Screen / Lock Screen widgets in sync
/// with real-time prayer schedules and countdowns.
class PrayerWidgetService {
  static const String appGroupId = 'group.com.nada.nadaZikrakanm';
  static const String androidWidgetProvider = 'PrayerTimesWidgetProvider';
  static const String iOSWidgetName = 'PrayerTimesWidget';

  static String resolveSharedPrayerValue(
    Map<String, dynamic> values, {
    required List<String> keys,
    required String fallback,
  }) {
    for (final key in keys) {
      final value = values[key];
      if (value is String && value.trim().isNotEmpty) {
        return value;
      }
    }
    return fallback;
  }

  /// Initializes App Group settings for iOS WidgetKit.
  /// Called every time before writing data to guarantee the group is always set.
  static Future<void> _ensureInit() async {
    try {
      if (!kIsWeb && (Platform.isIOS || Platform.isMacOS)) {
        await HomeWidget.setAppGroupId(appGroupId);
      }
    } catch (e) {
      debugPrint('PrayerWidgetService _ensureInit error: $e');
    }
  }

  /// Helper: save a string value.
  static Future<void> _save(String key, String value) async {
    try {
      await HomeWidget.saveWidgetData<String>(key, value);
    } catch (e) {
      debugPrint('PrayerWidgetService save($key) error: $e');
    }
  }

  /// Helper: save a double value.
  static Future<void> _saveDouble(String key, double value) async {
    try {
      await HomeWidget.saveWidgetData<double>(key, value);
    } catch (e) {
      debugPrint('PrayerWidgetService saveDouble($key) error: $e');
    }
  }

  /// Calculates a 0.0–1.0 progress fraction representing how far into the
  /// current prayer period we are (used by the iOS progress ring).
  static double _calcPrayerProgress(
    PrayerTimeItem? current,
    PrayerTimeItem? next,
  ) {
    if (current == null || next == null) return 0.0;
    final now = DateTime.now();
    final periodStart = current.time;
    final periodEnd = next.time;
    final totalMs = periodEnd.difference(periodStart).inMilliseconds;
    if (totalMs <= 0) return 0.0;
    final elapsedMs = now.difference(periodStart).inMilliseconds;
    return (elapsedMs / totalMs).clamp(0.0, 1.0);
  }

  /// Pushes the latest calculated prayer times to native Android and iOS widgets.
  static Future<void> updateWidgets({String? specificCityId}) async {
    try {
      // Always ensure the App Group is registered before writing anything
      await _ensureInit();

      final schedule = await PrayerRepository.getPrayerScheduleForDate(
        date: DateTime.now(),
      );

      final lang = AppLocalizations.languageCode;
      final isKurdish = lang == 'ku';
      final isArabic = lang == 'ar';

      final items = schedule['items'] as List<PrayerTimeItem>? ?? [];
      final cityName = isKurdish
          ? (schedule['locationNameKu'] as String? ??
              schedule['locationName'] as String? ??
              'کوردستان')
          : (isArabic
              ? (schedule['locationNameAr'] as String? ?? 'كردستان')
              : (schedule['locationNameEn'] as String? ??
                  schedule['locationName'] as String? ??
                  'Kurdistan'));
      final hijriInfo = schedule['hijriDate'] as HijriDateInfo?;

      // Find the next upcoming prayer (and the one before it, for progress)
      PrayerTimeItem? nextItem;
      PrayerTimeItem? currentItem; // prayer currently in progress (just before next)
      for (int i = 0; i < items.length; i++) {
        if (items[i].isNext) {
          nextItem = items[i];
          currentItem = i > 0 ? items[i - 1] : null;
          break;
        }
      }
      nextItem ??= items.isNotEmpty ? items.first : null;
      currentItem ??= items.length > 1 ? items[items.length - 1] : null;

      // Extract individual prayer times
      String fajr = '--:--';
      String sunrise = '--:--';
      String dhuhr = '--:--';
      String asr = '--:--';
      String maghrib = '--:--';
      String isha = '--:--';

      for (final item in items) {
        switch (item.id) {
          case 'fajr':
            fajr = item.formattedTime();
            break;
          case 'sunrise':
            sunrise = item.formattedTime();
            break;
          case 'dhuhr':
            dhuhr = item.formattedTime();
            break;
          case 'asr':
            asr = item.formattedTime();
            break;
          case 'maghrib':
            maghrib = item.formattedTime();
            break;
          case 'isha':
            isha = item.formattedTime();
            break;
        }
      }

      final nextPrayerName = nextItem?.localizedName(lang) ?? (isKurdish ? 'بانگ' : 'Prayer');
      final nextPrayerTime = nextItem?.formattedTime() ?? '--:--';
      final nextPrayerId = nextItem?.id ?? 'fajr';

      // Calculate time difference
      String remainingText = '';
      if (nextItem != null) {
        final diff = nextItem.time.difference(DateTime.now());
        if (diff.isNegative) {
          remainingText = isKurdish
              ? 'کاتی بانگە'
              : (isArabic ? 'حان وقت الأذان' : 'Prayer Time');
        } else {
          final hours = diff.inHours;
          final minutes = diff.inMinutes % 60;
          if (hours > 0) {
            remainingText = isKurdish
                ? '$hours کاتژمێر و $minutes خولەک ماوە'
                : (isArabic
                    ? 'باقي $hours ساعة و $minutes دقيقة'
                    : 'in $hours hrs $minutes mins');
          } else {
            remainingText = isKurdish
                ? '$minutes خولەک ماوە'
                : (isArabic ? 'باقي $minutes دقيقة' : 'in $minutes mins');
          }
        }
      }

      final hijriDateFormatted = hijriInfo != null
          ? '${hijriInfo.day} ${isKurdish ? hijriInfo.monthNameKu : (isArabic ? hijriInfo.monthNameAr : hijriInfo.monthNameEn)} ${hijriInfo.year}'
          : '';

      // Progress fraction for iOS ring (0.0 = just started, 1.0 = prayer arrived)
      final prayerProgress = _calcPrayerProgress(currentItem, nextItem);

      // ── Save all data (App Group set above for iOS) ──
      await _saveDouble('prayer_progress', prayerProgress);
      await _save('city_name', cityName);
      await _save('hijri_date', hijriDateFormatted);
      await _save('next_prayer_name', nextPrayerName);
      await _save('selected_prayer_name', nextPrayerName);
      await _save('current_prayer_name', nextPrayerName);
      await _save('next_prayer_time', nextPrayerTime);
      await _save('selected_prayer_time', nextPrayerTime);
      await _save('current_prayer_time', nextPrayerTime);
      await _save('next_prayer_remaining', remainingText);
      await _save('selected_prayer_remaining', remainingText);
      await _save('current_prayer_remaining', remainingText);
      await _save('next_prayer_id', nextPrayerId);
      await _save('selected_prayer_id', nextPrayerId);
      await _save('current_prayer_id', nextPrayerId);

      // Unix seconds of the next prayer — iOS widget reads this to compute
      // an always-accurate countdown at SwiftUI render time (never stale).
      if (nextItem != null) {
        await _saveDouble(
          'next_prayer_timestamp',
          nextItem.time.millisecondsSinceEpoch / 1000.0,
        );
      }

      await _save('fajr_time',    fajr);
      await _save('sunrise_time', sunrise);
      await _save('dhuhr_time',   dhuhr);
      await _save('asr_time',     asr);
      await _save('maghrib_time', maghrib);
      await _save('isha_time',    isha);

      // Boolean flags per prayer — lets Android/iOS trivially identify active cell
      for (final id in ['fajr', 'sunrise', 'dhuhr', 'asr', 'maghrib', 'isha']) {
        await _save('is_next_$id', (id == nextPrayerId) ? '1' : '0');
      }

      await _save('app_title', isKurdish ? 'نەدا' : 'Nada');
      await _save('lang', lang);

      // Trigger native widget refresh
      await HomeWidget.updateWidget(
        name: androidWidgetProvider,
        iOSName: iOSWidgetName,
      );
    } catch (e) {
      debugPrint('Error updating widgets in PrayerWidgetService: $e');
    }
  }
}
