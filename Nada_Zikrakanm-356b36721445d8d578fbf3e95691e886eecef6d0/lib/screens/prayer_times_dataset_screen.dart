import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../app_localizations.dart';
import '../services/prayer_times_service.dart';
import '../widgets/app_theme.dart';

class PrayerTimesDatasetScreen extends StatefulWidget {
  const PrayerTimesDatasetScreen({Key? key}) : super(key: key);

  @override
  State<PrayerTimesDatasetScreen> createState() => _PrayerTimesDatasetScreenState();
}

class _PrayerTimesDatasetScreenState extends State<PrayerTimesDatasetScreen> {
  late final Future<PrayerTimesCatalog> _catalogFuture;
  Timer? _clockTimer;
  String _city = 'Hawler';
  bool _isLocating = true;
  String? _locationMessage;

  @override
  void initState() {
    super.initState();
    _catalogFuture = PrayerTimesService.load();
    _catalogFuture.then(_setCityFromGps);
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  Future<void> _setCityFromGps(PrayerTimesCatalog catalog) async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        _setLocationStatus('Location services are off. Using Hawler.');
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _setLocationStatus('Location permission was not granted. Using Hawler.');
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
        timeLimit: const Duration(seconds: 8),
      );
      final nearest = _nearestSupportedCity(position.latitude, position.longitude, catalog);
      if (!mounted) return;
      setState(() {
        _city = nearest;
        _isLocating = false;
        _locationMessage = 'Using your location';
      });
    } catch (_) {
      _setLocationStatus('Could not read location. Using Hawler.');
    }
  }

  void _setLocationStatus(String message) {
    if (!mounted) return;
    setState(() {
      _isLocating = false;
      _locationMessage = message;
    });
  }

  String _nearestSupportedCity(double latitude, double longitude, PrayerTimesCatalog catalog) {
    const coordinates = <String, List<double>>{
      'Hawler': [36.1911, 44.0092],
      'Duhok': [36.8617, 42.9992],
      'Zakho': [37.1445, 42.6872],
      'Slemani': [35.5570, 45.4351],
      'Halabja': [35.1778, 45.9861],
      'Kirkuk': [35.4681, 44.3922],
      'Mosul': [36.3350, 43.1189],
      'Baghdad': [33.3152, 44.3661],
      'Basrah': [30.5085, 47.7804],
      'Najaf': [32.0003, 44.3354],
      'Karbala': [32.6160, 44.0249],
      'Ramadi': [33.4256, 43.2992],
      'Tikrit': [34.5970, 43.6769],
      'London': [51.5074, -0.1278],
      'Paris': [48.8566, 2.3522],
      'Berlin': [52.5200, 13.4050],
      'Dubai': [25.2048, 55.2708],
      'Abu Dhabi': [24.4539, 54.3773],
      'Damascus': [33.5138, 36.2765],
      'Homs': [34.7324, 36.7137],
      'Munich': [48.1351, 11.5820],
    };

    var nearest = 'Hawler';
    var shortestDistance = double.infinity;
    for (final entry in coordinates.entries) {
      if (!catalog.cities.containsKey(entry.key)) continue;
      final latDelta = latitude - entry.value[0];
      final lonDelta = longitude - entry.value[1];
      final distance = latDelta * latDelta + lonDelta * lonDelta;
      if (distance < shortestDistance) {
        shortestDistance = distance;
        nearest = entry.key;
      }
    }
    return nearest;
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)?.locale.languageCode ?? 'ku';
    final isKurdish = locale == 'ku';
    final isRtl = locale == 'ku' || locale == 'ar';

    return FutureBuilder<PrayerTimesCatalog>(
      future: _catalogFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _messageScreen(isKurdish ? 'داتای کاتەکانی بانگ نەهاتەوە.' : 'Prayer times could not be loaded.');
        }
        if (!snapshot.hasData) {
          return Scaffold(
            backgroundColor: AppColors.darkBg,
            body: Center(child: CircularProgressIndicator(color: AppColors.gold)),
          );
        }

        final catalog = snapshot.data!;
        final selectedCity = catalog.cities.containsKey(_city) ? _city : catalog.cityNames.first;
        final day = catalog.forDate(selectedCity, DateTime.now());
        final prayers = _prayersFor(day);
        final next = _nextPrayer(prayers);

        return _buildPage(context, catalog, selectedCity, day, prayers, next, locale, isKurdish, isRtl);
      },
    );
  }

  Widget _buildPage(
    BuildContext context,
    PrayerTimesCatalog catalog,
    String city,
    PrayerDay day,
    List<_Prayer> prayers,
    _Prayer next,
    String locale,
    bool isKurdish,
    bool isRtl,
  ) {
    final remaining = next.time.difference(DateTime.now());
    final hours = remaining.inHours.clamp(0, 99).toString().padLeft(2, '0');
    final minutes = (remaining.inMinutes % 60).clamp(0, 59).toString().padLeft(2, '0');
    final seconds = (remaining.inSeconds % 60).clamp(0, 59).toString().padLeft(2, '0');

    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.darkBg, AppColors.darkBgAlt, AppColors.softSurface],
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
            children: [
              Row(
                textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
                children: [
                  Icon(Icons.mosque_rounded, color: AppColors.gold, size: 30),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: isRtl ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        Text(
                          isKurdish ? 'کاتەکانی بانگ' : locale == 'ar' ? 'مواقيت الصلاة' : 'Prayer Times',
                          textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
                          style: isKurdish ? AppTheme.kurdishTitle(fontSize: 23, color: AppColors.gold) : AppTheme.englishTitle(fontSize: 23, color: AppColors.gold),
                        ),
                        Text(
                          _isLocating
                              ? (isKurdish ? 'شوێن دەخوێنرێتەوە...' : 'Finding your location...')
                              : _cityLabel(city, locale),
                          textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
                          style: isKurdish ? AppTheme.kurdishText(fontSize: 12, color: AppColors.faintText) : AppTheme.englishText(fontSize: 12, color: AppColors.faintText),
                        ),
                      ],
                    ),
                  ),
                  if (_isLocating)
                    SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.gold),
                    ),
                  IconButton(
                    tooltip: isKurdish ? 'شار هەڵبژێرە' : 'Choose city',
                    onPressed: () => _chooseCity(context, catalog, locale),
                    icon: Icon(Icons.location_on_outlined, color: AppColors.gold),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [AppColors.gold.withValues(alpha: 0.25), AppColors.accent1.withValues(alpha: 0.14)]),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.gold.withValues(alpha: 0.38)),
                ),
                child: Column(
                  crossAxisAlignment: isRtl ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    Text(isKurdish ? 'بانگی داهاتوو' : locale == 'ar' ? 'الصلاة القادمة' : 'Next prayer', textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr, style: isKurdish ? AppTheme.kurdishText(fontSize: 13, color: AppColors.gold, fontWeight: FontWeight.w700) : AppTheme.englishText(fontSize: 13, color: AppColors.gold, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 10),
                    Row(
                      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
                      children: [
                        Expanded(child: Text(next.label(locale), textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr, style: isKurdish ? AppTheme.kurdishTitle(fontSize: 27, color: AppColors.cream) : AppTheme.englishTitle(fontSize: 27, color: AppColors.cream))),
                        const SizedBox(width: 8),
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(next.displayTime, style: AppTheme.englishTitle(fontSize: 24, color: AppColors.cream)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('$hours:$minutes:$seconds', style: AppTheme.englishText(fontSize: 14, color: AppColors.faintText, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Row(
                textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
                children: [
                  Expanded(child: Text(isKurdish ? 'کاتەکانی ئەمڕۆ' : locale == 'ar' ? 'مواقيت اليوم' : "Today's prayer times", textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr, style: isKurdish ? AppTheme.kurdishTitle(fontSize: 15, color: AppColors.cream) : AppTheme.englishTitle(fontSize: 15, color: AppColors.cream))),
                  Text(day.date, style: AppTheme.englishText(fontSize: 12, color: AppColors.mutedText)),
                ],
              ),
              const SizedBox(height: 12),
              ...prayers.map((prayer) => _prayerRow(prayer, locale, isRtl, prayer == next)),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(color: AppColors.panelColor, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppColors.panelBorderColor)),
                child: Row(
                  textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
                  children: [
                    Icon(Icons.verified_outlined, color: AppColors.gold, size: 20),
                    const SizedBox(width: 9),
                    Expanded(child: Text(_locationMessage ?? (isKurdish ? 'کاتەکان لە داتابەیسی imanikurd ـەوە وەرگیراون.' : locale == 'ar' ? 'الأوقات مأخوذة من قاعدة بيانات imanikurd.' : 'Times are supplied by the imanikurd prayer-times database.'), textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr, style: isKurdish ? AppTheme.kurdishText(fontSize: 12, color: AppColors.faintText) : AppTheme.englishText(fontSize: 12, color: AppColors.faintText))),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _prayerRow(_Prayer prayer, String locale, bool isRtl, bool isNext) {
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(color: isNext ? AppColors.gold.withValues(alpha: 0.14) : AppColors.panelColor, borderRadius: BorderRadius.circular(17), border: Border.all(color: isNext ? AppColors.gold.withValues(alpha: 0.42) : AppColors.panelBorderColor)),
      child: Row(
        textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
        children: [
          Icon(prayer.icon, color: isNext ? AppColors.gold : AppColors.mutedText, size: 22),
          const SizedBox(width: 12),
          Expanded(child: Text(prayer.label(locale), textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr, style: locale == 'ku' ? AppTheme.kurdishText(fontSize: 14, color: isNext ? AppColors.gold : AppColors.cream, fontWeight: FontWeight.w700) : AppTheme.englishText(fontSize: 14, color: isNext ? AppColors.gold : AppColors.cream, fontWeight: FontWeight.w700))),
          const SizedBox(width: 8),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(prayer.displayTime, style: AppTheme.englishTitle(fontSize: 17, color: isNext ? AppColors.gold : AppColors.cream)),
            ),
          ),
        ],
      ),
    );
  }

  List<_Prayer> _prayersFor(PrayerDay day) {
    return [
      _Prayer('fajr', day.fajr, Icons.wb_twilight_rounded),
      _Prayer('sunrise', day.sunrise, Icons.wb_sunny_outlined),
      _Prayer('dhuhr', day.dhuhr, Icons.wb_sunny_rounded),
      _Prayer('asr', day.asr, Icons.wb_cloudy_outlined),
      _Prayer('maghrib', day.maghrib, Icons.nightlight_outlined),
      _Prayer('isha', day.isha, Icons.nights_stay_rounded),
    ];
  }

  _Prayer _nextPrayer(List<_Prayer> prayers) {
    final now = DateTime.now();
    return prayers.firstWhere((item) => item.time.isAfter(now), orElse: () => prayers.first);
  }

  Future<void> _chooseCity(BuildContext context, PrayerTimesCatalog catalog, String locale) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(sheetContext).size.height * 0.85,
        ),
        decoration: BoxDecoration(
          color: AppColors.darkPanel,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border.all(color: AppColors.panelBorderColor),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        locale == 'ku' ? 'شار هەڵبژێرە' : locale == 'ar' ? 'اختر المدينة' : 'Choose city',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTheme.englishTitle(fontSize: 18, color: AppColors.gold),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close_rounded, color: AppColors.faintText),
                      onPressed: () => Navigator.pop(sheetContext),
                    ),
                  ],
                ),
              ),
              const Divider(color: Colors.white10, height: 1),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  children: catalog.cityNames.map((city) => ListTile(
                        leading: Icon(city == _city ? Icons.radio_button_checked : Icons.radio_button_off, color: city == _city ? AppColors.gold : AppColors.mutedText),
                        title: Text(_cityLabel(city, locale), style: AppTheme.englishText(fontSize: 14, color: AppColors.cream)),
                        onTap: () => Navigator.pop(sheetContext, city),
                      )).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (selected != null && mounted) setState(() => _city = selected);
  }

  String _cityLabel(String city, String locale) {
    if (city == 'Hawler' && locale == 'ku') return 'هەولێر';
    if (city == 'Slemani' && locale == 'ku') return 'سلێمانی';
    if (city == 'Duhok' && locale == 'ku') return 'دهۆک';
    return city;
  }

  Widget _messageScreen(String message) {
    return Scaffold(backgroundColor: AppColors.darkBg, body: Center(child: Text(message, style: TextStyle(color: AppColors.cream))));
  }
}

class _Prayer {
  final String id;
  final String rawTime;
  final IconData icon;

  _Prayer(this.id, this.rawTime, this.icon);

  DateTime get time {
    final parts = rawTime.split(':');
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, int.parse(parts[0]), int.parse(parts[1]));
  }

  String get displayTime {
    final parts = rawTime.split(':');
    final hour = int.parse(parts[0]);
    final minute = parts[1];
    final suffix = hour >= 12 ? 'PM' : 'AM';
    final twelveHour = hour % 12 == 0 ? 12 : hour % 12;
    return '$twelveHour:$minute $suffix';
  }

  String label(String locale) {
    if (locale == 'ku') {
      const names = {'fajr': 'بەیانی', 'sunrise': 'هەڵاتنی خۆر', 'dhuhr': 'نیوەڕۆ', 'asr': 'عەسر', 'maghrib': 'ئێوارە', 'isha': 'عیشا'};
      return names[id] ?? id;
    }
    if (locale == 'ar') {
      const names = {'fajr': 'الفجر', 'sunrise': 'الشروق', 'dhuhr': 'الظهر', 'asr': 'العصر', 'maghrib': 'المغرب', 'isha': 'العشاء'};
      return names[id] ?? id;
    }
    const names = {'fajr': 'Fajr', 'sunrise': 'Sunrise', 'dhuhr': 'Dhuhr', 'asr': 'Asr', 'maghrib': 'Maghrib', 'isha': 'Isha'};
    return names[id] ?? id;
  }
}
