import 'dart:math' as math;

/// Juristic school for Asr calculation.
enum AsrSchool {
  /// Standard (Shafi, Maliki, Hanbali, Ja'fari) - Shadow factor = 1
  shafi,

  /// Hanafi - Shadow factor = 2
  hanafi,
}

/// High latitude rule for places with extreme daylight/twilight.
enum HighLatitudeRule {
  /// Twilight duration is capped at 1/2 of the night
  nightMiddle,

  /// Twilight duration is capped at 1/7 of the night
  oneSeventh,

  /// Twilight duration is capped proportionally to angle / 60 * night
  angleBased,
}

/// Global calculation methods for prayer times.
class CalculationMethod {
  final String id;
  final String nameEn;
  final String nameAr;
  final String nameKu;
  final double fajrAngle;
  final double ishaAngle;

  /// If non-null, Isha is fixed at N minutes after Maghrib
  final int? ishaIntervalMinutes;

  /// If non-null, Maghrib angle (for Shia methods)
  final double? maghribAngle;

  const CalculationMethod({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.nameKu,
    required this.fajrAngle,
    required this.ishaAngle,
    this.ishaIntervalMinutes,
    this.maghribAngle,
  });

  /// 1. Official Kurdistan Region Ministry of Endowments (وەزارەتی ئەوقاف)
  static const kurdistanEndowments = CalculationMethod(
    id: 'kurdistan_endowments',
    nameEn: 'Kurdistan Region Ministry of Endowments (Awqaf)',
    nameAr: 'وزارة الأوقاف والشؤون الدينية بكردستان',
    nameKu: 'وەزارەتی ئەوقاف و کاروباری ئایینی هەرێمی کوردستان',
    fajrAngle: 19.5,
    ishaAngle: 17.5,
  );

  /// 2. Umm Al-Qura University, Makkah (Saudi Arabia)
  static const ummAlQura = CalculationMethod(
    id: 'umm_al_qura',
    nameEn: 'Umm Al-Qura University, Makkah',
    nameAr: 'جامعة أم القرى، مكة المكرمة',
    nameKu: 'زانکۆی ئوم ئەلقورای مەککە',
    fajrAngle: 18.5,
    ishaAngle: 0,
    ishaIntervalMinutes: 90,
  );

  /// 2. Muslim World League (MWL) - Global Standard
  static const mwl = CalculationMethod(
    id: 'mwl',
    nameEn: 'Muslim World League (MWL)',
    nameAr: 'رابطة العالم الإسلامي',
    nameKu: 'یەکێتی جیهانی ئیسلامی (MWL)',
    fajrAngle: 18.0,
    ishaAngle: 17.0,
  );

  /// 3. Islamic Society of North America (ISNA)
  static const isna = CalculationMethod(
    id: 'isna',
    nameEn: 'Islamic Society of North America (ISNA)',
    nameAr: 'الجمعية الإسلامية لشمال أمريكا',
    nameKu: 'کۆمەڵەی ئیسلامی ئەمریکای باکوور (ISNA)',
    fajrAngle: 15.0,
    ishaAngle: 15.0,
  );

  /// 4. Egyptian General Authority of Survey
  static const egypt = CalculationMethod(
    id: 'egypt',
    nameEn: 'Egyptian General Authority of Survey',
    nameAr: 'الهيئة المصرية العامة للمساحة',
    nameKu: 'دەستەی گشتی ڕووپێوی میسری',
    fajrAngle: 19.5,
    ishaAngle: 17.5,
  );

  /// 5. University of Islamic Sciences, Karachi
  static const karachi = CalculationMethod(
    id: 'karachi',
    nameEn: 'University of Islamic Sciences, Karachi',
    nameAr: 'جامعة العلوم الإسلامية بكراتشي',
    nameKu: 'زانکۆی زانستە ئیسلامییەکان لە کراچی',
    fajrAngle: 18.0,
    ishaAngle: 18.0,
  );

  /// 6. Diyanet İşleri Başkanlığı (Turkey)
  static const diyanet = CalculationMethod(
    id: 'diyanet',
    nameEn: 'Diyanet İşleri Başkanlığı (Turkey)',
    nameAr: 'رئاسة الشؤون الدينية التركية',
    nameKu: 'سەرۆکایەتی کاروباری ئایینی تورکیا (دیانەت)',
    fajrAngle: 18.0,
    ishaAngle: 17.0,
  );

  /// 7. Institute of Geophysics, University of Tehran
  static const tehran = CalculationMethod(
    id: 'tehran',
    nameEn: 'Institute of Geophysics, University of Tehran',
    nameAr: 'معهد الجيوفيزياء بجمهورية إيران',
    nameKu: 'پەیمانگای جیۆفیزیک لە زانکۆی تاران',
    fajrAngle: 17.7,
    ishaAngle: 14.0,
    maghribAngle: 4.5,
  );

  /// 8. Shia Ithna-Ashari (Jafari)
  static const jafari = CalculationMethod(
    id: 'jafari',
    nameEn: 'Shia Ithna-Ashari (Jafari)',
    nameAr: 'الشيعة الإثنا عشرية (الجعفري)',
    nameKu: 'مەزهەبی جەعفەری (شێعە)',
    fajrAngle: 16.0,
    ishaAngle: 14.0,
    maghribAngle: 4.0,
  );

  /// 9. Gulf Region / UAE Standard
  static const gulf = CalculationMethod(
    id: 'gulf',
    nameEn: 'Gulf Region / UAE Standard',
    nameAr: 'منطقة الخليج العربي / الإمارات',
    nameKu: 'ناوچەی کەنداو / ئیمارات',
    fajrAngle: 19.5,
    ishaAngle: 0,
    ishaIntervalMinutes: 90,
  );

  /// 10. Majlis Ugama Islam Singapura (MUIS)
  static const singapore = CalculationMethod(
    id: 'singapore',
    nameEn: 'Majlis Ugama Islam Singapura (MUIS)',
    nameAr: 'مجلس الإدارة الإسلامية بسنغافورة',
    nameKu: 'ئەنجومەنی ئیسلامی سەنگافورە (MUIS)',
    fajrAngle: 20.0,
    ishaAngle: 18.0,
  );

  /// 11. UOIF (Union Des Organisations Islamiques De France)
  static const france = CalculationMethod(
    id: 'france',
    nameEn: 'UOIF (France 12°)',
    nameAr: 'اتحاد المنظمات الإسلامية في فرنسا',
    nameKu: 'یەکێتی ڕێکخراوە ئیسلامییەکان لە فەرەنسا (12°)',
    fajrAngle: 12.0,
    ishaAngle: 12.0,
  );

  /// 12. Spiritual Administration of Muslims of Russia
  static const russia = CalculationMethod( 
    id: 'russia',
    nameEn: 'Spiritual Administration of Muslims of Russia',
    nameAr: 'الإدارة الدينية لمسلمي روسيا',
    nameKu: 'بەڕێوەبەرایەتی ئایینی موسڵمانانی ڕووسیا',
    fajrAngle: 16.0,
    ishaAngle: 15.0,
  );

  /// 13. KEMENAG (Ministry of Religious Affairs, Indonesia)
  static const indonesia = CalculationMethod(
    id: 'indonesia',
    nameEn: 'KEMENAG (Indonesia)',
    nameAr: 'وزارة الشؤون الدينية الإندونيسية',
    nameKu: 'وەزارەتی کاروباری ئایینی ئەندەنوسیا',
    fajrAngle: 20.0,
    ishaAngle: 18.0,
  );

  /// 14. Dubai / UAE Standard
  static const dubai = CalculationMethod(
    id: 'dubai',
    nameEn: 'Dubai / UAE',
    nameAr: 'دبي / الإمارات العربية المتحدة',
    nameKu: 'دوبەی / ئیمارات',
    fajrAngle: 18.2,
    ishaAngle: 18.2,
  );

  static const List<CalculationMethod> allMethods = [
    kurdistanEndowments,
    mwl,
    ummAlQura,
    isna,
    egypt,
    karachi,
    diyanet,
    gulf,
    tehran,
    jafari,
    singapore,
    france,
    russia,
    indonesia,
    dubai,
  ];

  static CalculationMethod byId(String id) {
    return allMethods.firstWhere(
      (m) => m.id == id,
      orElse: () => kurdistanEndowments,
    );
  }
}

/// Structured prayer times model for a single day.
class CalculatedPrayerTimes {
  final DateTime date;
  final DateTime fajr;
  final DateTime sunrise;
  final DateTime dhuhr;
  final DateTime asr;
  final DateTime maghrib;
  final DateTime isha;
  final DateTime? imsak;
  final DateTime? midnight;

  const CalculatedPrayerTimes({
    required this.date,
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    this.imsak,
    this.midnight,
  });

  /// Map of prayer ID to DateTime
  Map<String, DateTime> toMap() {
    return {
      'fajr': fajr,
      'sunrise': sunrise,
      'dhuhr': dhuhr,
      'asr': asr,
      'maghrib': maghrib,
      'isha': isha,
      if (imsak != null) 'imsak': imsak!,
      if (midnight != null) 'midnight': midnight!,
    };
  }
}

/// 100% Offline Astronomical Prayer Times Calculator.
class OfflinePrayerCalculator {
  /// Calculates prayer times for a given latitude, longitude, and date.
  /// If [targetUtcOffsetHours] is provided, calculations use the location's true UTC offset
  /// regardless of device local timezone (crucial for worldwide cities).
  static CalculatedPrayerTimes calculate({
    required double latitude,
    required double longitude,
    required DateTime date,
    CalculationMethod method = CalculationMethod.mwl,
    AsrSchool asrSchool = AsrSchool.shafi,
    HighLatitudeRule highLatRule = HighLatitudeRule.nightMiddle,
    double elevationMeters = 0,
    double? targetUtcOffsetHours,
    Map<String, int> minuteOffsets = const {},
  }) {
    final cleanDate = DateTime(date.year, date.month, date.day);
    final timezoneOffsetHours = targetUtcOffsetHours ?? (date.timeZoneOffset.inMinutes / 60.0);

    // Day of year
    final dayOfYear = _julianDayOfYear(date.year, date.month, date.day);

    // Sun's declination & equation of time
    final solarParams = _calculateSolarParameters(date.year, dayOfYear);
    final declination = solarParams.declination;
    final eqOfTime = solarParams.equationOfTime;

    // Solar Noon (transit time in minutes from midnight local standard time)
    final solarNoonMinutes = 720 - (4.0 * longitude) - eqOfTime + (timezoneOffsetHours * 60.0);

    // Sunrise & Sunset angle (standard 90.833° accounting for atmospheric refraction & solar disc)
    // Elevation correction: dip angle = 0.0347 * sqrt(elevation_meters)
    final dip = 0.0347 * math.sqrt(math.max(0, elevationMeters));
    final sunriseSunsetZenith = 90.833 + dip;

    // 1. Sunrise & Sunset (Maghrib standard)
    final sunriseHourAngle = _hourAngle(sunriseSunsetZenith, latitude, declination);
    final sunsetHourAngle = sunriseHourAngle;

    double sunriseMinutes = solarNoonMinutes - (sunriseHourAngle * 4.0);
    double sunsetMinutes = solarNoonMinutes + (sunsetHourAngle * 4.0);
    final nightDurationMinutes = 1440.0 - sunsetMinutes + sunriseMinutes;

    // 2. Dhuhr (Solar noon + standard zawwal safety margin of +2 mins)
    double dhuhrMinutes = solarNoonMinutes + 2.0;

    // 3. Asr
    final asrShadowFactor = asrSchool == AsrSchool.hanafi ? 2.0 : 1.0;
    final asrHourAngle = _asrHourAngle(asrShadowFactor, latitude, declination);
    double asrMinutes = solarNoonMinutes + (asrHourAngle * 4.0);

    // 4. Fajr
    double fajrMinutes;
    final fajrHourAngle = _hourAngle(90.0 + method.fajrAngle, latitude, declination);
    final fajrPortion = _highLatPortion(highLatRule, method.fajrAngle);

    if (fajrHourAngle.isNaN) {
      // High latitude adjustment when sun doesn't reach twilight depth
      fajrMinutes = sunriseMinutes - (nightDurationMinutes * fajrPortion);
    } else {
      fajrMinutes = solarNoonMinutes - (fajrHourAngle * 4.0);
      // Cap twilight duration according to high-latitude fiqh rule if twilight is abnormal
      final rawTwilight = sunriseMinutes - fajrMinutes;
      final maxTwilight = nightDurationMinutes * fajrPortion;
      if (rawTwilight > maxTwilight) {
        fajrMinutes = sunriseMinutes - maxTwilight;
      }
    }

    // 5. Maghrib (Standard: sunset, or Shia angle)
    double maghribMinutes;
    if (method.maghribAngle != null) {
      final maghribHourAngle = _hourAngle(90.0 + method.maghribAngle!, latitude, declination);
      maghribMinutes = maghribHourAngle.isNaN
          ? sunsetMinutes
          : solarNoonMinutes + (maghribHourAngle * 4.0);
    } else {
      maghribMinutes = sunsetMinutes;
    }

    // 6. Isha
    double ishaMinutes;
    if (method.ishaIntervalMinutes != null) {
      // Fixed interval after Maghrib (e.g. Umm Al-Qura, Gulf)
      ishaMinutes = maghribMinutes + method.ishaIntervalMinutes!;
    } else {
      final ishaHourAngle = _hourAngle(90.0 + method.ishaAngle, latitude, declination);
      final ishaPortion = _highLatPortion(highLatRule, method.ishaAngle);

      if (ishaHourAngle.isNaN) {
        // High latitude adjustment for Isha
        ishaMinutes = sunsetMinutes + (nightDurationMinutes * ishaPortion);
      } else {
        ishaMinutes = solarNoonMinutes + (ishaHourAngle * 4.0);
        // Cap twilight duration according to high-latitude fiqh rule if twilight is abnormal
        final rawTwilight = ishaMinutes - sunsetMinutes;
        final maxTwilight = nightDurationMinutes * ishaPortion;
        if (rawTwilight > maxTwilight) {
          ishaMinutes = sunsetMinutes + maxTwilight;
        }
      }
    }

    // Secondary calculations: Imsak (10 min before Fajr) and Midnight
    final double imsakMinutes = fajrMinutes - 10.0;
    final double midnightMinutes = sunsetMinutes + (nightDurationMinutes / 2.0);

    // Apply minute offsets
    fajrMinutes += (minuteOffsets['fajr'] ?? 0);
    sunriseMinutes += (minuteOffsets['sunrise'] ?? 0);
    dhuhrMinutes += (minuteOffsets['dhuhr'] ?? 0);
    asrMinutes += (minuteOffsets['asr'] ?? 0);
    maghribMinutes += (minuteOffsets['maghrib'] ?? 0);
    ishaMinutes += (minuteOffsets['isha'] ?? 0);

    return CalculatedPrayerTimes(
      date: cleanDate,
      fajr: _minutesToDateTime(cleanDate, fajrMinutes),
      sunrise: _minutesToDateTime(cleanDate, sunriseMinutes),
      dhuhr: _minutesToDateTime(cleanDate, dhuhrMinutes),
      asr: _minutesToDateTime(cleanDate, asrMinutes),
      maghrib: _minutesToDateTime(cleanDate, maghribMinutes),
      isha: _minutesToDateTime(cleanDate, ishaMinutes),
      imsak: _minutesToDateTime(cleanDate, imsakMinutes),
      midnight: _minutesToDateTime(cleanDate, midnightMinutes),
    );
  }

  static double _highLatPortion(HighLatitudeRule rule, double angle) {
    switch (rule) {
      case HighLatitudeRule.nightMiddle:
        return 0.5;
      case HighLatitudeRule.oneSeventh:
        return 1.0 / 7.0;
      case HighLatitudeRule.angleBased:
        return angle / 60.0;
    }
  }

  /// Hour angle calculation in degrees:
  /// cos(H) = (cos(Zenith) - sin(Lat)*sin(Dec)) / (cos(Lat)*cos(Dec))
  static double _hourAngle(double zenithDegrees, double latitudeDegrees, double declinationRadians) {
    final latRad = latitudeDegrees * math.pi / 180.0;
    final zenithRad = zenithDegrees * math.pi / 180.0;

    final cosH = (math.cos(zenithRad) - (math.sin(latRad) * math.sin(declinationRadians))) /
        (math.cos(latRad) * math.cos(declinationRadians));

    if (cosH > 1.0 || cosH < -1.0) {
      return double.nan; // Sun does not reach zenith angle (polar day/night)
    }

    return math.acos(cosH) * 180.0 / math.pi;
  }

  /// Asr hour angle calculation in degrees
  static double _asrHourAngle(double shadowFactor, double latitudeDegrees, double declinationRadians) {
    final latRad = latitudeDegrees * math.pi / 180.0;

    // Angle of altitude for Asr: cot(A) = shadowFactor + tan(|lat - dec|)
    final deltaLatDec = (latRad - declinationRadians).abs();
    final cotAltitude = shadowFactor + math.tan(deltaLatDec);
    final altitudeRad = math.atan(1.0 / cotAltitude);

    final cosH = (math.sin(altitudeRad) - (math.sin(latRad) * math.sin(declinationRadians))) /
        (math.cos(latRad) * math.cos(declinationRadians));

    final clampedCosH = cosH.clamp(-1.0, 1.0);
    return math.acos(clampedCosH) * 180.0 / math.pi;
  }


  /// Calculates Solar Declination (radians) and Equation of Time (minutes).
  static _SolarParameters _calculateSolarParameters(int year, int dayOfYear) {
    final gamma = (2.0 * math.pi / 365.0) * (dayOfYear - 1.0);

    // Equation of time in minutes
    final eqOfTime = 229.18 *
        (0.000075 +
            0.001868 * math.cos(gamma) -
            0.032077 * math.sin(gamma) -
            0.014615 * math.cos(2.0 * gamma) -
            0.040849 * math.sin(2.0 * gamma));

    // Declination in radians
    final declination = 0.006918 -
        0.399912 * math.cos(gamma) +
        0.070257 * math.sin(gamma) -
        0.006758 * math.cos(2.0 * gamma) +
        0.000907 * math.sin(2.0 * gamma) -
        0.002697 * math.cos(3.0 * gamma) +
        0.00148 * math.sin(3.0 * gamma);

    return _SolarParameters(declination: declination, equationOfTime: eqOfTime);
  }

  static int _julianDayOfYear(int year, int month, int day) {
    final date = DateTime(year, month, day);
    final firstDay = DateTime(year, 1, 1);
    return date.difference(firstDay).inDays + 1;
  }

  static DateTime _minutesToDateTime(DateTime date, double minutesFromMidnight) {
    final totalSeconds = (minutesFromMidnight * 60).round();
    final cleanDay = DateTime(date.year, date.month, date.day);
    return cleanDay.add(Duration(seconds: totalSeconds));
  }
}

class _SolarParameters {
  final double declination;
  final double equationOfTime;

  const _SolarParameters({required this.declination, required this.equationOfTime});
}
