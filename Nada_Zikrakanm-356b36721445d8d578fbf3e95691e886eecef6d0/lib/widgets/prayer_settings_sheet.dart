import 'dart:async';
import 'package:flutter/material.dart';
import '../app_localizations.dart';
import '../services/azan_audio_service.dart';
import '../services/notification_service.dart';
import '../services/offline_prayer_calculator.dart';
import '../services/prayer_repository.dart';
import '../services/prayer_widget_service.dart';
import '../services/storage_service.dart';
import 'app_theme.dart';
import 'location_selector_sheet.dart';

/// Authentic Prayer Calculation Settings, Live Minute Offsets,
/// Hijri Date Calibration, Pre-Azan Reminders & Azan Audio Hub.
class PrayerSettingsSheet extends StatefulWidget {
  final VoidCallback onSettingsSaved;

  const PrayerSettingsSheet({Key? key, required this.onSettingsSaved})
      : super(key: key);

  static Future<void> show(BuildContext context,
      {required VoidCallback onSettingsSaved}) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PrayerSettingsSheet(onSettingsSaved: onSettingsSaved),
    );
  }

  @override
  State<PrayerSettingsSheet> createState() => _PrayerSettingsSheetState();
}

class _PrayerSettingsSheetState extends State<PrayerSettingsSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  late String _selectedMethodId;
  late String _selectedAsrSchool;
  late String _selectedHighLatRule;
  late Map<String, int> _offsets;
  late int _selectedHijriOffset;
  late int _selectedPreAzanMinutes;
  late String _selectedAzanSound;

  Map<String, DateTime>? _previewTimes;
  bool _isOfficialTimetable = false;
  HijriDateInfo? _previewHijriDate;
  WorldCity? _previewCity;
  String? _previewTimezoneAbbr;
  double? _previewTargetUtcOffset;
  bool _isLoadingPreview = true;
  String? _previewPlayingSound;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    _selectedMethodId = StorageService.getPrayerMethod();
    _selectedAsrSchool = StorageService.getPrayerAsrSchool();
    _selectedHighLatRule = StorageService.getPrayerHighLatRule();
    _offsets = Map<String, int>.from(StorageService.getPrayerMinuteOffsets());
    _selectedHijriOffset = StorageService.getPrayerHijriOffset();
    _selectedPreAzanMinutes = StorageService.getPreAzanReminderMinutes();
    _selectedAzanSound = 'makkah';

    _loadInitialAzanSound();
    _recalculatePreview();
  }

  Future<void> _loadInitialAzanSound() async {
    final sound = await StorageService.getAzanSound();
    if (mounted) {
      setState(() => _selectedAzanSound = sound);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    unawaited(AzanAudioService.instance.stop());
    super.dispose();
  }

  Future<void> _recalculatePreview() async {
    final now = DateTime.now();
    try {
      final res = await PrayerRepository.previewPrayerDayTimes(
        date: now,
        methodId: _selectedMethodId,
        asrSchoolStr: _selectedAsrSchool,
        highLatStr: _selectedHighLatRule,
        offsets: _offsets,
        hijriOffset: _selectedHijriOffset,
      );
      if (mounted) {
        setState(() {
          _previewTimes = res['times'] as Map<String, DateTime>?;
          _isOfficialTimetable = res['isOfficialTimetable'] as bool? ?? false;
          _previewHijriDate = res['hijriDate'] as HijriDateInfo?;
          _previewCity = res['city'] as WorldCity?;
          _previewTimezoneAbbr = res['timezoneAbbr'] as String?;
          _previewTargetUtcOffset = res['targetUtcOffset'] as double?;
          _isLoadingPreview = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoadingPreview = false);
      }
    }
  }

  Future<void> _toggleAudioPreview(String soundId) async {
    if (_previewPlayingSound == soundId) {
      await AzanAudioService.instance.stop();
      if (mounted) setState(() => _previewPlayingSound = null);
    } else {
      if (soundId == 'silent' || soundId == 'vibrate') {
        await AzanAudioService.instance.stop();
        if (mounted) setState(() => _previewPlayingSound = null);
        return;
      }
      await AzanAudioService.instance.play(soundId);
      if (mounted) setState(() => _previewPlayingSound = soundId);
    }
  }

  Future<void> _save() async {
    await AzanAudioService.instance.stop();
    await StorageService.savePrayerMethod(_selectedMethodId);
    await StorageService.savePrayerAsrSchool(_selectedAsrSchool);
    await StorageService.savePrayerHighLatRule(_selectedHighLatRule);
    await StorageService.savePrayerMinuteOffsets(_offsets);
    await StorageService.savePrayerHijriOffset(_selectedHijriOffset);
    await StorageService.savePreAzanReminderMinutes(_selectedPreAzanMinutes);
    await StorageService.saveAzanSound(_selectedAzanSound);
    await StorageService.saveFajrAzanSound(_selectedAzanSound);

    await NotificationService.rescheduleUpcomingPrayerAzans();
    await PrayerWidgetService.updateWidgets();
    widget.onSettingsSaved();

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.languageCode == 'ku'
                ? 'ڕێکخستنەکان پاشەکەوت کران و کاتەکان نوێکرانەوە'
                : (AppLocalizations.languageCode == 'ar'
                    ? 'تم حفظ الإعدادات وتحديث المواقيت بنجاح'
                    : 'Prayer settings saved & times updated successfully'),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: AppColors.darkPanel,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _resetOffsets() {
    setState(() {
      _offsets.clear();
      _offsets.addAll({
        'fajr': 0,
        'sunrise': 0,
        'dhuhr': 0,
        'asr': 0,
        'maghrib': 0,
        'isha': 0,
      });
    });
    _recalculatePreview();
  }

  String _formatTime(DateTime? dt) {
    if (dt == null) return '--:--';
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final language = AppLocalizations.languageCode;
    final isKurdish = language == 'ku';
    final isArabic = language == 'ar';

    String loc(String ku, String ar, String en) {
      return isKurdish ? ku : (isArabic ? ar : en);
    }

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.92,
      ),
      decoration: BoxDecoration(
        color: AppColors.darkPanel,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.6),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            const SizedBox(height: 12),
            // Handle bar
            Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 14),

            // Header Title & Engine Status
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          loc('ڕێکخستنەکانی کاتی بانگ و ئاگادارکردنەوە',
                              'إعدادات مواقيت الصلاة والأذان', 'Prayer Times & Azan Settings'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTheme.kurdishTitle(fontSize: 18, color: AppColors.gold),
                        ),
                        const SizedBox(height: 3),
                        // Live Engine Status Badge
                        _buildEngineBadge(isKurdish, isArabic),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close_rounded, color: AppColors.faintText),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Segmented Navigation Tabs
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.panelColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.panelBorderColor),
              ),
              child: TabBar(
                controller: _tabController,
                indicatorColor: AppColors.gold,
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: AppColors.gold,
                unselectedLabelColor: AppColors.mutedText,
                indicatorWeight: 3,
                labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                tabs: [
                  Tab(
                    icon: const Icon(Icons.tune_rounded, size: 18),
                    text: loc('دەستکاری', 'التعديل', 'Offsets'),
                  ),
                  Tab(
                    icon: const Icon(Icons.auto_awesome_rounded, size: 18),
                    text: loc('حیسابکاری', 'الحساب', 'Method'),
                  ),
                  Tab(
                    icon: const Icon(Icons.notifications_active_rounded, size: 18),
                    text: loc('ئاگاداری', 'التنبيه', 'Azan'),
                  ),
                  Tab(
                    icon: const Icon(Icons.calendar_month_rounded, size: 18),
                    text: loc('کۆچی', 'الهجري', 'Hijri'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Tab Views Content
            Expanded(
              child: _isLoadingPreview
                  ? Center(child: CircularProgressIndicator(color: AppColors.gold))
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        // Tab 1: Live Minute Offsets with dynamic time preview
                        _buildOffsetsTab(isKurdish, isArabic),
                        // Tab 2: Calculation Engine (15 methods, Asr school, high latitude)
                        _buildCalculationMethodTab(isKurdish, isArabic),
                        // Tab 3: Azan Sound & Pre-Azan Reminder
                        _buildAzanAndRemindersTab(isKurdish, isArabic),
                        // Tab 4: Hijri Date Calibration
                        _buildHijriCalibrationTab(isKurdish, isArabic),
                      ],
                    ),
            ),

            // Bottom Save Bar
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.darkPanel,
                border: Border(top: BorderSide(color: AppColors.panelBorderColor)),
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.gold,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle_rounded, size: 20, color: Colors.black),
                      const SizedBox(width: 8),
                      Text(
                        loc('پاشەکەوتکردن و چالاککردن', 'حفظ وتفعيل التغييرات',
                            'Save & Apply Settings'),
                        style: isKurdish
                            ? AppTheme.kurdishTitle(fontSize: 16, color: Colors.black)
                            : AppTheme.englishTitle(fontSize: 16, color: Colors.black),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEngineBadge(bool isKurdish, bool isArabic) {
    final cityName = _previewCity?.displayName(AppLocalizations.languageCode) ??
        StorageService.getPrayerSelectedCity();
    final tzLabel = _previewTimezoneAbbr ?? 'UTC+3';
    final offsetStr = _previewTargetUtcOffset != null
        ? ' · UTC${_previewTargetUtcOffset! >= 0 ? "+${_previewTargetUtcOffset!.toInt()}" : _previewTargetUtcOffset!.toInt()}'
        : '';

    return Wrap(
      spacing: 6,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        // Location & Timezone badge (Tap to change city)
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () {
              LocationSelectorSheet.show(
                context,
                locale: AppLocalizations.languageCode,
                onLocationSelected: () {
                  _recalculatePreview();
                },
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.panelColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.gold.withValues(alpha: 0.45)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.location_on_rounded, size: 12, color: AppColors.gold),
                  const SizedBox(width: 4),
                  Text(
                    '$cityName ($tzLabel$offsetStr)',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.cream,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.edit_rounded, size: 10, color: AppColors.gold),
                ],
              ),
            ),
          ),
        ),

        // Method / Timetable badge
        if (_isOfficialTimetable)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.5)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.verified_rounded, size: 12, color: Colors.greenAccent),
                const SizedBox(width: 4),
                Text(
                  isKurdish
                      ? 'خشتەی فەرمی ئەوقاف'
                      : (isArabic
                          ? 'الجدول الرسمي للأوقاف'
                          : 'Official Awqaf Timetable'),
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.greenAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          )
        else
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.bolt_rounded, size: 13, color: AppColors.gold),
                const SizedBox(width: 3),
                Text(
                  isKurdish
                      ? 'حیسابکاری فەلەکی بێ ئینتەرنێت'
                      : (isArabic
                          ? 'حساب فلكي دقيق'
                          : 'Offline Astronomical Math'),
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.gold,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  // ================= TAB 1: MINUTE OFFSETS & LIVE TIMES =================
  Widget _buildOffsetsTab(bool isKurdish, bool isArabic) {
    final prayers = [
      {'id': 'fajr', 'ku': 'بەیانی', 'ar': 'الفجر', 'en': 'Fajr', 'icon': Icons.wb_twilight_rounded},
      {'id': 'sunrise', 'ku': 'هەڵاتنی خۆر', 'ar': 'الشروق', 'en': 'Sunrise', 'icon': Icons.wb_sunny_rounded},
      {'id': 'dhuhr', 'ku': 'نیوەڕۆ', 'ar': 'الظهر', 'en': 'Dhuhr', 'icon': Icons.brightness_high_rounded},
      {'id': 'asr', 'ku': 'عەسر', 'ar': 'العصر', 'en': 'Asr', 'icon': Icons.wb_cloudy_rounded},
      {'id': 'maghrib', 'ku': 'مەغریب', 'ar': 'المغرب', 'en': 'Maghrib', 'icon': Icons.nights_stay_rounded},
      {'id': 'isha', 'ku': 'عیشا', 'ar': 'العشاء', 'en': 'Isha', 'icon': Icons.bedtime_rounded},
    ];

    final hasCustomOffsets = _offsets.values.any((v) => v != 0);

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              isKurdish
                  ? 'دەستکاری خولەک بە خولەکی کاتەکان'
                  : (isArabic ? 'تعديل دقائق المواقيت بدقة' : 'Minute-by-Minute Tuning'),
              style: AppTheme.kurdishTitle(fontSize: 14, color: AppColors.cream),
            ),
            if (hasCustomOffsets)
              TextButton.icon(
                onPressed: _resetOffsets,
                icon: const Icon(Icons.refresh_rounded, size: 16, color: Colors.orangeAccent),
                label: Text(
                  isKurdish ? 'ڕێکخستنەوە بۆ ٠' : (isArabic ? 'إعادة ضبط' : 'Reset to 0'),
                  style: const TextStyle(color: Colors.orangeAccent, fontSize: 12),
                ),
              ),
          ],
        ),
        Text(
          isKurdish
              ? 'گۆڕانکارییەکان دەستبەجێ لە کاتە ڕاستەقینەکاندا دەردەکەون'
              : (isArabic
                  ? 'تنعكس التعديلات مباشرة على المواقيت الحالية المعروضة'
                  : 'Time updates adjust dynamically on each card in real time'),
          style: AppTheme.englishText(fontSize: 11, color: AppColors.faintText),
        ),
        const SizedBox(height: 12),
        ...prayers.map((p) {
          final id = p['id'] as String;
          final name = isKurdish ? p['ku'] as String : (isArabic ? p['ar'] as String : p['en'] as String);
          final icon = p['icon'] as IconData;
          final currentDt = _previewTimes?[id];
          final offset = _offsets[id] ?? 0;

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: offset != 0
                  ? AppColors.gold.withValues(alpha: 0.1)
                  : AppColors.panelColor,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: offset != 0
                    ? AppColors.gold.withValues(alpha: 0.5)
                    : AppColors.panelBorderColor,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: AppColors.gold, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: AppTheme.kurdishText(
                          fontSize: 14,
                          color: AppColors.cream,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            _formatTime(currentDt),
                            style: AppTheme.englishTitle(
                              fontSize: 15,
                              color: AppColors.gold,
                            ),
                          ),
                          if (offset != 0) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                color: AppColors.gold.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${offset > 0 ? "+$offset" : offset} min',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.gold,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                // Stepper Buttons
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.remove_circle_outline_rounded,
                          color: offset > -30 ? AppColors.gold : Colors.white24),
                      onPressed: () {
                        setState(() {
                          _offsets[id] = (offset - 1).clamp(-30, 30);
                        });
                        _recalculatePreview();
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.add_circle_outline_rounded,
                          color: offset < 30 ? AppColors.gold : Colors.white24),
                      onPressed: () {
                        setState(() {
                          _offsets[id] = (offset + 1).clamp(-30, 30);
                        });
                        _recalculatePreview();
                      },
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  // ================= TAB 2: CALCULATION ENGINE =================
  Widget _buildCalculationMethodTab(bool isKurdish, bool isArabic) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      children: [
        // 1. Asr School Section
        _buildSectionHeader(
          icon: Icons.balance_rounded,
          title: isKurdish
              ? 'مەزهەبی کاتی عەسر (کاتی پڕی سێبەر)'
              : (isArabic ? 'المذهب الفقهي لحساب وقت العصر' : 'Asr Juristic School'),
        ),
        const SizedBox(height: 8),
        _buildRadioSelection(
          title: isKurdish
              ? 'شافعی، مالیکی، حەنبەلی، جەعفەری (کاتی فەرمی)'
              : (isArabic ? 'الشافعي، المالكي، الحنبلي، الجعفري' : 'Shafi, Maliki, Hanbali, Ja\'fari'),
          subtitle: isKurdish
              ? 'سێبەری شتەکە یەکسان بێت بە درێژییەکەی (فاکتەری ١)'
              : (isArabic ? 'ظل الشيء يساوي طوله (المعيار السائد)' : 'Shadow length equals object length (Factor 1)'),
          value: 'shafi',
          groupValue: _selectedAsrSchool,
          onSelected: (val) {
            setState(() => _selectedAsrSchool = val);
            _recalculatePreview();
          },
        ),
        _buildRadioSelection(
          title: isKurdish ? 'حەنەفی' : (isArabic ? 'الحنفي' : 'Hanafi'),
          subtitle: isKurdish
              ? 'سێبەری شتەکە دوو ئەوەندەی درێژییەکەیەتی (فاکتەری ٢)'
              : (isArabic ? 'ظل الشيء يساوي مثليه (عصر متأخر)' : 'Shadow length is twice object length (Factor 2)'),
          value: 'hanafi',
          groupValue: _selectedAsrSchool,
          onSelected: (val) {
            setState(() => _selectedAsrSchool = val);
            _recalculatePreview();
          },
        ),

        const SizedBox(height: 20),

        // 2. High Latitude Rule
        _buildSectionHeader(
          icon: Icons.public_rounded,
          title: isKurdish
              ? 'یاسای ناوچە بەرزەکان (ئەورووپا و وڵاتانی باکوور)'
              : (isArabic ? 'قاعدة خطوط العرض العليا' : 'High Latitude Rule'),
        ),
        const SizedBox(height: 8),
        _buildRadioSelection(
          title: isKurdish ? 'نیوەی شەو (Middle of the night)' : (isArabic ? 'منتصف الليل' : 'Middle of Night'),
          subtitle: isKurdish
              ? 'کاتی فەجر و عیشا لە نیوەی شەودا سنووردار دەکرێن'
              : (isArabic ? 'تحديد الشفق بمنتصف الليل' : 'Cap twilight duration by half of night'),
          value: 'night_middle',
          groupValue: _selectedHighLatRule,
          onSelected: (val) {
            setState(() => _selectedHighLatRule = val);
            _recalculatePreview();
          },
        ),
        _buildRadioSelection(
          title: isKurdish ? 'یەک لە حەوت (1/7th of Night)' : (isArabic ? 'سُبع الليل' : 'One Seventh'),
          subtitle: isKurdish
              ? 'کاتی تاریکی بە یەک لە حەوتی شەو سنووردار دەکرێت'
              : (isArabic ? 'تحديد وقت الفجر والعشاء بسبع الليل' : 'Cap twilight by 1/7th of night'),
          value: 'one_seventh',
          groupValue: _selectedHighLatRule,
          onSelected: (val) {
            setState(() => _selectedHighLatRule = val);
            _recalculatePreview();
          },
        ),
        _buildRadioSelection(
          title: isKurdish ? 'بەپێی گۆشە (Angle-Based Rule)' : (isArabic ? 'حسب الزاوية النسبية' : 'Angle Based'),
          subtitle: isKurdish
              ? 'سنووردانان بەپێی گۆشەی حیسابکراوی فەلەکی'
              : (isArabic ? 'تحديد نسبي دقيق لدرجات الفجر والعشاء' : 'Proportional angle calculation'),
          value: 'angle_based',
          groupValue: _selectedHighLatRule,
          onSelected: (val) {
            setState(() => _selectedHighLatRule = val);
            _recalculatePreview();
          },
        ),

        const SizedBox(height: 20),

        // 3. Calculation Method Picker
        _buildSectionHeader(
          icon: Icons.explore_rounded,
          title: isKurdish
              ? 'دەستەی دیاریکردنی گۆشەی فەلەکی'
              : (isArabic ? 'طريقة وهيئة الحساب الفلكي' : 'Calculation Method Standard'),
        ),
        const SizedBox(height: 8),
        ...CalculationMethod.allMethods.map((method) {
          final isSelected = _selectedMethodId == method.id;
          final isKurdistan = method.id == 'kurdistan_endowments';

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.gold.withValues(alpha: 0.12)
                  : AppColors.panelColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? AppColors.gold
                    : AppColors.panelBorderColor,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            // ignore: deprecated_member_use
            child: RadioListTile<String>(
              value: method.id,
              // ignore: deprecated_member_use
              groupValue: _selectedMethodId,
              // ignore: deprecated_member_use
              onChanged: (val) {
                if (val != null) {
                  setState(() => _selectedMethodId = val);
                  _recalculatePreview();
                }
              },
              // ignore: deprecated_member_use
              activeColor: AppColors.gold,
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      isKurdish
                          ? method.nameKu
                          : (isArabic ? method.nameAr : method.nameEn),
                      style: AppTheme.kurdishText(
                        fontSize: 13,
                        color: isSelected ? AppColors.gold : AppColors.cream,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (isKurdistan)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'کوردستان',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.greenAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              subtitle: Text(
                'Fajr: ${method.fajrAngle}° | Isha: ${method.ishaIntervalMinutes != null ? "+${method.ishaIntervalMinutes}m" : "${method.ishaAngle}°"}',
                style: AppTheme.englishText(fontSize: 11, color: AppColors.faintText),
              ),
            ),
          );
        }),
      ],
    );
  }

  // ================= TAB 3: AZAN & PRE-AZAN REMINDERS =================
  Widget _buildAzanAndRemindersTab(bool isKurdish, bool isArabic) {
    const reminderOptions = [0, 5, 10, 15, 20, 30];

    const azanSounds = [
      {'id': 'makkah', 'nameKu': 'بانگی مەککەی پیرۆز', 'nameAr': 'أذان مكة المكرمة', 'nameEn': 'Makkah Adhan'},
      {'id': 'madinah', 'nameKu': 'بانگی مەدینەی منەوەرە', 'nameAr': 'أذان المدينة المنورة', 'nameEn': 'Madinah Adhan'},
      {'id': 'aqsa', 'nameKu': 'بانگی مزگەوتی ئەقسا', 'nameAr': 'أذان المسجد الأقصى', 'nameEn': 'Al-Aqsa Adhan'},
      {'id': 'abdulbasit', 'nameKu': 'شێخ عەبدولباست عەبدولسەمەد', 'nameAr': 'الشيخ عبدالباسط', 'nameEn': 'Abdul Basit'},
      {'id': 'mishary', 'nameKu': 'میشاری ڕاشد ئەلعەفاسی', 'nameAr': 'مشاري العفاسي', 'nameEn': 'Mishary Alafasy'},
      {'id': 'haram_classic', 'nameKu': 'بانگی کلاسیکی حەڕەم', 'nameAr': 'أذان الحرم الكلاسيكي', 'nameEn': 'Haram Classic'},
      {'id': 'riyadh', 'nameKu': 'بانگی مزگەوتەکانی ڕیاز', 'nameAr': 'أذان الرياض', 'nameEn': 'Riyadh Adhan'},
      {'id': 'dubai', 'nameKu': 'بانگی مزگەوتی گەورەی دوبەی', 'nameAr': 'أذان دبي', 'nameEn': 'Dubai Adhan'},
      {'id': 'azan_short', 'nameKu': 'بانگی کورتی ئەلعەفاسی (تەنها دێڕێک)', 'nameAr': 'أذان قصير', 'nameEn': 'Short Adhan (Tone)'},
      {'id': 'azan_fajr', 'nameKu': 'بانگی تایبەتی بەیانی (الصلاة خير من النوم)', 'nameAr': 'أذان الفجر الخاص', 'nameEn': 'Melodic Fajr Adhan'},
    ];

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      children: [
        // 1. Pre-Azan Reminder Section
        _buildSectionHeader(
          icon: Icons.alarm_rounded,
          title: isKurdish
              ? 'ئاگادارکردنەوەی پێش بانگ (بۆ دەستنوێژ و ئامادەکاری)'
              : (isArabic ? 'تنبيه قبل الأذان (للوضوء والاستعداد)' : 'Pre-Azan Reminder (Wudu Alert)'),
        ),
        const SizedBox(height: 6),
        Text(
          isKurdish
              ? 'ئاگاداری پێشوەختە وەردەگریت پێش گەیشتنی کاتی بانگ'
              : (isArabic
                  ? 'يرسل التطبيق تنبيهاً لطيفاً للاستعداد قبل دخول وقت الصلاة'
                  : 'Receive a gentle reminder before the actual prayer time arrives'),
          style: AppTheme.englishText(fontSize: 11, color: AppColors.faintText),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: reminderOptions.map((mins) {
            final isSelected = _selectedPreAzanMinutes == mins;
            final label = mins == 0
                ? (isKurdish ? 'ناچالاکە' : (isArabic ? 'معطل' : 'Off'))
                : (isKurdish ? '$mins خولەک پێشتر' : (isArabic ? '$mins دقائق قبل' : '$mins min before'));

            return ChoiceChip(
              label: Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.black : AppColors.cream,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              selected: isSelected,
              selectedColor: AppColors.gold,
              backgroundColor: AppColors.panelColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: isSelected ? AppColors.gold : AppColors.panelBorderColor,
                ),
              ),
              onSelected: (_) {
                setState(() => _selectedPreAzanMinutes = mins);
              },
            );
          }).toList(),
        ),

        const SizedBox(height: 20),

        // 2. Global Azan Voice Selector with Instant Audio Preview
        _buildSectionHeader(
          icon: Icons.volume_up_rounded,
          title: isKurdish
              ? 'دەنگی گشتی بانگ (پێشبینین و هەڵبژاردن)'
              : (isArabic ? 'صوت الأذان العام (معاينة واختيار)' : 'Azan Audio Selection & Preview'),
        ),
        const SizedBox(height: 10),
        ...azanSounds.map((sound) {
          final id = sound['id'] as String;
          final isSelected = _selectedAzanSound == id;
          final isPlaying = _previewPlayingSound == id;
          final title = isKurdish
              ? sound['nameKu']!
              : (isArabic ? sound['nameAr']! : sound['nameEn']!);

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.gold.withValues(alpha: 0.12)
                  : AppColors.panelColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? AppColors.gold
                    : AppColors.panelBorderColor,
              ),
            ),
            child: Row(
              children: [
                // Radio select
                // ignore: deprecated_member_use
                Radio<String>(
                  value: id,
                  // ignore: deprecated_member_use
                  groupValue: _selectedAzanSound,
                  // ignore: deprecated_member_use
                  activeColor: AppColors.gold,
                  // ignore: deprecated_member_use
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _selectedAzanSound = val);
                    }
                  },
                ),
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _selectedAzanSound = id),
                    child: Text(
                      title,
                      style: AppTheme.kurdishText(
                        fontSize: 13,
                        color: isSelected ? AppColors.gold : AppColors.cream,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                // Audio preview button
                IconButton(
                  icon: Icon(
                    isPlaying ? Icons.stop_circle_rounded : Icons.play_circle_fill_rounded,
                    color: isPlaying ? Colors.redAccent : AppColors.gold,
                    size: 28,
                  ),
                  tooltip: isPlaying ? 'Stop' : 'Play Preview',
                  onPressed: () => _toggleAudioPreview(id),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  // ================= TAB 4: HIJRI DATE CALIBRATION =================
  Widget _buildHijriCalibrationTab(bool isKurdish, bool isArabic) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      children: [
        _buildSectionHeader(
          icon: Icons.nightlight_round,
          title: isKurdish
              ? 'تەعدیلی مێژووی کۆچی (ڕوانینی مانگ)'
              : (isArabic ? 'تعديل التقويم الهجري (رؤية الهلال)' : 'Hijri Calendar Correction'),
        ),
        const SizedBox(height: 6),
        Text(
          isKurdish
              ? 'بەهۆی جیاوازی دەرکەوتنی مانگ لە نێوان وڵاتان، دەتوانیت ڕۆژی کۆچی بە دەستی لە نێوان -٢ بۆ +٢ ڕۆژ بگۆڕیت.'
              : (isArabic
                  ? 'بسبب اختلاف رؤية الهلال، يمكنك تقديم أو تأخير التاريخ الهجري يدوياً بين -2 إلى +2 يوم.'
                  : 'Due to lunar sighting variations, you can adjust the Hijri calendar by -2 to +2 days.'),
          style: AppTheme.englishText(fontSize: 11, color: AppColors.faintText),
        ),
        const SizedBox(height: 20),

        // Live Hijri Date Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.gold.withValues(alpha: 0.18),
                AppColors.panelColor,
              ],
            ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.gold.withValues(alpha: 0.5)),
          ),
          child: Column(
            children: [
              Icon(Icons.auto_awesome, color: AppColors.gold, size: 28),
              const SizedBox(height: 8),
              Text(
                isKurdish
                    ? 'مێژووی کۆچی هەڵبژێردراو بۆ ئەمڕۆ:'
                    : (isArabic ? 'التاريخ الهجري المعتمد لليوم:' : 'Active Hijri Date for Today:'),
                style: AppTheme.kurdishText(fontSize: 12, color: AppColors.mutedText),
              ),
              const SizedBox(height: 6),
              Text(
                _previewHijriDate?.formatted(AppLocalizations.languageCode) ??
                    '-- / -- / ----',
                textAlign: TextAlign.center,
                style: AppTheme.kurdishTitle(
                  fontSize: 20,
                  color: AppColors.gold,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Stepper for Hijri offset
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.panelColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.panelBorderColor),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isKurdish
                    ? 'تەعدیلی ڕۆژەکان:'
                    : (isArabic ? 'تعديل الأيام:' : 'Day Offset:'),
                style: AppTheme.kurdishText(
                  fontSize: 14,
                  color: AppColors.cream,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.remove_circle_outline_rounded,
                      color: _selectedHijriOffset > -2
                          ? AppColors.gold
                          : Colors.white24,
                    ),
                    onPressed: _selectedHijriOffset > -2
                        ? () {
                            setState(() => _selectedHijriOffset--);
                            _recalculatePreview();
                          }
                        : null,
                  ),
                  Container(
                    width: 60,
                    alignment: Alignment.center,
                    child: Text(
                      '${_selectedHijriOffset > 0 ? "+$_selectedHijriOffset" : _selectedHijriOffset} ${isKurdish ? "ڕۆژ" : (isArabic ? "يوم" : "days")}',
                      style: AppTheme.englishTitle(
                        fontSize: 14,
                        color: AppColors.gold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.add_circle_outline_rounded,
                      color: _selectedHijriOffset < 2
                          ? AppColors.gold
                          : Colors.white24,
                    ),
                    onPressed: _selectedHijriOffset < 2
                        ? () {
                            setState(() => _selectedHijriOffset++);
                            _recalculatePreview();
                          }
                        : null,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ================= COMMON HELPERS =================
  Widget _buildSectionHeader({required IconData icon, required String title}) {
    return Row(
      children: [
        Icon(icon, color: AppColors.gold, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: AppTheme.kurdishTitle(fontSize: 14, color: AppColors.gold),
          ),
        ),
      ],
    );
  }

  Widget _buildRadioSelection({
    required String title,
    required String subtitle,
    required String value,
    required String groupValue,
    required ValueChanged<String> onSelected,
  }) {
    final isSelected = value == groupValue;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.gold.withValues(alpha: 0.12)
            : AppColors.panelColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? AppColors.gold : AppColors.panelBorderColor,
          width: isSelected ? 1.5 : 1,
        ),
      ),
      // ignore: deprecated_member_use
      child: RadioListTile<String>(
        value: value,
        // ignore: deprecated_member_use
        groupValue: groupValue,
        // ignore: deprecated_member_use
        onChanged: (val) {
          if (val != null) onSelected(val);
        },
        // ignore: deprecated_member_use
        activeColor: AppColors.gold,
        title: Text(
          title,
          style: AppTheme.kurdishText(
            fontSize: 13,
            color: isSelected ? AppColors.gold : AppColors.cream,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: AppTheme.englishText(fontSize: 11, color: AppColors.faintText),
        ),
      ),
    );
  }
}
