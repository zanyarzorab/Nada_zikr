import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../app_localizations.dart';
import '../services/prayer_repository.dart';
import '../services/notification_service.dart';
import '../services/prayer_widget_service.dart';
import '../services/storage_service.dart';
import '../widgets/app_theme.dart';
import '../widgets/location_selector_sheet.dart';
import '../widgets/monthly_timetable_sheet.dart';
import '../widgets/prayer_settings_sheet.dart';
import '../widgets/qibla_compass_sheet.dart';
import '../widgets/azan_sound_picker_sheet.dart';

/// Premier Main Prayer Times & Qibla Screen
class PrayerTimesScreen extends StatefulWidget {
  const PrayerTimesScreen({Key? key}) : super(key: key);

  @override
  State<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends State<PrayerTimesScreen>
    with WidgetsBindingObserver {
  DateTime _selectedDate = DateTime.now();
  late Future<Map<String, dynamic>> _scheduleFuture;
  Timer? _tickerTimer;
  Duration _timeUntilNext = Duration.zero;
  bool _notificationsAllowed = true;
  bool _exactAlarmsAllowed = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refreshSchedule();
    _checkPermissions();
    _tickerTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateCountdown();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tickerTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPermissions();
    }
  }

  Future<void> _checkPermissions() async {
    final notifs = await NotificationService.areNotificationsEnabled();
    final exact = await NotificationService.canScheduleExactNotifications();
    if (mounted) {
      setState(() {
        _notificationsAllowed = notifs;
        _exactAlarmsAllowed = exact;
      });
    }
  }

  void _refreshSchedule() {
    final future =
        PrayerRepository.getPrayerScheduleForDate(date: _selectedDate);
    setState(() {
      _scheduleFuture = future;
    });
    unawaited(NotificationService.rescheduleUpcomingPrayerAzans());
    unawaited(PrayerWidgetService.updateWidgets());
  }

  void _updateCountdown() {
    if (!mounted) return;
    setState(() {});
  }

  String _formatDuration(Duration duration) {
    if (duration.isNegative) return '00:00:00';
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  Future<void> _cyclePrayerNotificationMode(String prayerId) async {
    final current =
        StorageService.getPrayerNotificationModes()[prayerId] ?? 'azan';
    const modes = ['azan', 'silent', 'vibrate'];
    final next = modes[(modes.indexOf(current) + 1) % modes.length];
    await StorageService.savePrayerNotificationMode(prayerId, next);
    await NotificationService.rescheduleUpcomingPrayerAzans();
    if (next == 'vibrate') {
      await HapticFeedback.vibrate();
    } else if (next == 'azan') {
      await HapticFeedback.mediumImpact();
    } else {
      await HapticFeedback.selectionClick();
    }
    if (mounted) setState(() {});
  }

  IconData _notificationModeIcon(String prayerId) {
    final mode =
        StorageService.getPrayerNotificationModes()[prayerId] ?? 'azan';
    switch (mode) {
      case 'silent':
        return Icons.notifications_off_outlined;
      case 'vibrate':
        return Icons.vibration_rounded;
      default:
        return Icons.volume_up_rounded;
    }
  }

  Widget _buildPermissionNoticeBanner(bool isKurdish, String lang) {
    if (_notificationsAllowed && _exactAlarmsAllowed) {
      return const SizedBox.shrink();
    }

    final bool isNotificationMissing = !_notificationsAllowed;
    final String title = isNotificationMissing
        ? (isKurdish
            ? 'ئاگادارکردنەوەکان ناچالاکن'
            : (lang == 'ar' ? 'الإشعارات معطلة' : 'Notifications are disabled'))
        : (isKurdish
            ? 'کات دیاریکردنی ورد سنووردارە'
            : (lang == 'ar'
                ? 'تنبيهات المواعيد الدقيقة مقيدة'
                : 'Exact prayer alarms restricted'));

    final String subtitle = isNotificationMissing
        ? (isKurdish
            ? 'تکایە ڕێگە بە ئاگادارکردنەوە بدە بۆ گەیشتنی بانگ و کاتی نوێژەکان.'
            : (lang == 'ar'
                ? 'يرجى تفعيل الإشعارات لسماع الأذان وتنبيهات أوقات الصلاة.'
                : 'Enable notifications to hear the Azan and prayer alerts on time.'))
        : (isKurdish
            ? 'بۆ ئەوەی بانگ ڕێک لە کاتی خۆیدا لێبدات، ڕێگە بە کاتژمێری ورد بدە لە ڕێکخستنەکان.'
            : (lang == 'ar'
                ? 'لسماع الأذان بدقة في وقته المحدد، يرجى السماح بالتنبيهات الدقيقة.'
                : 'To ring the Azan accurately on time, allow Alarms & Reminders in settings.'));

    final String buttonLabel = isNotificationMissing
        ? (isKurdish ? 'چالاککردن' : (lang == 'ar' ? 'تفعيل' : 'Enable'))
        : (isKurdish ? 'ڕێکخستن' : (lang == 'ar' ? 'إصلاح' : 'Fix'));

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF332008),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: 0.6),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isNotificationMissing
                  ? Icons.notifications_off_rounded
                  : Icons.alarm_off_rounded,
              color: AppColors.gold,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: isKurdish
                      ? AppTheme.kurdishTitle(
                          fontSize: 13,
                          color: AppColors.gold,
                          fontWeight: FontWeight.bold,
                        )
                      : AppTheme.englishTitle(
                          fontSize: 13,
                          color: AppColors.gold,
                          fontWeight: FontWeight.bold,
                        ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: isKurdish
                      ? AppTheme.kurdishText(
                          fontSize: 11,
                          color: AppColors.cream.withValues(alpha: 0.85),
                        )
                      : AppTheme.englishText(
                          fontSize: 11,
                          color: AppColors.cream.withValues(alpha: 0.85),
                        ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.gold,
              foregroundColor: Colors.black87,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            onPressed: () async {
              if (isNotificationMissing) {
                await NotificationService.requestNotificationPermission();
              } else {
                await NotificationService.requestExactAlarmsPermission();
              }
              await _checkPermissions();
              await NotificationService.rescheduleUpcomingPrayerAzans();
            },
            child: Text(buttonLabel),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final lang = loc?.locale.languageCode ?? 'ku';
    final isKurdish = lang == 'ku';

    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF0D2419),
              AppColors.darkBg,
              AppColors.darkBgAlt,
            ],
          ),
        ),
        child: SafeArea(
          child: FutureBuilder<Map<String, dynamic>>(
            future: _scheduleFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(color: AppColors.gold),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error loading schedule: ${snapshot.error}',
                    style: AppTheme.englishText(color: Colors.redAccent),
                  ),
                );
              }

              final data = snapshot.data!;
              final double lat = data['latitude'];
              final double lng = data['longitude'];
              final WorldCity? currentCity = data['city'];
              final String locationName = isKurdish
                  ? (data['locationNameKu'] ?? currentCity?.nameKu ?? data['locationName'])
                  : (lang == 'ar'
                      ? (data['locationNameAr'] ?? currentCity?.nameAr ?? data['locationName'])
                      : (data['locationNameEn'] ?? currentCity?.nameEn ?? data['locationName']));
              final List<PrayerTimeItem> items = data['items'];
              final String nextId = data['nextId'];
              final DateTime? nextTime = data['nextTime'];
              final HijriDateInfo hijriDate = data['hijriDate'];

              if (nextTime != null) {
                _timeUntilNext = nextTime.difference(DateTime.now());
              }

              final nextItem = items.firstWhere(
                (it) => it.id == nextId,
                orElse: () => items.first,
              );

              return Column(
                children: [
                  // Top Navigation & Action Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Location Selector Button
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              LocationSelectorSheet.show(
                                context,
                                locale: lang,
                                onLocationSelected: _refreshSchedule,
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppColors.panelColor,
                                border: Border.all(
                                    color:
                                        AppColors.gold.withValues(alpha: 0.35)),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.location_on_rounded,
                                      color: AppColors.gold, size: 18),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      locationName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: isKurdish
                                          ? AppTheme.kurdishTitle(
                                              fontSize: 13,
                                              color: AppColors.cream)
                                          : AppTheme.englishText(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.cream),
                                    ),
                                  ),
                                  Icon(Icons.arrow_drop_down_rounded,
                                      color: AppColors.gold, size: 20),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),

                        // Action Buttons: Qibla Compass, Timetable, Settings, Azan Sound
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerRight,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // 🧭 QIBLA COMPASS BUTTON
                                IconButton(
                                  padding: const EdgeInsets.all(4),
                                  constraints: const BoxConstraints(),
                                  tooltip: 'Qibla Compass',
                                  icon: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppColors.gold.withValues(alpha: 0.15),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: AppColors.gold
                                              .withValues(alpha: 0.4)),
                                    ),
                                    child: Icon(Icons.explore_rounded,
                                        color: AppColors.gold, size: 18),
                                  ),
                                  onPressed: () {
                                    QiblaCompassSheet.show(
                                      context,
                                      latitude: lat,
                                      longitude: lng,
                                      locationName: locationName,
                                    );
                                  },
                                ),
                                const SizedBox(width: 4),
                                // 📅 MONTHLY TIMETABLE
                                IconButton(
                                  padding: const EdgeInsets.all(4),
                                  constraints: const BoxConstraints(),
                                  tooltip: 'Monthly Timetable',
                                  icon: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppColors.panelColor,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: AppColors.panelBorderColor),
                                    ),
                                    child: Icon(Icons.calendar_month_rounded,
                                        color: AppColors.cream, size: 17),
                                  ),
                                  onPressed: () {
                                    MonthlyTimetableSheet.show(context,
                                        initialDate: _selectedDate);
                                  },
                                ),
                                const SizedBox(width: 4),
                                // ⚙️ PRAYER SETTINGS
                                IconButton(
                                  padding: const EdgeInsets.all(4),
                                  constraints: const BoxConstraints(),
                                  tooltip: 'Prayer Settings',
                                  icon: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppColors.panelColor,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: AppColors.panelBorderColor),
                                    ),
                                    child: Icon(Icons.settings_outlined,
                                        color: AppColors.cream, size: 17),
                                  ),
                                  onPressed: () {
                                    PrayerSettingsSheet.show(
                                      context,
                                      onSettingsSaved: _refreshSchedule,
                                    );
                                  },
                                ),
                                const SizedBox(width: 4),
                                IconButton(
                                  padding: const EdgeInsets.all(4),
                                  constraints: const BoxConstraints(),
                                  tooltip: 'Azan sound',
                                  icon: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppColors.panelColor,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: AppColors.panelBorderColor),
                                    ),
                                    child: Icon(Icons.volume_up_rounded,
                                        color: AppColors.cream, size: 17),
                                  ),
                                  onPressed: () =>
                                      AzanSoundPickerSheet.show(context),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          _buildPermissionNoticeBanner(isKurdish, lang),

                          // HERO NEXT PRAYER CARD WITH COUNTDOWN
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(22),
                            decoration: BoxDecoration(
                              color: AppColors.panelColor,
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(
                                  color: AppColors.gold.withValues(alpha: 0.4),
                                  width: 1.5),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.gold.withValues(alpha: 0.12),
                                  blurRadius: 25,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppColors.gold
                                            .withValues(alpha: 0.16),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        isKurdish
                                            ? 'نوێژی داهاتوو'
                                            : 'NEXT PRAYER',
                                        style: AppTheme.englishText(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.gold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),

                                // Next Prayer Name
                                Text(
                                  nextItem.localizedName(lang),
                                  style: isKurdish
                                      ? AppTheme.kurdishTitle(
                                          fontSize: 28, color: AppColors.gold)
                                      : AppTheme.englishTitle(
                                          fontSize: 28, color: AppColors.gold),
                                ),
                                const SizedBox(height: 6),

                                // Live Countdown Timer (HH:MM:SS)
                                Text(
                                  _formatDuration(_timeUntilNext),
                                  style: AppTheme.englishTitle(
                                    fontSize: 38,
                                    color: AppColors.cream,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 6),

                                Text(
                                  nextItem.formattedTime(),
                                  style: AppTheme.englishText(
                                      fontSize: 14, color: AppColors.faintText),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          const SizedBox(height: 16),

                          // DATE BAR WITH GREGORIAN & HIJRI SWITCHER
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color:
                                  AppColors.panelColor.withValues(alpha: 0.8),
                              borderRadius: BorderRadius.circular(20),
                              border:
                                  Border.all(color: AppColors.panelBorderColor),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.chevron_left_rounded,
                                      color: AppColors.gold),
                                  onPressed: () {
                                    setState(() {
                                      _selectedDate = _selectedDate
                                          .subtract(const Duration(days: 1));
                                      _refreshSchedule();
                                    });
                                  },
                                ),
                                Column(
                                  children: [
                                    Text(
                                      '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}',
                                      style: AppTheme.englishTitle(
                                          fontSize: 15, color: AppColors.cream),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      hijriDate.formatted(lang),
                                      style: AppTheme.kurdishText(
                                          fontSize: 12, color: AppColors.gold),
                                    ),
                                  ],
                                ),
                                IconButton(
                                  icon: Icon(Icons.chevron_right_rounded,
                                      color: AppColors.gold),
                                  onPressed: () {
                                    setState(() {
                                      _selectedDate = _selectedDate
                                          .add(const Duration(days: 1));
                                      _refreshSchedule();
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          // DAILY PRAYER CARDS LIST
                          Column(
                            children: items.map((item) {
                              final isNext = item.id == nextId &&
                                  _selectedDate.day == DateTime.now().day;
                              return Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 18, vertical: 14),
                                decoration: BoxDecoration(
                                  color: isNext
                                      ? AppColors.gold.withValues(alpha: 0.16)
                                      : AppColors.panelColor,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isNext
                                        ? AppColors.gold
                                        : (item.isPassed
                                            ? Colors.white10
                                            : AppColors.panelBorderColor),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Row(
                                        children: [
                                          Icon(
                                            _getPrayerIcon(item.id),
                                            color: isNext
                                                ? AppColors.gold
                                                : (item.isPassed
                                                    ? AppColors.faintText
                                                    : AppColors.cream),
                                            size: 20,
                                          ),
                                          const SizedBox(width: 14),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  item.localizedName(lang),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: isKurdish
                                                      ? AppTheme.kurdishTitle(
                                                          fontSize: 15,
                                                          color: isNext
                                                              ? AppColors.gold
                                                              : AppColors.cream,
                                                        )
                                                      : AppTheme.englishText(
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: isNext
                                                              ? AppColors.gold
                                                              : AppColors.cream,
                                                        ),
                                                ),
                                                Text(
                                                  item.id.toUpperCase(),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: AppTheme.englishText(
                                                    fontSize: 10,
                                                    color: AppColors.faintText,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: FittedBox(
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              onPressed: () =>
                                                  _cyclePrayerNotificationMode(
                                                      item.id),
                                              tooltip: 'Change prayer alert mode',
                                              icon: Icon(
                                                _notificationModeIcon(item.id),
                                                size: 19,
                                                color: isNext
                                                    ? AppColors.gold
                                                    : AppColors.mutedText,
                                              ),
                                            ),
                                            Text(
                                              item.formattedTime(),
                                              style: AppTheme.englishTitle(
                                                fontSize: 16,
                                                color: isNext
                                                    ? AppColors.gold
                                                    : AppColors.cream,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  IconData _getPrayerIcon(String id) {
    switch (id) {
      case 'fajr':
        return Icons.wb_twilight_rounded;
      case 'sunrise':
        return Icons.wb_sunny_outlined;
      case 'dhuhr':
        return Icons.wb_sunny_rounded;
      case 'asr':
        return Icons.wb_cloudy_rounded;
      case 'maghrib':
        return Icons.nights_stay_outlined;
      case 'isha':
        return Icons.nights_stay_rounded;
      default:
        return Icons.access_time_rounded;
    }
  }
}
