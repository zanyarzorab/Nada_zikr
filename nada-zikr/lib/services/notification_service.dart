import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../app_localizations.dart';
import 'azan_audio_service.dart';
import 'prayer_repository.dart';
import 'storage_service.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const String channelVersion = 'prayer_alert_v10';

  static Future<void> initialize() async {
    tz_data.initializeTimeZones();
    try {
      final dynamic tzResult = await FlutterTimezone.getLocalTimezone();
      final String id = tzResult is String
          ? tzResult
          : (tzResult?.identifier ?? tzResult.toString());
      tz.setLocalLocation(tz.getLocation(id));
    } catch (_) {
      try {
        final now = DateTime.now();
        final offset = now.timeZoneOffset;
        final matching = tz.timeZoneDatabase.locations.values.where((loc) {
          final tzNow = tz.TZDateTime.now(loc);
          return tzNow.timeZoneOffset == offset;
        });
        if (matching.isNotEmpty) {
          tz.setLocalLocation(matching.first);
        } else {
          tz.setLocalLocation(tz.getLocation('Asia/Baghdad'));
        }
      } catch (_) {
        tz.setLocalLocation(tz.getLocation('Asia/Baghdad'));
      }
    }

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      defaultPresentAlert: true,
      defaultPresentBanner: true,
      defaultPresentSound: true,
      defaultPresentList: true,
      defaultPresentBadge: true,
    );
    const settings = InitializationSettings(android: android, iOS: ios);

    await _plugin.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: (details) async {},
    );

    // Request permissions explicitly on both Android and iOS
    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.requestNotificationsPermission();
    await androidPlugin?.requestExactAlarmsPermission();

    final iosPlugin = _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
    await iosPlugin?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );

    // Clean up legacy channels from older app versions
    if (androidPlugin != null) {
      try {
        final existingChannels = await androidPlugin.getNotificationChannels();
        if (existingChannels != null) {
          for (final ch in existingChannels) {
            if (ch.id.startsWith('prayer_alert_v8_') ||
                ch.id.startsWith('prayer_alert_v7_') ||
                ch.id.startsWith('prayer_alert_v6_') ||
                ch.id.startsWith('prayer_alert_v5_') ||
                ch.id.startsWith('prayer_alert_v4_') ||
                ch.id.startsWith('prayer_alert_v3_')) {
              await androidPlugin.deleteNotificationChannel(channelId: ch.id);
            }
          }
        }
      } catch (_) {}
    }
  }

  /// Checks if the application currently has permission to schedule exact notifications on Android.
  static Future<bool> canScheduleExactNotifications() async {
    try {
      final androidPlugin = _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin == null) return true; // iOS doesn't have exact alarm restriction
      return (await androidPlugin.canScheduleExactNotifications()) ?? false;
    } catch (_) {
      return true;
    }
  }

  /// Checks if notifications are globally permitted for the app on Android & iOS.
  static Future<bool> areNotificationsEnabled() async {
    try {
      final androidPlugin = _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        return (await androidPlugin.areNotificationsEnabled()) ?? true;
      }
      final iosPlugin = _plugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();
      if (iosPlugin != null) {
        final perms = await iosPlugin.checkPermissions();
        return perms?.isEnabled ?? true;
      }
      return true;
    } catch (_) {
      return true;
    }
  }

  /// Requests exact alarm permission (opens system Alarms & Reminders settings on Android 12+).
  static Future<bool?> requestExactAlarmsPermission() async {
    try {
      final androidPlugin = _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      return await androidPlugin?.requestExactAlarmsPermission();
    } catch (_) {
      return null;
    }
  }

  /// Requests notification permission on Android 13+ and iOS.
  static Future<bool?> requestNotificationPermission() async {
    try {
      final androidPlugin = _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        return await androidPlugin.requestNotificationsPermission();
      }
      final iosPlugin = _plugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();
      if (iosPlugin != null) {
        return await iosPlugin.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
      }
      return true;
    } catch (_) {
      return null;
    }
  }

  // Prevents concurrent calls to reschedule from interfering with each other.
  static bool _isRescheduling = false;

  static Future<void> rescheduleUpcomingPrayerAzans() async {
    // Debounce: ignore concurrent calls to prevent cancel/reschedule races
    if (_isRescheduling) return;
    _isRescheduling = true;
    try {
      await _rescheduleImpl();
    } finally {
      _isRescheduling = false;
    }
  }

  static Future<void> _rescheduleImpl() async {
    if (!StorageService.isNotificationsEnabled()) {
      // Notifications are turned off — cancel everything and return
      try { await _plugin.cancelAll(); } catch (_) {}
      return;
    }

    final soundId = await StorageService.getAzanSound();
    final prayerModes = StorageService.getPrayerNotificationModes();
    final now = DateTime.now();

    // Check exact alarm permission once per batch for efficiency
    final canExact = await canScheduleExactNotifications();

    // Collect all upcoming prayer items to schedule FIRST, before cancelling.
    // This prevents a race where cancelAll succeeds but rescheduling fails,
    // leaving the user with zero alarms.
    final List<_PendingAlarm> pendingAlarms = [];

    final preAzanMinutes = StorageService.getPreAzanReminderMinutes();
    // iOS has a hard cap of 64 scheduled notifications.
    // If pre-azan reminders are enabled, each day generates 10 notifications (5 prayers + 5 reminders).
    // Scheduling 5 days yields 50 notifications (safely under 64).
    // If pre-azan reminders are disabled, 7 days yields 35 notifications.
    final daysToSchedule = preAzanMinutes > 0 ? 5 : 7;

    for (var dayOffset = 0; dayOffset < daysToSchedule; dayOffset++) {
      final date = DateTime(now.year, now.month, now.day + dayOffset);
      try {
        final schedule = await PrayerRepository.getPrayerScheduleForDate(
          date: date,
        );
        final items = schedule['items'] as List<PrayerTimeItem>;
        final lang = AppLocalizations.languageCode;
        final locName = (lang == 'ku'
                ? (schedule['locationNameKu'] as String?)
                : (lang == 'ar'
                    ? (schedule['locationNameAr'] as String?)
                    : (schedule['locationNameEn'] as String?))) ??
            (schedule['locationName'] as String? ?? 'Kurdistan');

        final fajrSoundId = StorageService.getFajrAzanSound();

        final timezoneId = schedule['timezoneId'] as String? ?? 'Asia/Baghdad';
        tz.Location loc;
        try {
          loc = tz.getLocation(timezoneId);
        } catch (_) {
          loc = tz.local;
        }
        final nowInLoc = tz.TZDateTime.now(loc);

        for (final item in items) {
          final mode = prayerModes[item.id] ?? 'azan';

          final scheduledDate = tz.TZDateTime(
            loc,
            item.time.year,
            item.time.month,
            item.time.day,
            item.time.hour,
            item.time.minute,
          );

          // If mode is 'azan', ensure we have a valid audible sound even if global soundId was silent/vibrate
          final effectiveSoundId = (item.id == 'fajr' && fajrSoundId == 'azan_fajr')
              ? 'azan_fajr'
              : ((soundId == 'silent' || soundId == 'vibrate') ? 'makkah' : soundId);

          if (scheduledDate.isAfter(nowInLoc)) {
            pendingAlarms.add(_PendingAlarm(
              item: item,
              scheduledDate: scheduledDate,
              soundId: effectiveSoundId,
              mode: mode,
              locationName: locName,
              isPreAzan: false,
              minutesBefore: 0,
            ));
          }

          // Pre-azan reminder if configured (for 5 daily prayers, excluding sunrise)
          if (preAzanMinutes > 0 && item.id != 'sunrise' && mode != 'silent') {
            final reminderDate = scheduledDate.subtract(Duration(minutes: preAzanMinutes));
            if (reminderDate.isAfter(nowInLoc)) {
              pendingAlarms.add(_PendingAlarm(
                item: item,
                scheduledDate: reminderDate,
                soundId: effectiveSoundId,
                mode: mode,
                locationName: locName,
                isPreAzan: true,
                minutesBefore: preAzanMinutes,
              ));
            }
          } else {
            // Explicitly cancel pre-reminder for silent prayers or when pre-reminder is disabled
            await _plugin.cancel(id: _preReminderNotificationId(item));
          }
        }
      } catch (_) {
        // Continue collecting remaining days if one day encounters an error
        continue;
      }
    }

    // Atomically schedule all collected alarms by deterministic ID.
    // NOTE: We deliberately do NOT call cancelAll() here because cancelAll()
    // wipes all system alarms before a multi-second async loop, which creates a
    // race where minimizing the app or encountering an error leaves the user with 0 alarms.
    // In AlarmManager and UNUserNotificationCenter, zonedSchedule with the same ID
    // atomically updates and replaces the alarm without dropping existing ones.
    for (final alarm in pendingAlarms) {
      try {
        if (alarm.isPreAzan) {
          await _schedulePrePrayerReminder(
            item: alarm.item,
            scheduledDate: alarm.scheduledDate,
            minutesBefore: alarm.minutesBefore,
            locationName: alarm.locationName,
            mode: alarm.mode,
            canExact: canExact,
          );
        } else {
          await _schedulePrayer(
            item: alarm.item,
            scheduledDate: alarm.scheduledDate,
            soundId: alarm.soundId,
            mode: alarm.mode,
            locationName: alarm.locationName,
            canExact: canExact,
          );
        }
      } catch (_) {
        // Skip failed individual alarms — don't abort the whole batch
      }
    }
  }

  /// Checks whether the OS has excluded this app from battery optimization on Android.
  /// Always returns true on iOS.
  static Future<bool> isBatteryOptimizationIgnored() async {
    if (!Platform.isAndroid) return true;
    try {
      const channel = MethodChannel('com.nada.zikrakanm/battery');
      final bool? result =
          await channel.invokeMethod<bool>('isBatteryOptimizationIgnored');
      return result ?? true;
    } catch (_) {
      return true;
    }
  }

  /// Requests that the OS exclude this app from battery optimization.
  /// This is essential for reliable Azan delivery on Samsung, Xiaomi, OPPO,
  /// Huawei, and other OEM devices that aggressively kill background processes.
  /// Must only be called on Android; safe to call on iOS (no-op).
  static Future<void> requestBatteryOptimizationExclusion() async {
    if (!Platform.isAndroid) return;
    try {
      const channel = MethodChannel('com.nada.zikrakanm/battery');
      await channel.invokeMethod('requestIgnoreBatteryOptimizations');
    } on MissingPluginException {
      // Fallback: use flutter_local_notifications plugin's AndroidPlugin
      // to open battery settings so the user can whitelist manually
      try {
        final androidPlugin = _plugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();
        await androidPlugin?.requestExactAlarmsPermission();
      } catch (_) {}
    } catch (_) {}
  }

  static String localizedPrayerTitle({String? prayerId}) {
    final isSunrise = prayerId == 'sunrise';
    switch (AppLocalizations.languageCode) {
      case 'ku':
        return isSunrise ? 'کاتی هەڵاتنی خۆر هات' : 'کاتی بانگ هات';
      case 'ar':
        return isSunrise ? 'حان موعد شروق الشمس' : 'حان موعد الصلاة';
      default:
        return isSunrise ? 'Sunrise Time' : 'Time for Prayer';
    }
  }

  static String localizedPrayerBody(PrayerTimeItem item, String locationName) {
    final prayerName = item.localizedName(AppLocalizations.languageCode);
    // Remove (GPS), (GPS Fallback) or any parentheses terms from notification
    final cleanLocation = locationName
        .replaceAll(RegExp(r'\s*\([^)]*\)'), '')
        .trim();

    if (item.id == 'sunrise') {
      switch (AppLocalizations.languageCode) {
        case 'ku':
          return 'کاتی هەڵاتنی خۆر بۆ شاری $cleanLocation گەیشت';
        case 'ar':
          return 'حان الآن موعد شروق الشمس لمدينة $cleanLocation';
        default:
          return 'It is now sunrise in $cleanLocation';
      }
    }

    switch (AppLocalizations.languageCode) {
      case 'ku':
        return 'کاتی بانگی $prayerName بۆ شاری $cleanLocation گەیشت';
      case 'ar':
        return 'حان الآن موعد صلاة $prayerName لمدينة $cleanLocation';
      default:
        return 'It is now time for $prayerName in $cleanLocation';
    }
  }

  static Future<void> _schedulePrayer({
    required PrayerTimeItem item,
    required tz.TZDateTime scheduledDate,
    required String soundId,
    required String mode,
    required String locationName,
    bool? canExact,
  }) async {
    // Resolve sound fallback: if per-prayer mode is 'azan', ensure we have a valid audio sound
    final safeSound = (soundId == 'silent' || soundId == 'vibrate')
        ? 'makkah'
        : AzanAudioService.resolveSafeSoundId(soundId);
    final resourceName = _androidSoundResource(safeSound);

    final bool usesAzan = mode == 'azan';
    final bool usesVibration = mode == 'vibrate';
    final bool isSilent = mode == 'silent';

    // Powerful, distinct prayer alert vibration pattern (4 strong pulses)
    final vibrationPattern =
        Int64List.fromList([0, 1000, 500, 1000, 500, 1000, 500, 1000]);

    // Versioned channel IDs ensure Android OS applies fresh audio and vibration rules
    final channelId = isSilent
        ? '${channelVersion}_${item.id}_silent'
        : (!usesAzan && usesVibration)
            ? '${channelVersion}_${item.id}_vibrate'
            : '${channelVersion}_${item.id}_sound_$resourceName';

    final channelTitle = localizedPrayerTitle(prayerId: item.id);

    // Pre-create the notification channel with custom raw resource sound on Android
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      try {
        await androidPlugin.createNotificationChannel(
          AndroidNotificationChannel(
            channelId,
            channelTitle,
            description: channelTitle,
            importance: isSilent ? Importance.low : Importance.max,
            playSound: usesAzan,
            sound: usesAzan ? RawResourceAndroidNotificationSound(resourceName) : null,
            enableVibration: usesVibration || usesAzan,
            vibrationPattern: (usesVibration || usesAzan) ? vibrationPattern : null,
            // Azan uses alarm stream so it respects Alarm volume and rings even during DND
            audioAttributesUsage: usesAzan
                ? AudioAttributesUsage.alarm
                : AudioAttributesUsage.notification,
          ),
        );
      } catch (_) {}
    }

    final android = AndroidNotificationDetails(
      channelId,
      channelTitle,
      channelDescription: channelTitle,
      importance: isSilent ? Importance.low : Importance.max,
      priority: isSilent ? Priority.low : Priority.max,
      playSound: usesAzan,
      sound: usesAzan ? RawResourceAndroidNotificationSound(resourceName) : null,
      enableVibration: usesVibration || usesAzan,
      vibrationPattern: (usesVibration || usesAzan) ? vibrationPattern : null,
      audioAttributesUsage: usesAzan
          ? AudioAttributesUsage.alarm
          : AudioAttributesUsage.notification,
      category: usesAzan
          ? AndroidNotificationCategory.alarm
          : (isSilent
              ? AndroidNotificationCategory.status
              : AndroidNotificationCategory.reminder),
      fullScreenIntent: false,
      visibility: NotificationVisibility.public,
      channelAction: AndroidNotificationChannelAction.createIfNotExists,
      autoCancel: true,
      showWhen: true,
    );

    final ios = DarwinNotificationDetails(
      presentAlert: true,
      presentBanner: true,
      presentList: true,
      presentBadge: true,
      presentSound: usesAzan || usesVibration,
      sound: usesAzan
          ? '$resourceName.wav'
          : (usesVibration ? 'silent.wav' : null),
      interruptionLevel: isSilent
          ? InterruptionLevel.passive
          : InterruptionLevel.timeSensitive,
    );

    final exactAllowed = canExact ?? await canScheduleExactNotifications();
    final primaryScheduleMode = exactAllowed
        ? AndroidScheduleMode.alarmClock
        : AndroidScheduleMode.inexactAllowWhileIdle;

    try {
      await _plugin.zonedSchedule(
        id: _notificationId(item),
        title: channelTitle,
        body: localizedPrayerBody(item, locationName),
        scheduledDate: scheduledDate,
        notificationDetails: NotificationDetails(android: android, iOS: ios),
        androidScheduleMode: primaryScheduleMode,
        payload: 'prayer:${item.id}',
      );
    } catch (_) {
      try {
        await _plugin.zonedSchedule(
          id: _notificationId(item),
          title: channelTitle,
          body: localizedPrayerBody(item, locationName),
          scheduledDate: scheduledDate,
          notificationDetails: NotificationDetails(android: android, iOS: ios),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          payload: 'prayer:${item.id}',
        );
      } catch (_) {
        try {
          await _plugin.zonedSchedule(
            id: _notificationId(item),
            title: channelTitle,
            body: localizedPrayerBody(item, locationName),
            scheduledDate: scheduledDate,
            notificationDetails: NotificationDetails(android: android, iOS: ios),
            androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
            payload: 'prayer:${item.id}',
          );
        } catch (_) {}
      }
    }
  }

  static int _notificationId(PrayerTimeItem item) {
    final dateKey =
        item.time.year * 10000 + item.time.month * 100 + item.time.day;
    const ids = {
      'fajr': 1,
      'sunrise': 6,
      'dhuhr': 2,
      'asr': 3,
      'maghrib': 4,
      'isha': 5,
    };
    return dateKey * 10 + (ids[item.id] ?? 9);
  }

  static int _preReminderNotificationId(PrayerTimeItem item) {
    // Offset by 50,000,000 to prevent collisions and stay within 32-bit int
    return _notificationId(item) + 50000000;
  }

  static String localizedPreReminderTitle() {
    switch (AppLocalizations.languageCode) {
      case 'ku':
        return 'ئاگاداری پێش بانگ';
      case 'ar':
        return 'تنبيه قبل الأذان';
      default:
        return 'Pre-Prayer Reminder';
    }
  }

  static String localizedPreReminderBody(
    PrayerTimeItem item,
    int minutes,
    String locationName,
  ) {
    final prayerName = item.localizedName(AppLocalizations.languageCode);
    final cleanLocation = locationName
        .replaceAll(RegExp(r'\s*\([^)]*\)'), '')
        .trim();

    switch (AppLocalizations.languageCode) {
      case 'ku':
        return '$minutes خولەک ماوە بۆ بانگی $prayerName ($cleanLocation)';
      case 'ar':
        return 'بقي $minutes دقائق على موعد صلاة $prayerName ($cleanLocation)';
      default:
        return '$minutes minutes remaining until $prayerName in $cleanLocation';
    }
  }

  static Future<void> _schedulePrePrayerReminder({
    required PrayerTimeItem item,
    required tz.TZDateTime scheduledDate,
    required int minutesBefore,
    required String locationName,
    required String mode,
    bool? canExact,
  }) async {
    final bool usesAzan = mode == 'azan';
    final bool usesVibration = mode == 'vibrate';
    final bool isSilent = mode == 'silent';

    // If prayer is in silent mode, cancel any pre-reminder and do not schedule
    if (isSilent) {
      await _plugin.cancel(id: _preReminderNotificationId(item));
      return;
    }

    final channelId = usesVibration
        ? '${channelVersion}_pre_prayer_reminder_vibrate'
        : '${channelVersion}_pre_prayer_reminder';
    final channelTitle = localizedPreReminderTitle();

    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      try {
        await androidPlugin.createNotificationChannel(
          AndroidNotificationChannel(
            channelId,
            channelTitle,
            description: 'Notification sent before prayer time',
            importance: Importance.high,
            playSound: usesAzan,
            enableVibration: usesVibration || usesAzan,
            audioAttributesUsage: AudioAttributesUsage.notification,
          ),
        );
      } catch (_) {}
    }

    final android = AndroidNotificationDetails(
      channelId,
      channelTitle,
      channelDescription: 'Notification sent before prayer time',
      importance: Importance.high,
      priority: Priority.high,
      playSound: usesAzan,
      enableVibration: usesVibration || usesAzan,
      category: AndroidNotificationCategory.reminder,
      visibility: NotificationVisibility.public,
      channelAction: AndroidNotificationChannelAction.createIfNotExists,
      autoCancel: true,
      showWhen: true,
    );

    final ios = DarwinNotificationDetails(
      presentAlert: true,
      presentBanner: true,
      presentList: true,
      presentBadge: true,
      presentSound: usesAzan || usesVibration,
      sound: usesVibration ? 'silent.wav' : null,
      interruptionLevel: InterruptionLevel.timeSensitive,
    );

    final exactAllowed = canExact ?? await canScheduleExactNotifications();
    final primaryScheduleMode = exactAllowed
        ? AndroidScheduleMode.alarmClock
        : AndroidScheduleMode.inexactAllowWhileIdle;

    final body = localizedPreReminderBody(item, minutesBefore, locationName);
    final notifId = _preReminderNotificationId(item);

    try {
      await _plugin.zonedSchedule(
        id: notifId,
        title: channelTitle,
        body: body,
        scheduledDate: scheduledDate,
        notificationDetails: NotificationDetails(android: android, iOS: ios),
        androidScheduleMode: primaryScheduleMode,
        payload: 'pre_prayer:${item.id}',
      );
    } catch (_) {
      try {
        await _plugin.zonedSchedule(
          id: notifId,
          title: channelTitle,
          body: body,
          scheduledDate: scheduledDate,
          notificationDetails: NotificationDetails(android: android, iOS: ios),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          payload: 'pre_prayer:${item.id}',
        );
      } catch (_) {
        try {
          await _plugin.zonedSchedule(
            id: notifId,
            title: channelTitle,
            body: body,
            scheduledDate: scheduledDate,
            notificationDetails: NotificationDetails(android: android, iOS: ios),
            androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
            payload: 'pre_prayer:${item.id}',
          );
        } catch (_) {}
      }
    }
  }

  static String _androidSoundResource(String soundId) {
    final safeId = AzanAudioService.resolveSafeSoundId(soundId);
    if (safeId == 'silent' || safeId == 'vibrate') {
      return 'makkah';
    }
    return safeId.replaceAll('-', '_');
  }

  static String localizedReminderTitle() {
    switch (AppLocalizations.languageCode) {
      case 'ku':
        return 'ئاگادارکردنەوەی زیکر';
      case 'ar':
        return 'تذكير الذكر';
      default:
        return AppLocalizations.translateStatic('zikrReminderTitle');
    }
  }

  static String localizedReminderBody() {
    switch (AppLocalizations.languageCode) {
      case 'ku':
        return 'کاتێک بۆ بیرکردنەوەی نامەوە';
      case 'ar':
        return 'خذ لحظة للذكر والتأمل';
      default:
        return AppLocalizations.translateStatic('zikrReminderBody');
    }
  }

  static Future<void> showReminder(String title, String body) async {
    final resolvedTitle = title.isNotEmpty ? title : localizedReminderTitle();
    final resolvedBody = body.isNotEmpty ? body : localizedReminderBody();

    final androidDetails = AndroidNotificationDetails(
      'zikr_reminder',
      localizedReminderTitle(),
      channelDescription: localizedReminderBody(),
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    final details =
        NotificationDetails(android: androidDetails, iOS: iosDetails);
    await _plugin.show(
      id: 0,
      title: resolvedTitle,
      body: resolvedBody,
      notificationDetails: details,
      payload: 'zikr_reminder',
    );
  }

  /// Sends an immediate test prayer notification with azan sound and vibration
  /// so users can easily test their device sound, DND, and permission settings.
  static Future<void> showTestPrayerNotification() async {
    final soundId = await StorageService.getAzanSound();
    final isSilent = soundId == 'silent';
    final isVibrate = soundId == 'vibrate';
    final safeSound = (isSilent || isVibrate)
        ? 'makkah'
        : AzanAudioService.resolveSafeSoundId(soundId);
    final resourceName = _androidSoundResource(safeSound);

    // Actively play the selected azan audio in-app with AVAudioSessionCategory.playback
    // so the sound plays loud and clear out of the device speakers on iOS,
    // only if the user hasn't selected silent or vibrate.
    if (!isSilent && !isVibrate) {
      try {
        await AzanAudioService.instance.play(safeSound);
      } catch (_) {}
    } else if (isVibrate) {
      await HapticFeedback.vibrate();
    }

    final vibrationPattern =
        Int64List.fromList([0, 1000, 500, 1000, 500, 1000, 500, 1000]);

    final channelId = isSilent
        ? '${channelVersion}_test_prayer_silent'
        : (isVibrate
            ? '${channelVersion}_test_prayer_vibrate'
            : '${channelVersion}_test_prayer_sound_$resourceName');
    const channelTitle = 'Test Prayer Alert';

    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      try {
        await androidPlugin.createNotificationChannel(
          AndroidNotificationChannel(
            channelId,
            channelTitle,
            description: channelTitle,
            importance: isSilent ? Importance.low : Importance.max,
            playSound: !isSilent && !isVibrate,
            sound: (!isSilent && !isVibrate)
                ? RawResourceAndroidNotificationSound(resourceName)
                : null,
            enableVibration: isVibrate || (!isSilent && !isVibrate),
            vibrationPattern: (isVibrate || (!isSilent && !isVibrate))
                ? vibrationPattern
                : null,
            audioAttributesUsage: (!isSilent && !isVibrate)
                ? AudioAttributesUsage.alarm
                : AudioAttributesUsage.notification,
          ),
        );
      } catch (_) {}
    }

    final android = AndroidNotificationDetails(
      channelId,
      channelTitle,
      channelDescription: channelTitle,
      importance: isSilent ? Importance.low : Importance.max,
      priority: isSilent ? Priority.low : Priority.max,
      playSound: !isSilent && !isVibrate,
      sound: (!isSilent && !isVibrate)
          ? RawResourceAndroidNotificationSound(resourceName)
          : null,
      enableVibration: isVibrate || (!isSilent && !isVibrate),
      vibrationPattern: (isVibrate || (!isSilent && !isVibrate))
          ? vibrationPattern
          : null,
      audioAttributesUsage: (!isSilent && !isVibrate)
          ? AudioAttributesUsage.alarm
          : AudioAttributesUsage.notification,
      category: (!isSilent && !isVibrate)
          ? AndroidNotificationCategory.alarm
          : (isSilent
              ? AndroidNotificationCategory.status
              : AndroidNotificationCategory.reminder),
      fullScreenIntent: false,
      visibility: NotificationVisibility.public,
      channelAction: AndroidNotificationChannelAction.createIfNotExists,
      autoCancel: true,
    );

    final ios = DarwinNotificationDetails(
      presentAlert: true,
      presentBanner: true,
      presentList: true,
      presentBadge: true,
      presentSound: !isSilent,
      sound: (!isSilent && !isVibrate)
          ? '$resourceName.wav'
          : (isVibrate ? 'silent.wav' : null),
      interruptionLevel: isSilent
          ? InterruptionLevel.passive
          : InterruptionLevel.timeSensitive,
    );

    final title = localizedPrayerTitle();
    final body = AppLocalizations.languageCode == 'ku'
        ? 'ئەمە تاقیکردنەوەی دەنگی بانگ و ئاگادارکردنەوەیە'
        : (AppLocalizations.languageCode == 'ar'
            ? 'هذا إشعار تجريبي لأذان الصلاة والصوت'
            : 'This is a test notification for prayer azan and sound');

    await _plugin.show(
      id: 999999,
      title: title,
      body: body,
      notificationDetails: NotificationDetails(android: android, iOS: ios),
      payload: 'test_prayer',
    );
  }

  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}

/// Internal data class used to batch-collect all upcoming prayer alarms
/// before atomically replacing existing scheduled alarms.
class _PendingAlarm {
  final PrayerTimeItem item;
  final tz.TZDateTime scheduledDate;
  final String soundId;
  final String mode;
  final String locationName;
  final bool isPreAzan;
  final int minutesBefore;

  const _PendingAlarm({
    required this.item,
    required this.scheduledDate,
    required this.soundId,
    required this.mode,
    required this.locationName,
    required this.isPreAzan,
    required this.minutesBefore,
  });
}
