import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../app_localizations.dart';
import '../models/azkar_model.dart';
import '../services/app_haptics.dart';
import '../services/notification_service.dart';
import '../services/offline_prayer_calculator.dart';
import '../services/prayer_repository.dart';
import '../services/storage_service.dart';
import '../widgets/app_theme.dart';
import '../widgets/location_selector_sheet.dart';
import '../widgets/prayer_settings_sheet.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with WidgetsBindingObserver {
  late Future<UserProfile?> _profileFuture;
  bool _notifications = true;
  bool _haptic = true;
  String _currentLang = 'ku';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    AppThemeController.instance.addListener(_onThemeChanged);
    _profileFuture = StorageService.getUserProfile();
    _loadSettings();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    AppThemeController.instance.removeListener(_onThemeChanged);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadSettings();
    }
  }

  void _onThemeChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _loadSettings() async {
    final notif = await StorageService.readSetting('notifications', defaultValue: true);
    final haptic = await StorageService.readSetting('haptic', defaultValue: true);
    final lang = await StorageService.readSetting('language', defaultValue: 'ku');
    if (mounted) {
      setState(() {
        _notifications = notif;
        _haptic = haptic;
        _currentLang = lang;
      });
    }
  }

  Future<void> _onRefresh() async {
    AppHaptics.selectionClick();
    await _loadSettings();
    setState(() {
      _profileFuture = StorageService.getUserProfile();
    });
    await _profileFuture;
  }

  Future<void> _changeLanguage(String code) async {
    AppLocalizations.setLanguageCode(code);
    await StorageService.saveSetting('language', code);
    setState(() => _currentLang = code);
    if (mounted) {
      setState(() {});
    }
  }



  void _showThemePickerSheet(BuildContext context, bool isKurdish) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final currentPalette = AppThemeController.instance.palette;

            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.85,
              ),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.darkPanel,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                border: Border.all(color: AppColors.gold.withValues(alpha: 0.4), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.7),
                    blurRadius: 35,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  children: [
                  Container(
                    width: 48,
                    height: 5,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Icon(Icons.palette_rounded, color: AppColors.gold, size: 22),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                isKurdish ? 'هەڵبژاردنی ڕووکار • Choose Theme' : 'Choose Theme',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: isKurdish
                                    ? AppTheme.kurdishTitle(fontSize: 18, color: AppColors.gold)
                                    : AppTheme.englishTitle(fontSize: 18, color: AppColors.gold),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.close_rounded, color: AppColors.faintText),
                      ),
                    ],
                  ),
                  const Divider(color: Colors.white10, height: 16),
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 1.25,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: AppPalettes.values.length,
                      itemBuilder: (context, index) {
                        final palette = AppPalettes.values[index];
                        final isSelected = currentPalette.key == palette.key;

                        return GestureDetector(
                          onTap: () async {
                            await AppThemeController.instance.setPalette(palette.key);
                            setSheetState(() {});
                            if (mounted) setState(() {});
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: palette.softSurface,
                              border: Border.all(
                                color: isSelected ? palette.gold : palette.panelBorderColor,
                                width: isSelected ? 2.0 : 1.0,
                              ),
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: palette.gold.withValues(alpha: 0.35),
                                        blurRadius: 10,
                                        spreadRadius: 1,
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        isKurdish ? palette.labelKu : palette.label,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: isSelected ? palette.gold : palette.cream,
                                        ),
                                      ),
                                    ),
                                    if (isSelected)
                                      Icon(Icons.check_circle_rounded, color: palette.gold, size: 16),
                                  ],
                                ),
                                Row(
                                  children: [
                                    _colorDot(palette.darkBg),
                                    const SizedBox(width: 4),
                                    _colorDot(palette.softSurface),
                                    const SizedBox(width: 4),
                                    _colorDot(palette.gold),
                                    const SizedBox(width: 4),
                                    _colorDot(palette.accent1),
                                  ],
                                ),
                                Text(
                                  palette.description,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontSize: 9, color: palette.faintText),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
          },
        );
      },
    );
  }



  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isKurdish = _currentLang == 'ku';
    final currentPalette = AppThemeController.instance.palette;

    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.darkBg, AppColors.darkBgAlt, AppColors.panelColor],
          ),
        ),
        child: SafeArea(
          child: FutureBuilder<UserProfile?>(
            future: _profileFuture,
            builder: (context, snapshot) {
              final profile = snapshot.data;
              return RefreshIndicator(
                color: AppColors.gold,
                backgroundColor: AppColors.darkPanel,
                onRefresh: _onRefresh,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics()),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        loc?.translate('settings') ?? 'ڕێکخستنەکان',
                        style: isKurdish
                            ? AppTheme.kurdishTitle(fontSize: 24, color: AppColors.gold)
                            : AppTheme.englishTitle(fontSize: 24, color: AppColors.gold),
                      ),
                    ),
                    if (profile != null)
                      _buildUserProfileCard(profile, isKurdish, _currentLang),

                    // Language Selector Settings Card (After-Tap Selection)
                    Text(
                      loc?.translate('language') ?? 'زمان',
                      style: isKurdish ? AppTheme.kurdishTitle(fontSize: 14, color: AppColors.gold) : AppTheme.labelText(color: AppColors.mutedText),
                    ),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: () => _showLanguagePickerSheet(context, isKurdish),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.panelColor,
                          border: Border.all(color: AppColors.gold.withValues(alpha: 0.35)),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.gold.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(Icons.translate_rounded, color: AppColors.gold, size: 22),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isKurdish
                                        ? 'زمانی بەرنامە'
                                        : (_currentLang == 'ar' ? 'لغة التطبيق' : 'App Language'),
                                    style: isKurdish
                                        ? AppTheme.kurdishTitle(fontSize: 15, color: AppColors.cream)
                                        : AppTheme.englishText(fontSize: 15, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _getLangDisplayName(_currentLang),
                                    style: AppTheme.englishText(fontSize: 12, color: AppColors.gold),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              isKurdish
                                  ? Icons.chevron_left_rounded
                                  : Icons.chevron_right_rounded,
                              color: AppColors.gold,
                              size: 24,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Theme Selector Settings Card
                    Text(
                      loc?.translate('theme') ?? 'ڕووکار',
                      style: isKurdish ? AppTheme.kurdishTitle(fontSize: 14, color: AppColors.gold) : AppTheme.labelText(color: AppColors.mutedText),
                    ),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: () => _showThemePickerSheet(context, isKurdish),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.panelColor,
                          border: Border.all(color: AppColors.gold.withValues(alpha: 0.35)),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.gold.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(Icons.palette_rounded, color: AppColors.gold, size: 22),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isKurdish ? 'هەڵبژاردنی ڕووکار' : 'Choose Theme',
                                    style: isKurdish
                                        ? AppTheme.kurdishTitle(fontSize: 15, color: AppColors.cream)
                                        : AppTheme.englishText(fontSize: 15, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${isKurdish ? currentPalette.labelKu : currentPalette.label} · (8 ${isKurdish ? 'ڕووکار' : 'Themes'})',
                                    style: AppTheme.englishText(fontSize: 12, color: AppColors.gold),
                                  ),
                                ],
                              ),
                            ),
                            Icon(Icons.chevron_right_rounded, color: AppColors.gold, size: 22),
                          ],
                        ),
                      ),
                    ),



                    const SizedBox(height: 24),

                    // Prayer Times & Azan Settings Card
                    Text(
                      isKurdish
                          ? 'مواقیت و بانگدان'
                          : (_currentLang == 'ar'
                              ? 'مواقيت الصلاة والأذان'
                              : 'Prayer Times & Azan'),
                      style: isKurdish
                          ? AppTheme.kurdishTitle(
                              fontSize: 14, color: AppColors.gold)
                          : AppTheme.labelText(color: AppColors.mutedText),
                    ),
                    const SizedBox(height: 10),
                    _buildPrayerLocationCard(isKurdish, _currentLang),
                    const SizedBox(height: 10),
                    _buildPrayerSettingsCard(isKurdish, _currentLang),

                    const SizedBox(height: 24),

                    // Preferences & Toggles Section
                    Text(
                      isKurdish ? 'تایبەتمەندییەکان' : 'Preferences',
                      style: isKurdish ? AppTheme.kurdishTitle(fontSize: 14, color: AppColors.gold) : AppTheme.labelText(color: AppColors.mutedText),
                    ),
                    const SizedBox(height: 10),
                    _buildSettingToggle(
                      loc?.translate('enableReminders') ?? 'ئاگادارکردنەوەی ڕۆژانە',
                      loc?.translate('reminderTime') ?? 'کاتی بەیانیان و ئێواران',
                      _notifications,
                      (value) async {
                        setState(() => _notifications = value);
                        await StorageService.saveSetting('notifications', value);
                        await NotificationService.rescheduleUpcomingPrayerAzans();
                      },
                      isKurdish,
                    ),
                    const SizedBox(height: 10),
                    _buildSettingToggle(
                      loc?.translate('haptic') ?? 'لەرزینی هەستپێکردن',
                      isKurdish ? 'لەرزین لەکاتی کرتەکردندا' : 'Vibrate on count tap',
                      _haptic,
                      (value) async {
                        setState(() => _haptic = value);
                        await StorageService.saveSetting('haptic', value);
                        if (value) {
                          AppHaptics.mediumImpact();
                        }
                      },
                      isKurdish,
                    ),

                    const SizedBox(height: 24),

                    // About App Interactive Section
                    Text(
                      isKurdish
                          ? 'دەربارەی بەرنامە'
                          : (_currentLang == 'ar' ? 'عن التطبيق' : 'About App'),
                      style: isKurdish
                          ? AppTheme.kurdishTitle(
                              fontSize: 14, color: AppColors.gold)
                          : AppTheme.labelText(color: AppColors.mutedText),
                    ),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: () =>
                          _showAboutAppDialog(context, _currentLang, isKurdish),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.gold.withValues(alpha: 0.12),
                              AppColors.panelColor,
                            ],
                          ),
                          border: Border.all(
                            color: AppColors.gold.withValues(alpha: 0.4),
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.gold.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(Icons.auto_awesome_rounded,
                                  color: AppColors.gold, size: 22),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isKurdish
                                        ? 'دەربارەی ئەپی نەدا (Nada)'
                                        : (_currentLang == 'ar'
                                            ? 'عن تطبيق نَدَى'
                                            : 'About Nada App'),
                                    style: isKurdish
                                        ? AppTheme.kurdishTitle(
                                            fontSize: 15,
                                            color: AppColors.cream)
                                        : AppTheme.englishTitle(
                                            fontSize: 14,
                                            color: AppColors.cream),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    isKurdish
                                        ? 'یادی خودا'
                                        : (_currentLang == 'ar'
                                            ? 'الذكر، الرسالة والمطور'
                                            : 'Mission, Dhikr & Creator'),
                                    style: isKurdish
                                        ? AppTheme.kurdishText(
                                            fontSize: 11,
                                            color: AppColors.gold)
                                        : AppTheme.englishText(
                                            fontSize: 11,
                                            color: AppColors.gold),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              isKurdish
                                  ? Icons.arrow_back_ios_new_rounded
                                  : Icons.arrow_forward_ios_rounded,
                              color: AppColors.gold,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Send Feedback Interactive Card
                    GestureDetector(
                      onTap: () =>
                          _showFeedbackSheet(context, _currentLang, isKurdish),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.gold.withValues(alpha: 0.12),
                              AppColors.panelColor,
                            ],
                          ),
                          border: Border.all(
                            color: AppColors.gold.withValues(alpha: 0.4),
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.gold.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(Icons.mark_email_read_rounded,
                                  color: AppColors.gold, size: 22),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isKurdish
                                        ? 'ناردنی سەرنج و پێشنیار'
                                        : (_currentLang == 'ar'
                                            ? 'إرسال الملاحظات والاقتراحات'
                                            : 'Send Feedback & Suggestions'),
                                    style: isKurdish
                                        ? AppTheme.kurdishTitle(
                                            fontSize: 15,
                                            color: AppColors.cream)
                                        : AppTheme.englishTitle(
                                            fontSize: 14,
                                            color: AppColors.cream),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    isKurdish
                                        ? 'پەیامەکەت ڕاستەوخۆ بۆ گەشەپێدەر دەچێت'
                                        : (_currentLang == 'ar'
                                            ? 'رسالتك تصل مباشرة إلى المطور'
                                            : 'Your message goes directly to the developer'),
                                    style: isKurdish
                                        ? AppTheme.kurdishText(
                                            fontSize: 11,
                                            color: AppColors.gold)
                                        : AppTheme.englishText(
                                            fontSize: 11,
                                            color: AppColors.gold),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              isKurdish
                                  ? Icons.arrow_back_ios_new_rounded
                                  : Icons.arrow_forward_ios_rounded,
                              color: AppColors.gold,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // App Information & Developer Footer
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppColors.panelColor,
                            AppColors.softSurface.withValues(alpha: 0.8),
                          ],
                        ),
                        border: Border.all(
                            color: AppColors.gold.withValues(alpha: 0.25)),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 68,
                            height: 68,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.gold.withValues(alpha: 0.25),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(18),
                              child: Image.asset('assets/icon/app_icon.png',
                                  fit: BoxFit.cover),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text('نەدا • NADA',
                              style: AppTheme.englishTitle(
                                  fontSize: 20, color: AppColors.gold)),
                          const SizedBox(height: 4),
                          Text(
                            loc?.translate('appTagline') ?? 'قورئان و یادی خوا',
                            style: isKurdish
                                ? AppTheme.kurdishText(
                                    fontSize: 13,
                                    color: AppColors.gold,
                                    fontWeight: FontWeight.bold)
                                : AppTheme.englishText(
                                    fontSize: 13,
                                    color: AppColors.gold,
                                    fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.gold.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                  color: AppColors.gold.withValues(alpha: 0.2)),
                            ),
                            child: Text(
                              '« أَلَا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ »',
                              style: AppTheme.arabicTitle(
                                  fontSize: 15, color: AppColors.gold),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Divider(
                              color: AppColors.gold.withValues(alpha: 0.15)),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.code_rounded,
                                  size: 16, color: AppColors.gold),
                              const SizedBox(width: 6),
                              Text(
                                isKurdish
                                    ? 'گەشەپێدەر: زانیار زۆراب ئەحمەد'
                                    : (_currentLang == 'ar'
                                        ? 'تطوير: زانیار زۆراب أحمد'
                                        : 'Crafted by: Zanyar Zorab Ahmed'),
                                style: isKurdish
                                    ? AppTheme.kurdishText(
                                        fontSize: 12,
                                        color: AppColors.gold,
                                        fontWeight: FontWeight.bold)
                                    : (_currentLang == 'ar'
                                        ? AppTheme.arabicText(
                                            fontSize: 12,
                                            color: AppColors.gold)
                                        : AppTheme.englishText(
                                            fontSize: 12,
                                            color: AppColors.gold,
                                            fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'v1.0.0 (Kurdish Edition)',
                            style: AppTheme.englishText(
                                fontSize: 10, color: AppColors.faintText),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPrayerLocationCard(bool isKurdish, String currentLang) {
    final cityId = StorageService.getPrayerSelectedCity();
    final city = WorldCitiesCatalog.byId(cityId);
    final cityName = city.displayName(currentLang);
    final tzAbbr = city.timezoneAbbreviation();
    final isOfficial = city.isKurdistanOfficial;

    final locationTitle = isKurdish
        ? 'شوێن و شاری بانگدان'
        : (currentLang == 'ar' ? 'موقع المدينة للصلاة' : 'Prayer Location & City');

    final statusSubtitle = isOfficial
        ? (isKurdish
            ? '$cityName ($tzAbbr) · خشتەی فەرمی ئەوقاف'
            : (currentLang == 'ar'
                ? '$cityName ($tzAbbr) · الجدول الرسمي للأوقاف'
                : '$cityName ($tzAbbr) · Official Awqaf'))
        : (isKurdish
            ? '$cityName ($tzAbbr) · حیسابکاری فەلەکی GPS'
            : (currentLang == 'ar'
                ? '$cityName ($tzAbbr) · حساب فلكي دقيق'
                : '$cityName ($tzAbbr) · Astronomical Math'));

    return GestureDetector(
      onTap: () {
        AppHaptics.selectionClick();
        LocationSelectorSheet.show(
          context,
          locale: currentLang,
          onLocationSelected: () {
            if (mounted) setState(() {});
          },
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.panelColor,
          border: Border.all(color: AppColors.gold.withValues(alpha: 0.35)),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(Icons.location_on_rounded, color: AppColors.gold, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    locationTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: currentLang == 'ku'
                        ? AppTheme.kurdishTitle(fontSize: 15, color: AppColors.cream)
                        : AppTheme.englishText(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    statusSubtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.englishText(fontSize: 12, color: AppColors.gold),
                  ),
                ],
              ),
            ),
            Icon(
              currentLang == 'ku'
                  ? Icons.chevron_left_rounded
                  : Icons.chevron_right_rounded,
              color: AppColors.gold,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrayerSettingsCard(bool isKurdish, String currentLang) {
    final methodId = StorageService.getPrayerMethod();
    final method = CalculationMethod.byId(methodId);
    final methodName = currentLang == 'ku'
        ? method.nameKu
        : (currentLang == 'ar' ? method.nameAr : method.nameEn);
    final preMins = StorageService.getPreAzanReminderMinutes();
    final hijriOffset = StorageService.getPrayerHijriOffset();
    final cityId = StorageService.getPrayerSelectedCity();
    final city = WorldCitiesCatalog.byId(cityId);
    final cityName = city.displayName(currentLang);
    final tzAbbr = city.timezoneAbbreviation();

    final preAzanSummary = preMins == 0
        ? (currentLang == 'ku'
            ? 'ئاگاداری ڕاستەوخۆ'
            : (currentLang == 'ar' ? 'تنبيه مباشر' : 'At exact time'))
        : (currentLang == 'ku'
            ? '$preMins خولەک پێش بانگ'
            : (currentLang == 'ar' ? 'قبل $preMins د' : '$preMins min before'));

    final hijriSummary = hijriOffset == 0
        ? (currentLang == 'ku'
            ? 'کۆچی: بنەڕەت'
            : (currentLang == 'ar' ? 'هجري: قياسي' : 'Hijri: 0d'))
        : (currentLang == 'ku'
            ? 'کۆچی: ${hijriOffset > 0 ? "+$hijriOffset" : hijriOffset} ڕۆژ'
            : (currentLang == 'ar'
                ? 'هجري: ${hijriOffset > 0 ? "+$hijriOffset" : hijriOffset} يوم'
                : 'Hijri: ${hijriOffset > 0 ? "+$hijriOffset" : hijriOffset}d'));

    return GestureDetector(
      onTap: () {
        AppHaptics.selectionClick();
        PrayerSettingsSheet.show(
          context,
          onSettingsSaved: () {
            if (mounted) setState(() {});
          },
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.panelColor,
          border: Border.all(color: AppColors.gold.withValues(alpha: 0.35)),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(Icons.mosque_rounded, color: AppColors.gold, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currentLang == 'ku'
                        ? 'ڕێکخستنەکانی کاتی بانگ و ئاگادارکردنەوە'
                        : (currentLang == 'ar'
                            ? 'إعدادات مواقيت الصلاة والأذان'
                            : 'Prayer Times & Azan Settings'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: currentLang == 'ku'
                        ? AppTheme.kurdishTitle(fontSize: 15, color: AppColors.cream)
                        : AppTheme.englishText(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$cityName ($tzAbbr) · $methodName · $preAzanSummary · $hijriSummary',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.englishText(fontSize: 12, color: AppColors.gold),
                  ),
                ],
              ),
            ),
            Icon(
              currentLang == 'ku'
                  ? Icons.chevron_left_rounded
                  : Icons.chevron_right_rounded,
              color: AppColors.gold,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  String _getLangDisplayName(String code) {
    switch (code) {
      case 'ku':
        return 'کوردی (سۆرانی) · Kurdish';
      case 'ar':
        return 'العربية · Arabic';
      case 'en':
        return 'English · ئینگلیزی';
      default:
        return 'کوردی (سۆرانی)';
    }
  }

  void _showLanguagePickerSheet(BuildContext context, bool isKurdish) {
    final languages = [
      {
        'code': 'ku',
        'title': 'کوردی (سۆرانی)',
        'subtitle': 'Kurdish (Sorani)',
        'icon': Icons.brightness_5_rounded,
        'badge': 'سەرەکی',
      },
      {
        'code': 'ar',
        'title': 'العربية',
        'subtitle': 'Arabic (لغة القرآن)',
        'icon': Icons.auto_stories_rounded,
        'badge': 'فصيح',
      },
      {
        'code': 'en',
        'title': 'English',
        'subtitle': 'English (International)',
        'icon': Icons.language_rounded,
        'badge': 'Global',
      },
    ];

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.darkPanel,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            border: Border.all(color: AppColors.gold.withValues(alpha: 0.4), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.7),
                blurRadius: 35,
                spreadRadius: 5,
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
              Container(
                width: 48,
                height: 5,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(Icons.translate_rounded, color: AppColors.gold, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isKurdish
                              ? 'هەڵبژاردنی زمانی بەرنامە'
                              : (_currentLang == 'ar' ? 'اختيار لغة التطبيق' : 'Select App Language'),
                          style: isKurdish
                              ? AppTheme.kurdishTitle(fontSize: 18, color: AppColors.cream)
                              : AppTheme.englishText(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          isKurdish
                              ? 'تەواوی نوسین و بەشەکان دەگۆڕدرێن'
                              : (_currentLang == 'ar'
                                  ? 'سيتم تغيير لغة الواجهة بالكامل'
                                  : 'The entire UI will update immediately'),
                          style: AppTheme.englishText(fontSize: 12, color: AppColors.mutedText),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ...languages.map((item) {
                final code = item['code'] as String;
                final title = item['title'] as String;
                final subtitle = item['subtitle'] as String;
                final icon = item['icon'] as IconData;
                final badge = item['badge'] as String;
                final isSelected = _currentLang == code;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GestureDetector(
                    onTap: () async {
                      AppHaptics.selectionClick();
                      await _changeLanguage(code);
                      if (ctx.mounted) {
                        Navigator.pop(ctx);
                      }
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.gold.withValues(alpha: 0.18)
                            : AppColors.panelColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.gold
                              : AppColors.panelBorderColor,
                          width: isSelected ? 1.8 : 1.0,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.gold
                                  : AppColors.gold.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              icon,
                              size: 20,
                              color: isSelected ? AppColors.darkBg : AppColors.gold,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: isSelected ? AppColors.gold : AppColors.cream,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.gold.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        badge,
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.gold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  subtitle,
                                  style: AppTheme.englishText(
                                    fontSize: 12,
                                    color: AppColors.mutedText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: AppColors.gold,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.check_rounded, color: AppColors.darkBg, size: 16),
                            )
                          else
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.panelBorderColor, width: 1.5),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  },
);
  }

  Widget _buildSettingToggle(String label, String description, bool value, Function(bool) onChanged, bool isKurdish) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.panelColor,
        border: Border.all(color: AppColors.panelBorderColor),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: isKurdish ? AppTheme.kurdishTitle(fontSize: 14, color: AppColors.cream) : AppTheme.englishText(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: isKurdish ? AppTheme.kurdishText(fontSize: 11, color: AppColors.faintText) : AppTheme.englishText(fontSize: 11, color: AppColors.faintText),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Toggle(value: value, onChange: onChanged),
        ],
      ),
    );
  }

  void _showAboutAppDialog(
      BuildContext context, String lang, bool isKurdish) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.darkBg,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
                color: AppColors.gold.withValues(alpha: 0.4), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.6),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.gold.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(Icons.auto_awesome_rounded,
                                color: AppColors.gold, size: 20),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              isKurdish
                                  ? 'دەربارەی ئەپی نەدا'
                                  : (lang == 'ar' ? 'عن تطبيق نَدَى' : 'About Nada App'),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: isKurdish
                                  ? AppTheme.kurdishTitle(
                                      fontSize: 17, color: AppColors.gold)
                                  : AppTheme.englishTitle(
                                      fontSize: 17, color: AppColors.gold),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close_rounded, color: AppColors.cream),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                // App Icon & Title Header
                Center(
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.gold.withValues(alpha: 0.25),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: Image.asset(
                            'assets/icon/nada_app_icon_squircle.png',
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        isKurdish
                            ? 'نەدا: قورئان و یادی خوا'
                            : (lang == 'ar'
                                ? 'ندا: القرآن وذكر الله'
                                : 'Nada: Quran & Dhikr'),
                        textAlign: TextAlign.center,
                        style: isKurdish
                            ? AppTheme.kurdishTitle(
                                fontSize: 17,
                                color: AppColors.gold)
                            : AppTheme.englishTitle(
                                fontSize: 17,
                                color: AppColors.gold),
                      ),
                      Text(
                        isKurdish
                            ? 'وەشانی 1.0.0 (نوێترین)'
                            : (lang == 'ar'
                                ? 'الإصدار 1.0.0'
                                : 'Version 1.0.0 (Latest)'),
                        style: isKurdish
                            ? AppTheme.kurdishText(
                                fontSize: 11, color: AppColors.faintText)
                            : AppTheme.englishText(
                                fontSize: 11, color: AppColors.faintText),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Quran Verse Badge
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.gold.withValues(alpha: 0.15),
                        AppColors.darkPanel,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: AppColors.gold.withValues(alpha: 0.35)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '﴿ أَلَا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ ﴾',
                        textAlign: TextAlign.center,
                        style: AppTheme.arabicTitle(
                            fontSize: 18, color: AppColors.gold),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        isKurdish
                            ? '«بێگومان تەنها بە یادی خوای گەورە دڵەکان ئارام دەگرن»'
                            : (lang == 'ar'
                                ? 'سورة الرعد - آية 28'
                                : '“Unquestionably, by the remembrance of Allah hearts are assured.” (13:28)'),
                        textAlign: TextAlign.center,
                        style: isKurdish
                            ? AppTheme.kurdishText(
                                fontSize: 12, color: AppColors.cream)
                            : AppTheme.englishText(
                                fontSize: 12, color: AppColors.cream),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // Narrative Message
                Text(
                  isKurdish
                      ? 'یادی خودای پەروەردگار و زیکر و پاڕانەوە چرای ڕێگای ژیانمانە و هەوێنی ئارامی و بەختەوەرییە لە دونیا و قیامەتدا. ئەپی «نەدا» هاتە کایەوە تا ببێتە یاوەر و هاوڕێیەکی دڵسۆز و ڕۆحی بۆ هەموو موسڵمانێک.\n\n'
                          'هەمیشە هەستم بە کەلێنێکی گەورە کردووە کە بە زمانی شیرینی کوردی ئەپێکی ئیسلامی تەواو سەردەمیانە بەردەست بێت ، ئەپێک کە بە بەرزترین ئاست زۆرترین زیکر و فەرموودەی سەروەرمان وە دوعا و قورئانی پیرۆز و تەفسیر و دەنگی قورئانخوێن و کاتە فەرمییەکانی بانگی شارەکانی کوردستان و جیهان لەخۆ بگرێت.\n\n'
                          '«نەدا» هات تا شایستەترین و پاکترین خزمەت پێشکەش بە ئیمانداران و گەلەکەمان بکات.\n\n'
                          'پشتیوان بە خوا لە داهاتوو باشتریش پێشکەش دەکات.'
                      : (lang == 'ar'
                          ? 'ذكر الله تعالى والأدعية المباركة هما نور دروبنا ومنبع الطمأنينة والسعادة في الدنيا والآخرة. انطلق تطبيق «نَدَى» ليكون رفيقاً مخلصاً وروحانياً لكل مسلم في كل لحظة.\n\n'
                              'لطالما كان هناك تطلع وشعور بالحاجة لوجود تطبيق إسلامي شامل وعصري باللغة الكردية؛ تطبيق يجمع بأعلى درجات الإتقان أوسع أبواب الأذكار النبوية، والقرآن الكريم بتفاسيره وتلاوات كبار القراء، مع مواقيت الصلاة الدقيقة لكردستان والعالم.\n\n'
                              'جاء «نَدَى» ليقدم أصدق وأنقى خدمة للمؤمنين ومجتمعنا المبارك.\n\n'
                              'وبإذن الله وتوفيقه، سنقدم الأفضل دائماً في المستقبل.'
                          : 'The remembrance of Allah and sacred supplications are the guiding light of our journey and the true fountain of peace in this life and the hereafter. Nada was created to be a devoted spiritual companion for every Muslim.\n\n'
                              'There has always been a profound aspiration for a comprehensive, modern, and beautiful Islamic app in Kurdish—one crafted to the highest standard to encompass authentic Adhkar, the Holy Quran with Kurdish Tafsir, recitations by  master Qaris, and accurate prayer times for Kurdistan and the world.\n\n'
                              'Nada came to deliver the purest, most elevated service to believers and our community.\n\n'
                              'With Allah’s grace, even greater enhancements will follow in the future.'),
                  textAlign: isKurdish || lang == 'ar'
                      ? TextAlign.justify
                      : TextAlign.left,
                  style: isKurdish
                      ? AppTheme.kurdishText(
                          fontSize: 13,
                          color: AppColors.cream,
                        ).copyWith(height: 1.7)
                      : (lang == 'ar'
                          ? AppTheme.arabicText(
                              fontSize: 13,
                              color: AppColors.cream,
                            ).copyWith(height: 1.7)
                          : AppTheme.englishText(
                              fontSize: 13,
                              color: AppColors.cream,
                            ).copyWith(height: 1.6)),
                ),
                const SizedBox(height: 20),

                // Developer Recognition Box
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.panelColor,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                        color: AppColors.gold.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.person_rounded,
                              color: AppColors.gold, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            isKurdish
                                ? 'گەشەپێدەر و دروستکەر:'
                                : (lang == 'ar'
                                    ? 'تطوير وإعداد:'
                                    : 'Crafted & Developed by:'),
                            style: isKurdish
                                ? AppTheme.kurdishText(
                                    fontSize: 12,
                                    color: AppColors.faintText)
                                : (lang == 'ar'
                                    ? AppTheme.arabicText(
                                        fontSize: 12,
                                        color: AppColors.faintText)
                                    : AppTheme.englishText(
                                        fontSize: 12,
                                        color: AppColors.faintText)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        isKurdish
                            ? 'زانیار زۆراب ئەحمەد'
                            : (lang == 'ar'
                                ? 'زانیار زۆراب أحمد'
                                : 'Zanyar Zorab Ahmed'),
                        style: isKurdish
                            ? AppTheme.kurdishTitle(
                                fontSize: 16, color: AppColors.gold)
                            : (lang == 'ar'
                                ? AppTheme.arabicTitle(
                                    fontSize: 16, color: AppColors.gold)
                                : AppTheme.englishTitle(
                                    fontSize: 16, color: AppColors.gold)),
                      ),
                      if (lang != 'en') ...[
                        const SizedBox(height: 2),
                        Text(
                          'Zanyar Zorab Ahmed',
                          style: AppTheme.englishText(
                              fontSize: 12, color: AppColors.cream),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Text(
                        isKurdish
                            ? '«داواکارین لە پەروەردگار بیکاتە توێشووی خێر و قبووڵی بکات»'
                            : (lang == 'ar'
                                ? '«نسأل الله أن يتقبل هذا العمل وينفع به الجميع»'
                                : '“May Allah accept this humble endeavor and make it a blessing for all.”'),
                        textAlign: TextAlign.center,
                        style: isKurdish
                            ? AppTheme.kurdishText(
                                fontSize: 11, color: AppColors.gold)
                            : (lang == 'ar'
                                ? AppTheme.arabicText(
                                    fontSize: 11, color: AppColors.gold)
                                : AppTheme.englishText(
                                    fontSize: 11, color: AppColors.gold)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.gold,
                    foregroundColor: AppColors.darkBg,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 12),
                  ),
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(
                    isKurdish
                        ? 'داخستن'
                        : (lang == 'ar' ? 'إغلاق' : 'Close'),
                    style: isKurdish
                        ? AppTheme.kurdishTitle(
                            fontSize: 14, color: AppColors.darkBg)
                        : AppTheme.englishTitle(
                            fontSize: 14, color: AppColors.darkBg),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _colorDot(Color color) {
    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white24, width: 0.8),
      ),
    );
  }

  Widget _buildUserProfileCard(
      UserProfile profile, bool isKurdish, String lang) {
    final hasCustomName = profile.name.trim().isNotEmpty;
    final displayName = hasCustomName
        ? profile.name.trim()
        : (isKurdish
            ? 'ئیمانداری خۆشەویست'
            : (lang == 'ar' ? 'أهلاً بك، يا مؤمن' : 'Beloved Believer'));

    String honorificTitle;
    IconData honorificIcon;
    Color honorificColor;
    if (profile.currentStreak >= 30) {
      honorificTitle = isKurdish
          ? 'پێشەنگی زیکر'
          : (lang == 'ar' ? 'سابق بالخيرات' : 'Dhikr Champion');
      honorificIcon = Icons.military_tech_rounded;
      honorificColor = const Color(0xFFFFD700);
    } else if (profile.currentStreak >= 7) {
      honorificTitle = isKurdish
          ? 'دۆستی زیکر'
          : (lang == 'ar' ? 'مواظب على الذكر' : 'Devoted to Dhikr');
      honorificIcon = Icons.verified_rounded;
      honorificColor = const Color(0xFF64FFDA);
    } else if (profile.currentStreak >= 1) {
      honorificTitle = isKurdish
          ? 'ڕێبواری خێر'
          : (lang == 'ar' ? 'سالك طريق النور' : 'Seeker of Light');
      honorificIcon = Icons.auto_awesome_rounded;
      honorificColor = AppColors.gold;
    } else {
      honorificTitle = isKurdish
          ? 'دەستپێکی پیرۆز'
          : (lang == 'ar' ? 'بداية مباركة' : 'Blessed Start');
      honorificIcon = Icons.spa_rounded;
      honorificColor = AppColors.gold.withValues(alpha: 0.85);
    }

    final initialLetter =
        hasCustomName ? displayName.characters.first.toUpperCase() : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.panelColor,
            AppColors.softSurface.withValues(alpha: 0.9),
          ],
        ),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: 0.35),
          width: 1.2,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => _showEditNameDialog(context, profile, isKurdish, lang),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.gold.withValues(alpha: 0.25),
                            AppColors.gold.withValues(alpha: 0.08),
                          ],
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.gold.withValues(alpha: 0.5),
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: hasCustomName
                            ? Text(
                                initialLetter,
                                style: AppTheme.englishTitle(
                                  fontSize: 24,
                                  color: AppColors.gold,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : Icon(
                                Icons.person_rounded,
                                size: 30,
                                color: AppColors.gold,
                              ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  displayName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: isKurdish
                                      ? AppTheme.kurdishTitle(
                                          fontSize: 18, color: AppColors.cream)
                                      : (lang == 'ar'
                                          ? AppTheme.arabicTitle(
                                              fontSize: 18,
                                              color: AppColors.cream)
                                          : AppTheme.englishTitle(
                                              fontSize: 18,
                                              color: AppColors.cream)),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Icon(
                                Icons.edit_rounded,
                                size: 14,
                                color: AppColors.gold.withValues(alpha: 0.7),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: honorificColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: honorificColor.withValues(alpha: 0.35),
                                width: 0.8,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(honorificIcon,
                                    size: 13, color: honorificColor),
                                const SizedBox(width: 4),
                                Text(
                                  honorificTitle,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: honorificColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.gold.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.drive_file_rename_outline_rounded,
                        size: 18,
                        color: AppColors.gold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.darkBg.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.orangeAccent.withValues(alpha: 0.3),
                            width: 0.8,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('🔥', style: TextStyle(fontSize: 14)),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                '${profile.currentStreak} ${isKurdish ? 'ڕۆژ بەردەوامی' : (lang == 'ar' ? 'أيام مواظبة' : 'Days Streak')}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: isKurdish
                                    ? AppTheme.kurdishText(
                                        fontSize: 11,
                                        color: Colors.orangeAccent,
                                        fontWeight: FontWeight.bold)
                                    : AppTheme.englishText(
                                        fontSize: 11,
                                        color: Colors.orangeAccent,
                                        fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.darkBg.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppColors.gold.withValues(alpha: 0.3),
                            width: 0.8,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('📿', style: TextStyle(fontSize: 14)),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                '${profile.totalSessions} ${isKurdish ? 'تەسبیحات' : (lang == 'ar' ? 'جلسات الذكر' : 'Sessions')}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: isKurdish
                                    ? AppTheme.kurdishText(
                                        fontSize: 11,
                                        color: AppColors.gold,
                                        fontWeight: FontWeight.bold)
                                    : AppTheme.englishText(
                                        fontSize: 11,
                                        color: AppColors.gold,
                                        fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showEditNameDialog(
      BuildContext context, UserProfile profile, bool isKurdish, String lang) {
    final controller = TextEditingController(text: profile.name);

    showDialog<void>(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          backgroundColor: AppColors.darkPanel,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(
              color: AppColors.gold.withValues(alpha: 0.45),
              width: 1.5,
            ),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.person_rounded,
                    color: AppColors.gold, size: 22),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  isKurdish
                      ? 'ناوی بەکارهێنەر'
                      : (lang == 'ar' ? 'اسم المستخدم' : 'Your Name'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: isKurdish
                      ? AppTheme.kurdishTitle(fontSize: 17, color: AppColors.cream)
                      : AppTheme.englishTitle(fontSize: 17, color: AppColors.cream),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              Text(
                isKurdish
                    ? 'ناوی خۆت بنووسە تا لە ئەپەکەدا پیشان بدرێت:'
                    : (lang == 'ar'
                        ? 'اكتب اسمك ليتم عرضه في التطبيق:'
                        : 'Enter your name to personalize your experience:'),
                style: isKurdish
                    ? AppTheme.kurdishText(
                        fontSize: 12, color: AppColors.mutedText)
                    : AppTheme.englishText(
                        fontSize: 12, color: AppColors.mutedText),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: controller,
                autofocus: true,
                style: isKurdish
                    ? AppTheme.kurdishText(
                        fontSize: 15, color: AppColors.cream)
                    : AppTheme.englishText(
                        fontSize: 15, color: AppColors.cream),
                textDirection: isKurdish || lang == 'ar'
                    ? TextDirection.rtl
                    : TextDirection.ltr,
                decoration: InputDecoration(
                  hintText: isKurdish
                      ? 'بۆ نموونە: ئەحمەد'
                      : (lang == 'ar' ? 'مثال: أحمد' : 'e.g. Zanyar'),
                  hintStyle: TextStyle(
                    color: AppColors.mutedText.withValues(alpha: 0.6),
                    fontSize: 13,
                  ),
                  filled: true,
                  fillColor: AppColors.panelColor,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: AppColors.gold.withValues(alpha: 0.3),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: AppColors.gold,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: Text(
                isKurdish
                    ? 'پاشگەزبوونەوە'
                    : (lang == 'ar' ? 'إلغاء' : 'Cancel'),
                style: TextStyle(color: AppColors.faintText),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final newName = controller.text.trim();
                final updated = profile.copyWith(name: newName);
                await StorageService.saveUserProfile(updated);
                AppHaptics.selectionClick();
                if (dialogCtx.mounted) Navigator.pop(dialogCtx);
                if (mounted) {
                  setState(() {
                    _profileFuture = StorageService.getUserProfile();
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.gold,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                isKurdish
                    ? 'تۆمارکردن'
                    : (lang == 'ar' ? 'حفظ' : 'Save'),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showFeedbackSheet(
      BuildContext context, String lang, bool isKurdish) {
    final controller = TextEditingController();
    const recipient = 'zanyarzahmed.dev@gmail.com';

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(ctx).size.height * 0.85,
            ),
            padding: const EdgeInsets.fromLTRB(22, 16, 22, 28),
            decoration: BoxDecoration(
              color: AppColors.darkPanel,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(32)),
              border: Border.all(
                  color: AppColors.gold.withValues(alpha: 0.4), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.75),
                  blurRadius: 35,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: SingleChildScrollView(
                child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 4.5,
                      margin: const EdgeInsets.only(bottom: 18),
                      decoration: BoxDecoration(
                        color: AppColors.gold.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.gold.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(Icons.mark_email_read_rounded,
                            color: AppColors.gold, size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isKurdish
                                  ? 'ناردنی سەرنج و پێشنیار'
                                  : (lang == 'ar'
                                      ? 'إرسال ملاحظة أو اقتراح'
                                      : 'Send Feedback & Message'),
                              style: isKurdish
                                  ? AppTheme.kurdishTitle(
                                      fontSize: 18, color: AppColors.cream)
                                  : AppTheme.englishText(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              isKurdish
                                  ? 'بۆ: $recipient'
                                  : (lang == 'ar'
                                      ? 'إلى: $recipient'
                                      : 'To: $recipient'),
                              style: AppTheme.englishText(
                                fontSize: 11,
                                color: AppColors.gold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.panelColor,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: AppColors.gold.withValues(alpha: 0.25),
                      ),
                    ),
                    child: TextField(
                      controller: controller,
                      maxLines: 5,
                      minLines: 4,
                      autofocus: true,
                      style: isKurdish
                          ? AppTheme.kurdishText(
                              fontSize: 14, color: AppColors.cream)
                          : AppTheme.englishText(
                              fontSize: 14, color: AppColors.cream),
                      textDirection: isKurdish || lang == 'ar'
                          ? TextDirection.rtl
                          : TextDirection.ltr,
                      decoration: InputDecoration(
                        hintText: isKurdish
                            ? 'سەرنج، ڕەخنە، پێشنیار یان کێشەکەت لێرە بنووسە...'
                            : (lang == 'ar'
                                ? 'اكتب ملاحظتك، اقتراحك أو مشكلتك هنا...'
                                : 'Write your feedback, suggestion or bug report here...'),
                        hintStyle: isKurdish
                            ? AppTheme.kurdishText(
                                fontSize: 13, color: AppColors.mutedText)
                            : AppTheme.englishText(
                                fontSize: 13, color: AppColors.mutedText),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final text = controller.text.trim();
                      if (text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              isKurdish
                                  ? 'تکایە سەرەتا سەرنج یان پەیامەکەت بنووسە'
                                  : (lang == 'ar'
                                      ? 'يرجى كتابة رسالتك أولاً'
                                      : 'Please write your message first'),
                              style: const TextStyle(color: Colors.white),
                            ),
                            backgroundColor: Colors.redAccent,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                        return;
                      }

                      Navigator.pop(ctx);

                      final subject = isKurdish
                          ? 'سەرنج لەسەر ئەپی نەدا'
                          : (lang == 'ar'
                              ? 'ملاحظات حول تطبيق ندى'
                              : 'Nada App User Feedback');

                      String encodeMailtoParams(Map<String, String> params) {
                        return params.entries
                            .map((e) =>
                                '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
                            .join('&');
                      }

                      final emailUri = Uri(
                        scheme: 'mailto',
                        path: recipient,
                        query: encodeMailtoParams(<String, String>{
                          'subject': subject,
                          'body': text,
                        }),
                      );

                      try {
                        if (await canLaunchUrl(emailUri)) {
                          await launchUrl(emailUri,
                              mode: LaunchMode.externalApplication);
                        } else {
                          await launchUrl(emailUri,
                              mode: LaunchMode.externalApplication);
                        }
                      } catch (_) {}

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                const Icon(Icons.check_circle_rounded,
                                    color: Colors.greenAccent),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    isKurdish
                                        ? 'سوپاس بۆ سەرنج و پێشنیارەکەت بۆ باشترکردنی نەدا!'
                                        : (lang == 'ar'
                                            ? 'شكراً جزيلاً لملاحظاتكم الكريمة!'
                                            : 'Thank you for helping us improve Nada!'),
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                            backgroundColor: AppColors.panelColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                              side: BorderSide(
                                  color: AppColors.gold.withValues(alpha: 0.4)),
                            ),
                            behavior: SnackBarBehavior.floating,
                            duration: const Duration(seconds: 4),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.send_rounded, size: 20),
                    label: Text(
                      isKurdish
                          ? 'ناردنی پەیام'
                          : (lang == 'ar' ? 'إرسال الرسالة' : 'Send Feedback'),
                      style: isKurdish
                          ? AppTheme.kurdishTitle(
                              fontSize: 15, color: Colors.black)
                          : AppTheme.englishTitle(
                              fontSize: 15, color: Colors.black),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.gold,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      },
    );
  }
}

class Toggle extends StatelessWidget {
  final bool value;
  final Function(bool) onChange;

  const Toggle({super.key, required this.value, required this.onChange});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChange(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 50,
        height: 28,
        decoration: BoxDecoration(
          color: value ? AppColors.gold : AppColors.panelColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: value ? AppColors.gold.withValues(alpha: 0.5) : AppColors.panelBorderColor),
        ),
        child: Stack(
          children: [
            Positioned(
              left: value ? 22 : 2,
              top: 2,
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(color: value ? AppColors.darkBg : AppColors.faintText, shape: BoxShape.circle),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
