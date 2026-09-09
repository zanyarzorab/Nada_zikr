import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import 'location_service.dart';
import 'offline_prayer_calculator.dart';
import 'prayer_times_service.dart';
import 'storage_service.dart';

/// Country or Region Grouping Model
class CountryGroup {
  final String id;
  final String nameEn;
  final String nameAr;
  final String nameKu;
  final String flag;
  final List<WorldCity> cities;

  const CountryGroup({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.nameKu,
    required this.flag,
    required this.cities,
  });

  String displayName(String locale) {
    if (locale == 'ku') return nameKu;
    if (locale == 'ar') return nameAr;
    return nameEn;
  }
}

/// Pre-defined world cities catalog with coordinates, real IANA timezones and calculation hints.
class WorldCity {
  final String id;
  final String nameEn;
  final String nameAr;
  final String nameKu;
  final String countryEn;
  final String countryAr;
  final String countryKu;
  final double latitude;
  final double longitude;
  final String timezoneId;
  final double utcOffsetStandard;
  final String recommendedMethodId;
  final String? datasetKey;

  const WorldCity({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.nameKu,
    required this.countryEn,
    required this.countryAr,
    required this.countryKu,
    required this.latitude,
    required this.longitude,
    this.timezoneId = 'Asia/Baghdad',
    this.utcOffsetStandard = 3.0,
    this.recommendedMethodId = 'kurdistan_endowments',
    this.datasetKey,
  });

  bool get isKurdistanOfficial => countryEn.toLowerCase() == 'kurdistan' && datasetKey != null;

  String displayName(String locale) {
    if (locale == 'ku') return nameKu;
    if (locale == 'ar') return nameAr;
    return nameEn;
  }

  String displayCountry(String locale) {
    if (locale == 'ku') return countryKu;
    if (locale == 'ar') return countryAr;
    return countryEn;
  }

  static bool _tzInitialized = false;
  static void _ensureTzInit() {
    if (!_tzInitialized) {
      try {
        tz_data.initializeTimeZones();
        _tzInitialized = true;
      } catch (_) {}
    }
  }

  /// Resolves the actual UTC offset in hours for this city on a given date (accounting for DST).
  double resolveUtcOffset([DateTime? date]) {
    final effectiveDate = date ?? DateTime.now();
    _ensureTzInit();
    try {
      final loc = tz.getLocation(timezoneId);
      final tzDate = tz.TZDateTime.from(effectiveDate, loc);
      return tzDate.timeZoneOffset.inMinutes / 60.0;
    } catch (_) {
      return utcOffsetStandard;
    }
  }

  /// Friendly timezone abbreviation (e.g., AST, GMT, BST, EDT, JST)
  String timezoneAbbreviation([DateTime? date]) {
    final effectiveDate = date ?? DateTime.now();
    _ensureTzInit();
    try {
      final loc = tz.getLocation(timezoneId);
      final tzDate = tz.TZDateTime.from(effectiveDate, loc);
      return tzDate.timeZoneName;
    } catch (_) {
      final sign = utcOffsetStandard >= 0 ? '+' : '-';
      final h = utcOffsetStandard.abs().toInt();
      return 'UTC$sign$h';
    }
  }
}

/// Global Preset Cities List organized cleanly by Country/Region.
class WorldCitiesCatalog {
  static const List<CountryGroup> countryGroups = [
    // 1. Kurdistan
    CountryGroup(
      id: 'kurdistan',
      nameEn: 'Kurdistan',
      nameAr: 'كردستان',
      nameKu: 'کوردستان',
      flag: '☀️',
      cities: [
        WorldCity(id: 'Hawler', nameEn: 'Hewlêr / Erbil', nameAr: 'أربيل', nameKu: 'هەولێر', countryEn: 'Kurdistan', countryAr: 'كردستان', countryKu: 'کوردستان', latitude: 36.1911, longitude: 44.0092, timezoneId: 'Asia/Baghdad', utcOffsetStandard: 3.0, datasetKey: 'Hawler'),
        WorldCity(id: 'Slemani', nameEn: 'Sulaymaniyah', nameAr: 'السليمانية', nameKu: 'سلێمانی', countryEn: 'Kurdistan', countryAr: 'كردستان', countryKu: 'کوردستان', latitude: 35.5570, longitude: 45.4351, timezoneId: 'Asia/Baghdad', utcOffsetStandard: 3.0, datasetKey: 'Slemani'),
        WorldCity(id: 'Duhok', nameEn: 'Duhok', nameAr: 'دهوك', nameKu: 'دهۆک', countryEn: 'Kurdistan', countryAr: 'كردستان', countryKu: 'کوردستان', latitude: 36.8617, longitude: 42.9992, timezoneId: 'Asia/Baghdad', utcOffsetStandard: 3.0, datasetKey: 'Duhok'),
        WorldCity(id: 'Halabja', nameEn: 'Halabja', nameAr: 'حلبجة', nameKu: 'هەڵەبجە', countryEn: 'Kurdistan', countryAr: 'كردستان', countryKu: 'کوردستان', latitude: 35.1778, longitude: 45.9861, timezoneId: 'Asia/Baghdad', utcOffsetStandard: 3.0, datasetKey: 'Halabja'),
        WorldCity(id: 'SaidSadiq', nameEn: 'Said Sadiq', nameAr: 'سيد صادق', nameKu: 'سەید سادق', countryEn: 'Kurdistan', countryAr: 'كردستان', countryKu: 'کوردستان', latitude: 35.3558, longitude: 45.8642, timezoneId: 'Asia/Baghdad', utcOffsetStandard: 3.0, datasetKey: 'SaidSadq'),
        WorldCity(id: 'Khurmal', nameEn: 'Khurmal', nameAr: 'خورمال', nameKu: 'خورماڵ', countryEn: 'Kurdistan', countryAr: 'كردستان', countryKu: 'کوردستان', latitude: 35.2917, longitude: 46.0333, timezoneId: 'Asia/Baghdad', utcOffsetStandard: 3.0, datasetKey: 'Khurmal'),
        WorldCity(id: 'Dukan', nameEn: 'Dukan', nameAr: 'دوكان', nameKu: 'دووکان', countryEn: 'Kurdistan', countryAr: 'كردستان', countryKu: 'کوردستان', latitude: 35.9528, longitude: 44.9575, timezoneId: 'Asia/Baghdad', utcOffsetStandard: 3.0, datasetKey: 'Dukan'),
        WorldCity(id: 'Kirkuk', nameEn: 'Kirkuk', nameAr: 'كركوك', nameKu: 'کەرکووک', countryEn: 'Kurdistan', countryAr: 'كردستان', countryKu: 'کوردستان', latitude: 35.4681, longitude: 44.3922, timezoneId: 'Asia/Baghdad', utcOffsetStandard: 3.0, datasetKey: 'Kirkuk'),
        WorldCity(id: 'Dwz', nameEn: 'Tuz Khurmatu / Dwz', nameAr: 'طوز خورماتو', nameKu: 'دوزخورماتوو', countryEn: 'Kurdistan', countryAr: 'كردستان', countryKu: 'کوردستان', latitude: 34.8872, longitude: 44.6319, timezoneId: 'Asia/Baghdad', utcOffsetStandard: 3.0, datasetKey: 'Dwz'),
        WorldCity(id: 'Daquq', nameEn: 'Daquq', nameAr: 'دقوق', nameKu: 'داقووق', countryEn: 'Kurdistan', countryAr: 'كردستان', countryKu: 'کوردستان', latitude: 35.0747, longitude: 44.4283, timezoneId: 'Asia/Baghdad', utcOffsetStandard: 3.0, datasetKey: 'Daquq'),
        WorldCity(id: 'Hawija', nameEn: 'Hawija', nameAr: 'الحويجة', nameKu: 'حەویجە', countryEn: 'Kurdistan', countryAr: 'كردستان', countryKu: 'کوردستان', latitude: 35.3253, longitude: 43.7739, timezoneId: 'Asia/Baghdad', utcOffsetStandard: 3.0, datasetKey: 'Hawija'),
        WorldCity(id: 'Dibis', nameEn: 'Dibis', nameAr: 'دبس', nameKu: 'دبس', countryEn: 'Kurdistan', countryAr: 'كردستان', countryKu: 'کوردستان', latitude: 35.6881, longitude: 44.0628, timezoneId: 'Asia/Baghdad', utcOffsetStandard: 3.0, datasetKey: 'Dibis'),
        WorldCity(id: 'Makhmur', nameEn: 'Makhmur', nameAr: 'مخمور', nameKu: 'مەخموور', countryEn: 'Kurdistan', countryAr: 'كردستان', countryKu: 'کوردستان', latitude: 35.7761, longitude: 43.5786, timezoneId: 'Asia/Baghdad', utcOffsetStandard: 3.0, datasetKey: 'Makhmur'),
        WorldCity(id: 'Zakho', nameEn: 'Zakho', nameAr: 'زاخو', nameKu: 'زاخۆ', countryEn: 'Kurdistan', countryAr: 'كردستان', countryKu: 'کوردستان', latitude: 37.1445, longitude: 42.6872, timezoneId: 'Asia/Baghdad', utcOffsetStandard: 3.0, datasetKey: 'Zakho'),
        WorldCity(id: 'Soran', nameEn: 'Soran', nameAr: 'سوران', nameKu: 'سۆران', countryEn: 'Kurdistan', countryAr: 'كردستان', countryKu: 'کوردستان', latitude: 36.6500, longitude: 44.5386, timezoneId: 'Asia/Baghdad', utcOffsetStandard: 3.0, datasetKey: 'Soran'),
        WorldCity(id: 'Akre', nameEn: 'Akre', nameAr: 'عقرة', nameKu: 'ئاکرێ', countryEn: 'Kurdistan', countryAr: 'كردستان', countryKu: 'کوردستان', latitude: 36.7411, longitude: 43.8933, timezoneId: 'Asia/Baghdad', utcOffsetStandard: 3.0, datasetKey: 'Akre'),
        WorldCity(id: 'Kalar', nameEn: 'Kalar', nameAr: 'كلار', nameKu: 'کەلار', countryEn: 'Kurdistan', countryAr: 'كردستان', countryKu: 'کوردستان', latitude: 34.6294, longitude: 45.3169, timezoneId: 'Asia/Baghdad', utcOffsetStandard: 3.0, datasetKey: 'Kalar'),
        WorldCity(id: 'Bawanur', nameEn: 'Bawanur', nameAr: 'باوانور', nameKu: 'باوەنور', countryEn: 'Kurdistan', countryAr: 'كردستان', countryKu: 'کوردستان', latitude: 34.8217, longitude: 45.2411, timezoneId: 'Asia/Baghdad', utcOffsetStandard: 3.0, datasetKey: 'Bawanur'),
        WorldCity(id: 'Sarqala', nameEn: 'Sarqala', nameAr: 'سرقلاع', nameKu: 'سەرقەڵا', countryEn: 'Kurdistan', countryAr: 'كردستان', countryKu: 'کوردستان', latitude: 34.7214, longitude: 45.0312, timezoneId: 'Asia/Baghdad', utcOffsetStandard: 3.0, datasetKey: 'Sarqala'),
        WorldCity(id: 'Rania', nameEn: 'Rania', nameAr: 'رانية', nameKu: 'ڕانیە', countryEn: 'Kurdistan', countryAr: 'كردستان', countryKu: 'کوردستان', latitude: 36.2547, longitude: 44.8825, timezoneId: 'Asia/Baghdad', utcOffsetStandard: 3.0, datasetKey: 'Ranya(Kon)'),
        WorldCity(id: 'Chamchamal', nameEn: 'Chamchamal', nameAr: 'جمجمال', nameKu: 'چەمچەماڵ', countryEn: 'Kurdistan', countryAr: 'كردستان', countryKu: 'کوردستان', latitude: 35.5317, longitude: 44.8344, timezoneId: 'Asia/Baghdad', utcOffsetStandard: 3.0, datasetKey: 'Chamchamal'),
        WorldCity(id: 'Koya', nameEn: 'Koya', nameAr: 'كويسنجق', nameKu: 'کۆیە', countryEn: 'Kurdistan', countryAr: 'كردستان', countryKu: 'کوردستان', latitude: 36.0828, longitude: 44.6289, timezoneId: 'Asia/Baghdad', utcOffsetStandard: 3.0, datasetKey: 'Koya'),
        WorldCity(id: 'Shaqlawa', nameEn: 'Shaqlawa', nameAr: 'شقلاوة', nameKu: 'شەقڵاوە', countryEn: 'Kurdistan', countryAr: 'كردستان', countryKu: 'کوردستان', latitude: 36.4042, longitude: 44.3267, timezoneId: 'Asia/Baghdad', utcOffsetStandard: 3.0, datasetKey: 'Hawler'),
        WorldCity(id: 'Derbendikhan', nameEn: 'Derbendikhan', nameAr: 'دربندخان', nameKu: 'دەربەندیخان', countryEn: 'Kurdistan', countryAr: 'كردستان', countryKu: 'کوردستان', latitude: 35.1114, longitude: 45.6961, timezoneId: 'Asia/Baghdad', utcOffsetStandard: 3.0, datasetKey: 'Darbandikhan'),
        WorldCity(id: 'Penjwen', nameEn: 'Penjwen', nameAr: 'بنجوين', nameKu: 'پێنچوێن', countryEn: 'Kurdistan', countryAr: 'كردستان', countryKu: 'کوردستان', latitude: 35.6167, longitude: 45.9500, timezoneId: 'Asia/Baghdad', utcOffsetStandard: 3.0, datasetKey: 'Halabja'),
        WorldCity(id: 'Amadiya', nameEn: 'Amadiya', nameAr: 'العمادية', nameKu: 'ئامێدی', countryEn: 'Kurdistan', countryAr: 'كردستان', countryKu: 'کوردستان', latitude: 37.0917, longitude: 43.4878, timezoneId: 'Asia/Baghdad', utcOffsetStandard: 3.0, datasetKey: 'Duhok'),
        WorldCity(id: 'Kifri', nameEn: 'Kifri', nameAr: 'كفري', nameKu: 'کفری', countryEn: 'Kurdistan', countryAr: 'كردستان', countryKu: 'کوردستان', latitude: 34.6897, longitude: 44.9625, timezoneId: 'Asia/Baghdad', utcOffsetStandard: 3.0, datasetKey: 'Kifri'),
        WorldCity(id: 'Rawanduz', nameEn: 'Rawanduz', nameAr: 'رواندوز', nameKu: 'ڕواندز', countryEn: 'Kurdistan', countryAr: 'كردستان', countryKu: 'کوردستان', latitude: 36.6117, longitude: 44.5244, timezoneId: 'Asia/Baghdad', utcOffsetStandard: 3.0, datasetKey: 'Soran'),
        WorldCity(id: 'Choman', nameEn: 'Choman', nameAr: 'جومان', nameKu: 'چۆمان', countryEn: 'Kurdistan', countryAr: 'كردستان', countryKu: 'کوردستان', latitude: 36.6358, longitude: 44.8864, timezoneId: 'Asia/Baghdad', utcOffsetStandard: 3.0, datasetKey: 'Soran'),
        WorldCity(id: 'Qasre', nameEn: 'Qasre', nameAr: 'قصري', nameKu: 'قەسرێ', countryEn: 'Kurdistan', countryAr: 'كردستان', countryKu: 'کوردستان', latitude: 36.5714, longitude: 44.7512, timezoneId: 'Asia/Baghdad', utcOffsetStandard: 3.0, datasetKey: 'Qasre'),
        WorldCity(id: 'Taqtaq', nameEn: 'Taqtaq', nameAr: 'طقطق', nameKu: 'تەقتەق', countryEn: 'Kurdistan', countryAr: 'كردستان', countryKu: 'کوردستان', latitude: 35.8881, longitude: 44.5828, timezoneId: 'Asia/Baghdad', utcOffsetStandard: 3.0, datasetKey: 'Taqtaq'),
        WorldCity(id: 'Qaladiza', nameEn: 'Qaladiza', nameAr: 'قلعة دزة', nameKu: 'قەڵادزێ', countryEn: 'Kurdistan', countryAr: 'كردستان', countryKu: 'کوردستان', latitude: 36.1808, longitude: 45.1228, timezoneId: 'Asia/Baghdad', utcOffsetStandard: 3.0, datasetKey: 'Qaladze'),
        WorldCity(id: 'Bardarash', nameEn: 'Bardarash', nameAr: 'بردرش', nameKu: 'بەردەڕەش', countryEn: 'Kurdistan', countryAr: 'كردستان', countryKu: 'کوردستان', latitude: 36.4833, longitude: 43.5833, timezoneId: 'Asia/Baghdad', utcOffsetStandard: 3.0, datasetKey: 'Bardarash'),
        WorldCity(id: 'Shekhan', nameEn: 'Shekhan', nameAr: 'شيخان', nameKu: 'شێخان', countryEn: 'Kurdistan', countryAr: 'كردستان', countryKu: 'کوردستان', latitude: 36.7208, longitude: 43.3375, timezoneId: 'Asia/Baghdad', utcOffsetStandard: 3.0, datasetKey: 'Shekhan'),
      ],
    ),

    // 2. Iraq (Governorates)
    CountryGroup(
      id: 'iraq',
      nameEn: 'Iraq',
      nameAr: 'العراق',
      nameKu: 'عێراق',
      flag: '🇮🇶',
      cities: [
        WorldCity(id: 'Baghdad', nameEn: 'Baghdad', nameAr: 'بغداد', nameKu: 'بەغدا', countryEn: 'Iraq', countryAr: 'العراق', countryKu: 'عێراق', latitude: 33.3152, longitude: 44.3661, timezoneId: 'Asia/Baghdad', utcOffsetStandard: 3.0, datasetKey: 'Baghdad'),
        WorldCity(id: 'Mosul', nameEn: 'Mosul', nameAr: 'الموصل', nameKu: 'موسڵ', countryEn: 'Iraq', countryAr: 'العراق', countryKu: 'عێراق', latitude: 36.3350, longitude: 43.1189, timezoneId: 'Asia/Baghdad', utcOffsetStandard: 3.0, datasetKey: 'Mosul'),
        WorldCity(id: 'Basrah', nameEn: 'Basra', nameAr: 'البصرة', nameKu: 'بەسرە', countryEn: 'Iraq', countryAr: 'العراق', countryKu: 'عێراق', latitude: 30.5085, longitude: 47.7804, timezoneId: 'Asia/Baghdad', utcOffsetStandard: 3.0, datasetKey: 'Basrah'),
        WorldCity(id: 'Najaf', nameEn: 'Najaf', nameAr: 'النجف', nameKu: 'نەجەف', countryEn: 'Iraq', countryAr: 'العراق', countryKu: 'عێراق', latitude: 32.0003, longitude: 44.3354, timezoneId: 'Asia/Baghdad', utcOffsetStandard: 3.0, datasetKey: 'Najaf'),
        WorldCity(id: 'Karbala', nameEn: 'Karbala', nameAr: 'كربلاء', nameKu: 'کەربەلا', countryEn: 'Iraq', countryAr: 'العراق', countryKu: 'عێراق', latitude: 32.6160, longitude: 44.0249, timezoneId: 'Asia/Baghdad', utcOffsetStandard: 3.0, datasetKey: 'Karbala'),
        WorldCity(id: 'Samarra', nameEn: 'Samarra', nameAr: 'سامراء', nameKu: 'سامەڕا', countryEn: 'Iraq', countryAr: 'العراق', countryKu: 'عێراق', latitude: 34.1983, longitude: 43.8742, timezoneId: 'Asia/Baghdad', utcOffsetStandard: 3.0, datasetKey: 'Samarra\''),
        WorldCity(id: 'Hillah', nameEn: 'Hillah (Babil)', nameAr: 'الحلة (بابل)', nameKu: 'حللەی بابیل', countryEn: 'Iraq', countryAr: 'العراق', countryKu: 'عێراق', latitude: 32.4833, longitude: 44.4333, timezoneId: 'Asia/Baghdad', utcOffsetStandard: 3.0, datasetKey: 'Hillah'),
        WorldCity(id: 'Nasiriyah', nameEn: 'Nasiriyah (Dhi Qar)', nameAr: 'الناصرية (ذي قار)', nameKu: 'ناسر تەقیار', countryEn: 'Iraq', countryAr: 'العراق', countryKu: 'عێراق', latitude: 31.0500, longitude: 46.2500, timezoneId: 'Asia/Baghdad', utcOffsetStandard: 3.0, datasetKey: 'Nasiriyah'),
        WorldCity(id: 'Amarah', nameEn: 'Amarah (Maysan)', nameAr: 'العمارة (ميسان)', nameKu: 'عەمارە', countryEn: 'Iraq', countryAr: 'العراق', countryKu: 'عێراق', latitude: 31.8333, longitude: 47.1500, timezoneId: 'Asia/Baghdad', utcOffsetStandard: 3.0, datasetKey: 'Amarah'),
        WorldCity(id: 'Ramadi', nameEn: 'Ramadi (Anbar)', nameAr: 'الرمادي (الأنبار)', nameKu: 'ڕەمادی', countryEn: 'Iraq', countryAr: 'العراق', countryKu: 'عێراق', latitude: 33.4256, longitude: 43.2992, timezoneId: 'Asia/Baghdad', utcOffsetStandard: 3.0, datasetKey: 'Ramadi'),
        WorldCity(id: 'Fallujah', nameEn: 'Fallujah', nameAr: 'الفلوجة', nameKu: 'فەللووجە', countryEn: 'Iraq', countryAr: 'العراق', countryKu: 'عێراق', latitude: 33.3500, longitude: 43.7833, timezoneId: 'Asia/Baghdad', utcOffsetStandard: 3.0, datasetKey: 'Al Fallujah'),
        WorldCity(id: 'Tikrit', nameEn: 'Tikrit (Saladin)', nameAr: 'تكريت (صلاح الدين)', nameKu: 'تکریت', countryEn: 'Iraq', countryAr: 'العراق', countryKu: 'عێراق', latitude: 34.5970, longitude: 43.6769, timezoneId: 'Asia/Baghdad', utcOffsetStandard: 3.0, datasetKey: 'Tikrit'),
        WorldCity(id: 'Baqubah', nameEn: 'Baqubah (Diyala)', nameAr: 'بعقوبة (ديالى)', nameKu: 'بەعقووبە', countryEn: 'Iraq', countryAr: 'العراق', countryKu: 'عێراق', latitude: 33.7500, longitude: 44.6500, timezoneId: 'Asia/Baghdad', utcOffsetStandard: 3.0, datasetKey: 'Baqubah'),
        WorldCity(id: 'Khanaqin', nameEn: 'Khanaqin', nameAr: 'خانقين', nameKu: 'خانەقین', countryEn: 'Iraq', countryAr: 'العراق', countryKu: 'عێراق', latitude: 34.3500, longitude: 45.3833, timezoneId: 'Asia/Baghdad', utcOffsetStandard: 3.0, datasetKey: 'Khanaqin'),
        WorldCity(id: 'Kut', nameEn: 'Kut (Wasit)', nameAr: 'الكوت (واسط)', nameKu: 'کوت', countryEn: 'Iraq', countryAr: 'العراق', countryKu: 'عێراق', latitude: 32.5000, longitude: 45.8167, timezoneId: 'Asia/Baghdad', utcOffsetStandard: 3.0, datasetKey: 'Kut'),
        WorldCity(id: 'Diwaniyah', nameEn: 'Diwaniyah (Qadisiyyah)', nameAr: 'الديوانية (القادسية)', nameKu: 'دیوانیە', countryEn: 'Iraq', countryAr: 'العراق', countryKu: 'عێراق', latitude: 31.9833, longitude: 44.9167, timezoneId: 'Asia/Baghdad', utcOffsetStandard: 3.0, datasetKey: 'Diwaniyah'),
        WorldCity(id: 'Samawah', nameEn: 'Samawah (Muthanna)', nameAr: 'السماوة (المثنى)', nameKu: 'سەماوە', countryEn: 'Iraq', countryAr: 'العراق', countryKu: 'عێراق', latitude: 31.3167, longitude: 45.2833, timezoneId: 'Asia/Baghdad', utcOffsetStandard: 3.0, datasetKey: 'Samawah'),
        WorldCity(id: 'Sinjar', nameEn: 'Sinjar / Shingal', nameAr: 'سنجار', nameKu: 'شەنگال', countryEn: 'Iraq', countryAr: 'العراق', countryKu: 'عێراق', latitude: 36.3208, longitude: 41.8761, timezoneId: 'Asia/Baghdad', utcOffsetStandard: 3.0, datasetKey: 'Sinjar'),
        WorldCity(id: 'TalAfar', nameEn: 'Tal Afar', nameAr: 'تلعفر', nameKu: 'تەلئەعفەر', countryEn: 'Iraq', countryAr: 'العراق', countryKu: 'عێراق', latitude: 36.3758, longitude: 42.4542, timezoneId: 'Asia/Baghdad', utcOffsetStandard: 3.0, datasetKey: 'Tal `Afar'),
      ],
    ),

    // 3. Saudi Arabia
    CountryGroup(
      id: 'saudi',
      nameEn: 'Saudi Arabia',
      nameAr: 'المملكة العربية السعودية',
      nameKu: 'عەرەبستانی سعودی',
      flag: '🇸🇦',
      cities: [
        WorldCity(id: 'Makkah', nameEn: 'Makkah Al-Mukarramah', nameAr: 'مكة المكرمة', nameKu: 'مەککەی پیرۆز', countryEn: 'Saudi Arabia', countryAr: 'السعودية', countryKu: 'سعودیە', latitude: 21.4225, longitude: 39.8262, timezoneId: 'Asia/Riyadh', utcOffsetStandard: 3.0, recommendedMethodId: 'umm_al_qura'),
        WorldCity(id: 'Madinah', nameEn: 'Madinah Al-Munawwarah', nameAr: 'المدينة المنورة', nameKu: 'مەدینەی پیرۆز', countryEn: 'Saudi Arabia', countryAr: 'السعودية', countryKu: 'سعودیە', latitude: 24.4672, longitude: 39.6112, timezoneId: 'Asia/Riyadh', utcOffsetStandard: 3.0, recommendedMethodId: 'umm_al_qura'),
        WorldCity(id: 'Riyadh', nameEn: 'Riyadh', nameAr: 'الرياض', nameKu: 'ڕیاز', countryEn: 'Saudi Arabia', countryAr: 'السعودية', countryKu: 'سعودیە', latitude: 24.7136, longitude: 46.6753, timezoneId: 'Asia/Riyadh', utcOffsetStandard: 3.0, recommendedMethodId: 'umm_al_qura'),
        WorldCity(id: 'Jeddah', nameEn: 'Jeddah', nameAr: 'جدة', nameKu: 'جەددە', countryEn: 'Saudi Arabia', countryAr: 'السعودية', countryKu: 'سعودیە', latitude: 21.5433, longitude: 39.1728, timezoneId: 'Asia/Riyadh', utcOffsetStandard: 3.0, recommendedMethodId: 'umm_al_qura'),
        WorldCity(id: 'Dammam', nameEn: 'Dammam', nameAr: 'الدمام', nameKu: 'دەوڵەتی دەمام', countryEn: 'Saudi Arabia', countryAr: 'السعودية', countryKu: 'سعودیە', latitude: 26.4207, longitude: 50.0888, timezoneId: 'Asia/Riyadh', utcOffsetStandard: 3.0, recommendedMethodId: 'umm_al_qura'),
      ],
    ),

    // 4. Turkey
    CountryGroup(
      id: 'turkey',
      nameEn: 'Turkey',
      nameAr: 'تركيا',
      nameKu: 'تورکیا',
      flag: '🇹🇷',
      cities: [
        WorldCity(id: 'Istanbul', nameEn: 'Istanbul', nameAr: 'إسطنبول', nameKu: 'ئەستەنبوڵ', countryEn: 'Turkey', countryAr: 'تركيا', countryKu: 'تورکیا', latitude: 41.0082, longitude: 28.9784, timezoneId: 'Europe/Istanbul', utcOffsetStandard: 3.0, recommendedMethodId: 'diyanet'),
        WorldCity(id: 'Ankara', nameEn: 'Ankara', nameAr: 'أنقرة', nameKu: 'ئەنقەرە', countryEn: 'Turkey', countryAr: 'تركيا', countryKu: 'تورکیا', latitude: 39.9334, longitude: 32.8597, timezoneId: 'Europe/Istanbul', utcOffsetStandard: 3.0, recommendedMethodId: 'diyanet'),
        WorldCity(id: 'Diyarbakir', nameEn: 'Diyarbakır / Amed', nameAr: 'ديار بكر (أمد)', nameKu: 'ئامەد (دیاربەکر)', countryEn: 'Turkey', countryAr: 'تركيا', countryKu: 'تورکیا', latitude: 37.9144, longitude: 40.2306, timezoneId: 'Europe/Istanbul', utcOffsetStandard: 3.0, recommendedMethodId: 'diyanet'),
        WorldCity(id: 'Gaziantep', nameEn: 'Gaziantep / Dîlok', nameAr: 'غازي عنتاب', nameKu: 'دیلۆک (عەنتاب)', countryEn: 'Turkey', countryAr: 'تركيا', countryKu: 'تورکیا', latitude: 37.0662, longitude: 37.3833, timezoneId: 'Europe/Istanbul', utcOffsetStandard: 3.0, recommendedMethodId: 'diyanet'),
        WorldCity(id: 'Batman', nameEn: 'Batman / Êlih', nameAr: 'باتمان', nameKu: 'ئێلح (باتمان)', countryEn: 'Turkey', countryAr: 'تركيا', countryKu: 'تورکیا', latitude: 37.8812, longitude: 41.1351, timezoneId: 'Europe/Istanbul', utcOffsetStandard: 3.0, recommendedMethodId: 'diyanet'),
        WorldCity(id: 'Van', nameEn: 'Van / Wan', nameAr: 'فان', nameKu: 'وان', countryEn: 'Turkey', countryAr: 'تركيا', countryKu: 'تورکیا', latitude: 38.4942, longitude: 43.3800, timezoneId: 'Europe/Istanbul', utcOffsetStandard: 3.0, recommendedMethodId: 'diyanet'),
        WorldCity(id: 'Mardin', nameEn: 'Mardin / Mêrdîn', nameAr: 'ماردين', nameKu: 'مێردین', countryEn: 'Turkey', countryAr: 'تركيا', countryKu: 'تورکیا', latitude: 37.3129, longitude: 40.7350, timezoneId: 'Europe/Istanbul', utcOffsetStandard: 3.0, recommendedMethodId: 'diyanet'),
        WorldCity(id: 'Urfa', nameEn: 'Şanlıurfa / Riha', nameAr: 'أورفا', nameKu: 'ڕحا (ئورفا)', countryEn: 'Turkey', countryAr: 'تركيا', countryKu: 'تورکیا', latitude: 37.1674, longitude: 38.7954, timezoneId: 'Europe/Istanbul', utcOffsetStandard: 3.0, recommendedMethodId: 'diyanet'),
        WorldCity(id: 'Izmir', nameEn: 'Izmir', nameAr: 'إزمير', nameKu: 'ئیزمیر', countryEn: 'Turkey', countryAr: 'تركيا', countryKu: 'تورکیا', latitude: 38.4237, longitude: 27.1428, timezoneId: 'Europe/Istanbul', utcOffsetStandard: 3.0, recommendedMethodId: 'diyanet'),
      ],
    ),

    // 5. Iran
    CountryGroup(
      id: 'iran',
      nameEn: 'Iran',
      nameAr: 'إيران',
      nameKu: 'ئێران',
      flag: '🇮🇷',
      cities: [
        WorldCity(id: 'Tehran', nameEn: 'Tehran', nameAr: 'طهران', nameKu: 'تاران', countryEn: 'Iran', countryAr: 'إيران', countryKu: 'ئێران', latitude: 35.6892, longitude: 51.3890, timezoneId: 'Asia/Tehran', utcOffsetStandard: 3.5, recommendedMethodId: 'tehran'),
        WorldCity(id: 'Urmia', nameEn: 'Urmia / Urmiye', nameAr: 'أورومية', nameKu: 'ورمێ', countryEn: 'Iran', countryAr: 'إيران', countryKu: 'ئێران', latitude: 37.5527, longitude: 45.0761, timezoneId: 'Asia/Tehran', utcOffsetStandard: 3.5, datasetKey: 'Urmia'),
        WorldCity(id: 'Sanandaj', nameEn: 'Sanandaj / Sine', nameAr: 'سنندج', nameKu: 'سنە', countryEn: 'Iran', countryAr: 'إيران', countryKu: 'ئێران', latitude: 35.3144, longitude: 46.9923, timezoneId: 'Asia/Tehran', utcOffsetStandard: 3.5, datasetKey: 'Sanandaj'),
        WorldCity(id: 'Kermanshah', nameEn: 'Kermanshah / Kirmashan', nameAr: 'كرمانشاه', nameKu: 'کرماشان', countryEn: 'Iran', countryAr: 'إيران', countryKu: 'ئێران', latitude: 34.3142, longitude: 47.0650, timezoneId: 'Asia/Tehran', utcOffsetStandard: 3.5, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Mahabad', nameEn: 'Mahabad', nameAr: 'مهاباد', nameKu: 'مەهاباد', countryEn: 'Iran', countryAr: 'إيران', countryKu: 'ئێران', latitude: 36.7631, longitude: 45.7222, timezoneId: 'Asia/Tehran', utcOffsetStandard: 3.5, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Piranshahr', nameEn: 'Piranshahr', nameAr: 'بيرانشهر', nameKu: 'پیرانشار', countryEn: 'Iran', countryAr: 'إيران', countryKu: 'ئێران', latitude: 36.7010, longitude: 45.1413, timezoneId: 'Asia/Tehran', utcOffsetStandard: 3.5, datasetKey: 'Piranshahr'),
        WorldCity(id: 'Saqqez', nameEn: 'Saqqez', nameAr: 'سقز', nameKu: 'سەقز', countryEn: 'Iran', countryAr: 'إيران', countryKu: 'ئێران', latitude: 36.2497, longitude: 46.2735, timezoneId: 'Asia/Tehran', utcOffsetStandard: 3.5, datasetKey: 'Saqqez'),
        WorldCity(id: 'Baneh', nameEn: 'Baneh', nameAr: 'بانه', nameKu: 'بانە', countryEn: 'Iran', countryAr: 'إيران', countryKu: 'ئێران', latitude: 35.9975, longitude: 45.8853, timezoneId: 'Asia/Tehran', utcOffsetStandard: 3.5, datasetKey: 'Baneh'),
        WorldCity(id: 'Marivan', nameEn: 'Marivan', nameAr: 'مريوان', nameKu: 'مەریوان', countryEn: 'Iran', countryAr: 'إيران', countryKu: 'ئێران', latitude: 35.5269, longitude: 46.1761, timezoneId: 'Asia/Tehran', utcOffsetStandard: 3.5, datasetKey: 'Marivan'),
      ],
    ),

    // 6. Syria & Levant
    CountryGroup(
      id: 'syria',
      nameEn: 'Syria & Levant',
      nameAr: 'سوريا وبلاد الشام',
      nameKu: 'سووریا و شام',
      flag: '🇸🇾',
      cities: [
        WorldCity(id: 'Damascus', nameEn: 'Damascus', nameAr: 'دمشق', nameKu: 'دیمەشق', countryEn: 'Syria', countryAr: 'سوريا', countryKu: 'سووریا', latitude: 33.5138, longitude: 36.2765, timezoneId: 'Asia/Damascus', utcOffsetStandard: 3.0, datasetKey: 'Damascus'),
        WorldCity(id: 'Qamishli', nameEn: 'Qamishli / Qamişlo', nameAr: 'القامشلي', nameKu: 'قامیشلۆ', countryEn: 'Syria', countryAr: 'سوريا', countryKu: 'سووریا', latitude: 37.0522, longitude: 41.2222, timezoneId: 'Asia/Damascus', utcOffsetStandard: 3.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Hasakah', nameEn: 'Hasakah / Heseke', nameAr: 'الحسكة', nameKu: 'حەسەکە', countryEn: 'Syria', countryAr: 'سوريا', countryKu: 'سووریا', latitude: 36.5024, longitude: 40.7477, timezoneId: 'Asia/Damascus', utcOffsetStandard: 3.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Aleppo', nameEn: 'Aleppo', nameAr: 'حلب', nameKu: 'حەلەب', countryEn: 'Syria', countryAr: 'سوريا', countryKu: 'سووریا', latitude: 36.2021, longitude: 37.1343, timezoneId: 'Asia/Damascus', utcOffsetStandard: 3.0, datasetKey: 'Aleppo'),
        WorldCity(id: 'Homs', nameEn: 'Homs', nameAr: 'حمص', nameKu: 'حمس', countryEn: 'Syria', countryAr: 'سوريا', countryKu: 'سووریا', latitude: 34.7324, longitude: 36.7137, timezoneId: 'Asia/Damascus', utcOffsetStandard: 3.0, datasetKey: 'Homs'),
        WorldCity(id: 'Amman', nameEn: 'Amman', nameAr: 'عمان', nameKu: 'عەممان', countryEn: 'Jordan', countryAr: 'الأردن', countryKu: 'ئوردن', latitude: 31.9454, longitude: 35.9284, timezoneId: 'Asia/Amman', utcOffsetStandard: 3.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Beirut', nameEn: 'Beirut', nameAr: 'بيروت', nameKu: 'بەیرووت', countryEn: 'Lebanon', countryAr: 'لبنان', countryKu: 'لوبنان', latitude: 33.8938, longitude: 35.5018, timezoneId: 'Asia/Beirut', utcOffsetStandard: 2.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Jerusalem', nameEn: 'Al-Quds / Jerusalem', nameAr: 'القدس الشريف', nameKu: 'قودس', countryEn: 'Palestine', countryAr: 'فلسطين', countryKu: 'فەلەستین', latitude: 31.7683, longitude: 35.2137, timezoneId: 'Asia/Jerusalem', utcOffsetStandard: 2.0, recommendedMethodId: 'mwl'),
      ],
    ),

    // 7. Gulf States
    CountryGroup(
      id: 'gulf',
      nameEn: 'Gulf States',
      nameAr: 'دول الخليج العربي',
      nameKu: 'دەوڵەتانی کەنداو',
      flag: '🇦🇪',
      cities: [
        WorldCity(id: 'Dubai', nameEn: 'Dubai', nameAr: 'دبي', nameKu: 'دوبەی', countryEn: 'UAE', countryAr: 'الإمارات', countryKu: 'ئیمارات', latitude: 25.2048, longitude: 55.2708, timezoneId: 'Asia/Dubai', utcOffsetStandard: 4.0, recommendedMethodId: 'dubai', datasetKey: 'Dubai'),
        WorldCity(id: 'AbuDhabi', nameEn: 'Abu Dhabi', nameAr: 'أبو ظبي', nameKu: 'ئەبو زەبی', countryEn: 'UAE', countryAr: 'الإمارات', countryKu: 'ئیمارات', latitude: 24.4539, longitude: 54.3773, timezoneId: 'Asia/Dubai', utcOffsetStandard: 4.0, recommendedMethodId: 'gulf', datasetKey: 'Abu Dhabi'),
        WorldCity(id: 'Sharjah', nameEn: 'Sharjah', nameAr: 'الشارقة', nameKu: 'شارقە', countryEn: 'UAE', countryAr: 'الإمارات', countryKu: 'ئیمارات', latitude: 25.3463, longitude: 55.4209, timezoneId: 'Asia/Dubai', utcOffsetStandard: 4.0, recommendedMethodId: 'gulf', datasetKey: 'Dubai'),
        WorldCity(id: 'Doha', nameEn: 'Doha', nameAr: 'الدوحة', nameKu: 'دەوحە', countryEn: 'Qatar', countryAr: 'قطر', countryKu: 'قەتەر', latitude: 25.2854, longitude: 51.5310, timezoneId: 'Asia/Qatar', utcOffsetStandard: 3.0, recommendedMethodId: 'gulf'),
        WorldCity(id: 'KuwaitCity', nameEn: 'Kuwait City', nameAr: 'مدينة الكويت', nameKu: 'کوێت سیتی', countryEn: 'Kuwait', countryAr: 'الكويت', countryKu: 'کوێت', latitude: 29.3759, longitude: 47.9774, timezoneId: 'Asia/Kuwait', utcOffsetStandard: 3.0, recommendedMethodId: 'gulf'),
        WorldCity(id: 'Manama', nameEn: 'Manama', nameAr: 'المنامة', nameKu: 'مەنامە', countryEn: 'Bahrain', countryAr: 'البحرين', countryKu: 'بەحرەین', latitude: 26.2285, longitude: 50.5860, timezoneId: 'Asia/Bahrain', utcOffsetStandard: 3.0, recommendedMethodId: 'gulf'),
        WorldCity(id: 'Muscat', nameEn: 'Muscat', nameAr: 'مسقط', nameKu: 'مەسقەت', countryEn: 'Oman', countryAr: 'عمان', countryKu: 'عومان', latitude: 23.5859, longitude: 58.4059, timezoneId: 'Asia/Muscat', utcOffsetStandard: 4.0, recommendedMethodId: 'gulf'),
      ],
    ),

    // 8. Egypt & North Africa
    CountryGroup(
      id: 'egypt',
      nameEn: 'Egypt & North Africa',
      nameAr: 'مصر وشمال إفريقيا',
      nameKu: 'میسر و باکووری ئەفریقا',
      flag: '🇪🇬',
      cities: [
        WorldCity(id: 'Cairo', nameEn: 'Cairo', nameAr: 'القاهرة', nameKu: 'قاهیرە', countryEn: 'Egypt', countryAr: 'مصر', countryKu: 'میسر', latitude: 30.0444, longitude: 31.2357, timezoneId: 'Africa/Cairo', utcOffsetStandard: 2.0, recommendedMethodId: 'egypt'),
        WorldCity(id: 'Alexandria', nameEn: 'Alexandria', nameAr: 'الإسكندرية', nameKu: 'ئەلێکساندریا', countryEn: 'Egypt', countryAr: 'مصر', countryKu: 'میسر', latitude: 31.2001, longitude: 29.9187, timezoneId: 'Africa/Cairo', utcOffsetStandard: 2.0, recommendedMethodId: 'egypt'),
        WorldCity(id: 'Giza', nameEn: 'Giza', nameAr: 'الجيزة', nameKu: 'جیزە', countryEn: 'Egypt', countryAr: 'مصر', countryKu: 'میسر', latitude: 30.0131, longitude: 31.2089, timezoneId: 'Africa/Cairo', utcOffsetStandard: 2.0, recommendedMethodId: 'egypt'),
        WorldCity(id: 'Casablanca', nameEn: 'Casablanca', nameAr: 'الدار البيضاء', nameKu: 'کازابلانکا', countryEn: 'Morocco', countryAr: 'المغرب', countryKu: 'مەغریب', latitude: 33.5731, longitude: -7.5898, timezoneId: 'Africa/Casablanca', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Tunis', nameEn: 'Tunis', nameAr: 'تونس', nameKu: 'توونس', countryEn: 'Tunisia', countryAr: 'تونس', countryKu: 'توونس', latitude: 36.8065, longitude: 10.1815, timezoneId: 'Africa/Tunis', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Algiers', nameEn: 'Algiers', nameAr: 'الجزائر', nameKu: 'جەزائیر', countryEn: 'Algeria', countryAr: 'الجزائر', countryKu: 'جەزائیر', latitude: 36.7538, longitude: 3.0588, timezoneId: 'Africa/Algiers', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
      ],
    ),

    // 9. Europe
    CountryGroup(
      id: 'europe',
      nameEn: 'Europe',
      nameAr: 'أوروبا',
      nameKu: 'ئەوروپا',
      flag: '🇪🇺',
      cities: [
        WorldCity(id: 'London', nameEn: 'London', nameAr: 'لندن', nameKu: 'لەندن', countryEn: 'UK', countryAr: 'المملكة المتحدة', countryKu: 'بەریتانیا', latitude: 51.5074, longitude: -0.1278, timezoneId: 'Europe/London', utcOffsetStandard: 0.0, recommendedMethodId: 'mwl', datasetKey: 'London'),
        WorldCity(id: 'Paris', nameEn: 'Paris', nameAr: 'باريس', nameKu: 'پاریس', countryEn: 'France', countryAr: 'فرنسا', countryKu: 'فەرەنسا', latitude: 48.8566, longitude: 2.3522, timezoneId: 'Europe/Paris', utcOffsetStandard: 1.0, recommendedMethodId: 'france', datasetKey: 'Paris'),
        WorldCity(id: 'Berlin', nameEn: 'Berlin', nameAr: 'برلين', nameKu: 'بەرلین', countryEn: 'Germany', countryAr: 'ألمانيا', countryKu: 'ئەڵمانیا', latitude: 52.5200, longitude: 13.4050, timezoneId: 'Europe/Berlin', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl', datasetKey: 'Berlin'),
        WorldCity(id: 'Frankfurt', nameEn: 'Frankfurt', nameAr: 'فرانكفورت', nameKu: 'فرانکفۆرت', countryEn: 'Germany', countryAr: 'ألمانيا', countryKu: 'ئەڵمانیا', latitude: 50.1109, longitude: 8.6821, timezoneId: 'Europe/Berlin', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Amsterdam', nameEn: 'Amsterdam', nameAr: 'أمستردام', nameKu: 'ئەمستەردام', countryEn: 'Netherlands', countryAr: 'هولندا', countryKu: 'هۆڵەندا', latitude: 52.3676, longitude: 4.9041, timezoneId: 'Europe/Amsterdam', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Stockholm', nameEn: 'Stockholm', nameAr: 'ستوكهولم', nameKu: 'ستۆکهۆڵم', countryEn: 'Sweden', countryAr: 'السويد', countryKu: 'سوید', latitude: 59.3293, longitude: 18.0686, timezoneId: 'Europe/Stockholm', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Oslo', nameEn: 'Oslo', nameAr: 'أوسلو', nameKu: 'ئۆسلۆ', countryEn: 'Norway', countryAr: 'النرويج', countryKu: 'نەرویژ', latitude: 59.9139, longitude: 10.7522, timezoneId: 'Europe/Oslo', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Vienna', nameEn: 'Vienna', nameAr: 'فيينا', nameKu: 'ڤییەنا', countryEn: 'Austria', countryAr: 'النمسا', countryKu: 'نەمسا', latitude: 48.2082, longitude: 16.3738, timezoneId: 'Europe/Vienna', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Rome', nameEn: 'Rome', nameAr: 'روما', nameKu: 'ڕۆما', countryEn: 'Italy', countryAr: 'إيطاليا', countryKu: 'ئیتاڵیا', latitude: 41.9028, longitude: 12.4964, timezoneId: 'Europe/Rome', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Madrid', nameEn: 'Madrid', nameAr: 'مدريد', nameKu: 'مەدرید', countryEn: 'Spain', countryAr: 'إسبانيا', countryKu: 'ئیسپانیا', latitude: 40.4168, longitude: -3.7038, timezoneId: 'Europe/Madrid', utcOffsetStandard: 1.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Moscow', nameEn: 'Moscow', nameAr: 'موسكو', nameKu: 'مۆسکۆ', countryEn: 'Russia', countryAr: 'روسيا', countryKu: 'ڕووسیا', latitude: 55.7558, longitude: 37.6173, timezoneId: 'Europe/Moscow', utcOffsetStandard: 3.0, recommendedMethodId: 'russia'),
      ],
    ),

    // 10. Americas
    CountryGroup(
      id: 'americas',
      nameEn: 'Americas',
      nameAr: 'الأمريكتان',
      nameKu: 'ئەمریکاکان',
      flag: '🌎',
      cities: [
        WorldCity(id: 'NewYork', nameEn: 'New York', nameAr: 'نيويورك', nameKu: 'نیویۆرک', countryEn: 'USA', countryAr: 'أمريكا', countryKu: 'ئەمریکا', latitude: 40.7128, longitude: -74.0060, timezoneId: 'America/New_York', utcOffsetStandard: -5.0, recommendedMethodId: 'isna'),
        WorldCity(id: 'Chicago', nameEn: 'Chicago', nameAr: 'شيكاغو', nameKu: 'شیکاگۆ', countryEn: 'USA', countryAr: 'أمريكا', countryKu: 'ئەمریکا', latitude: 41.8781, longitude: -87.6298, timezoneId: 'America/Chicago', utcOffsetStandard: -6.0, recommendedMethodId: 'isna'),
        WorldCity(id: 'LosAngeles', nameEn: 'Los Angeles', nameAr: 'لوس أنجلوس', nameKu: 'لۆس ئەنجلەس', countryEn: 'USA', countryAr: 'أمريكا', countryKu: 'ئەمریکا', latitude: 34.0522, longitude: -118.2437, timezoneId: 'America/Los_Angeles', utcOffsetStandard: -8.0, recommendedMethodId: 'isna'),
        WorldCity(id: 'Houston', nameEn: 'Houston', nameAr: 'هيوستن', nameKu: 'هیۆستن', countryEn: 'USA', countryAr: 'أمريكا', countryKu: 'ئەمریکا', latitude: 29.7604, longitude: -95.3698, timezoneId: 'America/Chicago', utcOffsetStandard: -6.0, recommendedMethodId: 'isna'),
        WorldCity(id: 'Toronto', nameEn: 'Toronto', nameAr: 'تورونتو', nameKu: 'تۆرۆنتۆ', countryEn: 'Canada', countryAr: 'كندا', countryKu: 'کەنەدا', latitude: 43.6532, longitude: -79.3832, timezoneId: 'America/Toronto', utcOffsetStandard: -5.0, recommendedMethodId: 'isna'),
        WorldCity(id: 'Vancouver', nameEn: 'Vancouver', nameAr: 'فانكوفر', nameKu: 'ڤانکۆڤەر', countryEn: 'Canada', countryAr: 'كندا', countryKu: 'کەنەدا', latitude: 49.2827, longitude: -123.1207, timezoneId: 'America/Vancouver', utcOffsetStandard: -8.0, recommendedMethodId: 'isna'),
      ],
    ),

    // 11. Asia & Pacific
    CountryGroup(
      id: 'asia',
      nameEn: 'Asia & Pacific',
      nameAr: 'آسيا والمحيط الهادئ',
      nameKu: 'ئاسیا و پاسیفیک',
      flag: '🌏',
      cities: [
        WorldCity(id: 'Karachi', nameEn: 'Karachi', nameAr: 'كراتشي', nameKu: 'کراچی', countryEn: 'Pakistan', countryAr: 'باكستان', countryKu: 'پاکستان', latitude: 24.8607, longitude: 67.0011, timezoneId: 'Asia/Karachi', utcOffsetStandard: 5.0, recommendedMethodId: 'karachi'),
        WorldCity(id: 'Lahore', nameEn: 'Lahore', nameAr: 'لاهور', nameKu: 'لاهوور', countryEn: 'Pakistan', countryAr: 'باكستان', countryKu: 'پاکستان', latitude: 31.5204, longitude: 74.3587, timezoneId: 'Asia/Karachi', utcOffsetStandard: 5.0, recommendedMethodId: 'karachi'),
        WorldCity(id: 'KualaLumpur', nameEn: 'Kuala Lumpur', nameAr: 'كوالالمبور', nameKu: 'کوالالامپور', countryEn: 'Malaysia', countryAr: 'ماليزيا', countryKu: 'مالیزیا', latitude: 3.1390, longitude: 101.6869, timezoneId: 'Asia/Kuala_Lumpur', utcOffsetStandard: 8.0, recommendedMethodId: 'singapore'),
        WorldCity(id: 'Jakarta', nameEn: 'Jakarta', nameAr: 'جاكرتا', nameKu: 'جاکارتا', countryEn: 'Indonesia', countryAr: 'إندونيسيا', countryKu: 'ئەندەنوسیا', latitude: -6.2088, longitude: 106.8456, timezoneId: 'Asia/Jakarta', utcOffsetStandard: 7.0, recommendedMethodId: 'indonesia'),
        WorldCity(id: 'Singapore', nameEn: 'Singapore', nameAr: 'سنغافورة', nameKu: 'سەنگافورە', countryEn: 'Singapore', countryAr: 'سنغافورة', countryKu: 'سەنگافورە', latitude: 1.3521, longitude: 103.8198, timezoneId: 'Asia/Singapore', utcOffsetStandard: 8.0, recommendedMethodId: 'singapore'),
        WorldCity(id: 'Tokyo', nameEn: 'Tokyo', nameAr: 'طوكيو', nameKu: 'تۆکیۆ', countryEn: 'Japan', countryAr: 'اليابان', countryKu: 'ژاپۆن', latitude: 35.6762, longitude: 139.6503, timezoneId: 'Asia/Tokyo', utcOffsetStandard: 9.0, recommendedMethodId: 'mwl'),
        WorldCity(id: 'Sydney', nameEn: 'Sydney', nameAr: 'سيدني', nameKu: 'سیدنی', countryEn: 'Australia', countryAr: 'أستراليا', countryKu: 'ئوسترالیا', latitude: -33.8688, longitude: 151.2093, timezoneId: 'Australia/Sydney', utcOffsetStandard: 10.0, recommendedMethodId: 'mwl'),
      ],
    ),
  ];

  /// Flattened list of all cities across all country groups.
  static List<WorldCity> get allCities {
    final list = <WorldCity>[];
    for (final group in countryGroups) {
      list.addAll(group.cities);
    }
    return list;
  }

  static WorldCity byId(String id) {
    final lower = id.trim().toLowerCase();
    return allCities.firstWhere(
      (c) =>
          c.id.toLowerCase() == lower ||
          c.nameEn.toLowerCase() == lower ||
          c.nameKu.toLowerCase() == lower ||
          c.nameAr.toLowerCase() == lower ||
          (lower == 'erbil' && c.id == 'Hawler') ||
          (lower == 'saidsadiq' && c.id == 'SaidSadiq') ||
          (lower == 'said sadiq' && c.id == 'SaidSadiq') ||
          (lower == 'سەیدسادق' && c.id == 'SaidSadiq') ||
          (lower == 'سەید سادق' && c.id == 'SaidSadiq'),
      orElse: () => allCities.first,
    );
  }

  static WorldCity nearestCity(double latitude, double longitude) {
    WorldCity nearest = allCities.first;
    double shortestDistance = double.infinity;
    for (final city in allCities) {
      final latDiff = latitude - city.latitude;
      final lonDiff = longitude - city.longitude;
      final dist = latDiff * latDiff + lonDiff * lonDiff;
      if (dist < shortestDistance) {
        shortestDistance = dist;
        nearest = city;
      }
    }
    return nearest;
  }
}

/// Unified Prayer Times Schedule Item
class PrayerTimeItem {
  final String id;
  final String nameEn;
  final String nameAr;
  final String nameKu;
  final DateTime time;
  final bool isPassed;
  final bool isNext;

  const PrayerTimeItem({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.nameKu,
    required this.time,
    required this.isPassed,
    required this.isNext,
  });

  String localizedName(String locale) {
    if (locale == 'ku') return nameKu;
    if (locale == 'ar') return nameAr;
    return nameEn;
  }

  String formattedTime() {
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
}

/// Hijri Date Model
class HijriDateInfo {
  final int day;
  final int month;
  final int year;
  final String monthNameAr;
  final String monthNameEn;
  final String monthNameKu;

  const HijriDateInfo({
    required this.day,
    required this.month,
    required this.year,
    required this.monthNameAr,
    required this.monthNameEn,
    required this.monthNameKu,
  });

  String formatted(String locale) {
    final monthStr = locale == 'ku' ? monthNameKu : (locale == 'ar' ? monthNameAr : monthNameEn);
    return '$day $monthStr $year AH';
  }

  /// Approximate Gregorian to Hijri conversion using Ku-calendar algorithm with optional day offset
  static HijriDateInfo fromGregorian(DateTime date, {int offsetDays = 0}) {
    final effectiveDate = offsetDays == 0 ? date : date.add(Duration(days: offsetDays));
    final jd = _gregorianToJulianDay(effectiveDate.year, effectiveDate.month, effectiveDate.day);
    final l = jd - 1948440 + 10632;
    final n = ((l - 1) / 10631).floor();
    final l1 = l - 10631 * n + 354;
    final j = (((10985 - l1) / 5316).floor()) * (((50 * l1) / 17719).floor()) +
        (((l1 / 5670).floor()) * (((43 * l1) / 15238).floor()));
    final l2 = l1 - (((30 - j) / 15).floor()) * (((17719 * j) / 50).floor()) -
        ((j / 30).floor()) * (((15238 * j) / 43).floor()) + 29;
    final month = ((24 * l2) / 709).floor();
    final day = l2 - ((709 * month) / 24).floor();
    final year = 30 * n + j - 30;

    const monthsAr = [
      'محرم', 'صفر', 'ربيع الأول', 'ربيع الثاني', 'جمادى الأولى', 'جمادى الآخرة',
      'رجب', 'شعبان', 'رمضان', 'شوال', 'ذو القعدة', 'ذو الحجة'
    ];
    const monthsEn = [
      'Muharram', 'Safar', 'Rabi\' al-Awwal', 'Rabi\' al-Thani', 'Jumada al-Ula', 'Jumada al-Akhirah',
      'Rajab', 'Sha\'ban', 'Ramadan', 'Shawwal', 'Dhu al-Qi\'dah', 'Dhu al-Hijjah'
    ];
    const monthsKu = [
      'مۆحەرەم', 'سەفەر', 'ڕەبیعی ئەوەل', 'ڕەبیعی دووەم', 'جومادەل ئوولا', 'جومادەل ئاخیرە',
      'ڕەجەب', 'شەعبان', 'ڕەمەزان', 'شەووال', 'زولقەعدە', 'زولحیججە'
    ];

    final clampedMonth = month.clamp(1, 12) - 1;
    return HijriDateInfo(
      day: day.clamp(1, 30),
      month: clampedMonth + 1,
      year: year,
      monthNameAr: monthsAr[clampedMonth],
      monthNameEn: monthsEn[clampedMonth],
      monthNameKu: monthsKu[clampedMonth],
    );
  }

  static int _gregorianToJulianDay(int year, int month, int day) {
    if (month < 3) {
      year -= 1;
      month += 12;
    }
    final a = (year / 100).floor();
    final b = 2 - a + (a / 4).floor();
    return (365.25 * (year + 4716)).floor() + (30.6001 * (month + 1)).floor() + day + b - 1524;
  }
}

/// Unified Prayer Times Repository
class PrayerRepository {
  static PrayerTimesCatalog? _cachedCatalog;

  /// Preload official dataset into memory at app launch
  static Future<void> preload() => _getOfficialCatalog();

  static Future<PrayerTimesCatalog?> _getOfficialCatalog() async {
    if (_cachedCatalog != null) return _cachedCatalog;
    try {
      _cachedCatalog = await PrayerTimesService.load();
      return _cachedCatalog;
    } catch (_) {
      return null;
    }
  }

  static Future<Map<String, dynamic>> getPrayerScheduleForDate({
    required DateTime date,
    bool forceGps = false,
  }) async {
    final methodId = StorageService.getPrayerMethod();
    final asrSchoolStr = StorageService.getPrayerAsrSchool();
    final highLatStr = StorageService.getPrayerHighLatRule();
    final locationMode = StorageService.getPrayerLocationMode();
    final cityId = StorageService.getPrayerSelectedCity();
    final customCoords = StorageService.getPrayerCustomCoordinates();
    final offsets = StorageService.getPrayerMinuteOffsets();

    final method = CalculationMethod.byId(methodId);
    final asrSchool = asrSchoolStr == 'hanafi' ? AsrSchool.hanafi : AsrSchool.shafi;
    HighLatitudeRule highLatRule;
    switch (highLatStr) {
      case 'one_seventh':
        highLatRule = HighLatitudeRule.oneSeventh;
        break;
      case 'angle_based':
        highLatRule = HighLatitudeRule.angleBased;
        break;
      default:
        highLatRule = HighLatitudeRule.nightMiddle;
    }

    double lat = 36.1911; // Default Erbil
    double lng = 44.0092;
    String locationNameKu = 'هەولێر';
    String locationNameAr = 'أربيل';
    String locationNameEn = 'Hewlêr / Erbil';
    String locationName = 'Hewlêr / Erbil';
    WorldCity? currentCity;

    if (locationMode == 'gps') {
      final locRes = await LocationService.getCurrentLocation(forceGps: forceGps);
      lat = locRes.latitude;
      lng = locRes.longitude;
      currentCity = locRes.nearestCity;
      final gpsSuffixKu = locRes.isGpsSuccess ? " (GPS)" : "";
      final gpsSuffixAr = locRes.isGpsSuccess ? " (GPS)" : "";
      final gpsSuffixEn = locRes.isGpsSuccess ? " (GPS)" : " (GPS Fallback)";
      locationNameKu = '${currentCity.nameKu}$gpsSuffixKu';
      locationNameAr = '${currentCity.nameAr}$gpsSuffixAr';
      locationNameEn = '${currentCity.nameEn}$gpsSuffixEn';
      locationName = locationNameEn;
    } else if (locationMode == 'custom' && customCoords != null && customCoords.length >= 2) {
      lat = customCoords[0];
      lng = customCoords[1];
      currentCity = WorldCitiesCatalog.nearestCity(lat, lng);
      locationNameKu = 'دیاریکراو (${lat.toStringAsFixed(2)}, ${lng.toStringAsFixed(2)})';
      locationNameAr = 'مخصص (${lat.toStringAsFixed(2)}, ${lng.toStringAsFixed(2)})';
      locationNameEn = 'Custom (${lat.toStringAsFixed(2)}, ${lng.toStringAsFixed(2)})';
      locationName = locationNameEn;
    } else {
      currentCity = WorldCitiesCatalog.byId(cityId);
      lat = currentCity.latitude;
      lng = currentCity.longitude;
      locationNameKu = currentCity.nameKu;
      locationNameAr = currentCity.nameAr;
      locationNameEn = currentCity.nameEn;
      locationName = locationNameEn;
    }

    final targetUtcOffset = currentCity.resolveUtcOffset(date);
    final timezoneAbbr = currentCity.timezoneAbbreviation(date);

    // Official timetables represent the Kurdistan Endowments profile.
    Map<String, DateTime>? officialTimesMap;
    String dataSourceLabel = '⚡ 100% Offline Astronomical Math ($timezoneAbbr)';
    final isKurdistanAwqaf = methodId == 'kurdistan_endowments';
    bool isOfficial = false;

    if (isKurdistanAwqaf && currentCity.datasetKey != null) {
      final catalog = await _getOfficialCatalog();
      if (catalog != null && catalog.cities.containsKey(currentCity.datasetKey)) {
        final dayRecord = catalog.forDate(currentCity.datasetKey!, date);
        officialTimesMap = _parseOfficialDayTimes(date, dayRecord, offsets);
        isOfficial = true;
        dataSourceLabel = '✓ Authentic Local Official Timetable';

        // When Hanafi Asr is selected, preserve authentic Awqaf Fajr/Sunrise/Dhuhr/Maghrib/Isha
        // and adjust Asr by the precise astronomical offset between Shafi and Hanafi for this day
        if (asrSchool == AsrSchool.hanafi) {
          final shafiCalc = OfflinePrayerCalculator.calculate(
            latitude: lat,
            longitude: lng,
            date: date,
            method: method,
            asrSchool: AsrSchool.shafi,
            highLatRule: highLatRule,
            targetUtcOffsetHours: targetUtcOffset,
          );
          final hanafiCalc = OfflinePrayerCalculator.calculate(
            latitude: lat,
            longitude: lng,
            date: date,
            method: method,
            asrSchool: AsrSchool.hanafi,
            highLatRule: highLatRule,
            targetUtcOffsetHours: targetUtcOffset,
          );
          final delay = hanafiCalc.asr.difference(shafiCalc.asr);
          officialTimesMap['asr'] = officialTimesMap['asr']!.add(delay);
          dataSourceLabel = '✓ Authentic Timetable (Hanafi Asr)';
        }
      }
    }

    // Fallback to 100% offline astronomical calculation using the target city's real timezone offset
    final timesMap = officialTimesMap ?? OfflinePrayerCalculator.calculate(
      latitude: lat,
      longitude: lng,
      date: date,
      method: method,
      asrSchool: asrSchool,
      highLatRule: highLatRule,
      targetUtcOffsetHours: targetUtcOffset,
      minuteOffsets: offsets,
    ).toMap();

    final now = DateTime.now();

    const prayerNames = [
      {'id': 'fajr', 'en': 'Fajr', 'ar': 'الفجر', 'ku': 'بەیانی'},
      {'id': 'sunrise', 'en': 'Sunrise', 'ar': 'الشروق', 'ku': 'هەڵاتنی خۆر'},
      {'id': 'dhuhr', 'en': 'Dhuhr', 'ar': 'الظهر', 'ku': 'نیوەڕۆ'},
      {'id': 'asr', 'en': 'Asr', 'ar': 'العصر', 'ku': 'عەسر'},
      {'id': 'maghrib', 'en': 'Maghrib', 'ar': 'المغرب', 'ku': 'مەغریب'},
      {'id': 'isha', 'en': 'Isha', 'ar': 'العشاء', 'ku': 'عیشا'},
    ];

    // Find next prayer
    String nextId = 'fajr';
    DateTime? nextTime;
    for (final p in prayerNames) {
      final pTime = timesMap[p['id']]!;
      if (pTime.isAfter(now)) {
        nextId = p['id']!;
        nextTime = pTime;
        break;
      }
    }
    if (nextTime == null) {
      // All prayers passed for today, next is tomorrow's Fajr
      final tomorrowDate = date.add(const Duration(days: 1));
      final tomorrowTargetOffset = currentCity.resolveUtcOffset(tomorrowDate);
      Map<String, DateTime>? tomorrowOfficialMap;
      if (isKurdistanAwqaf && currentCity.datasetKey != null) {
        final catalog = await _getOfficialCatalog();
        if (catalog != null && catalog.cities.containsKey(currentCity.datasetKey)) {
          final dayRecord = catalog.forDate(currentCity.datasetKey!, tomorrowDate);
          tomorrowOfficialMap = _parseOfficialDayTimes(tomorrowDate, dayRecord, offsets);
          if (asrSchool == AsrSchool.hanafi) {
            final shafiCalc = OfflinePrayerCalculator.calculate(
              latitude: lat,
              longitude: lng,
              date: tomorrowDate,
              method: method,
              asrSchool: AsrSchool.shafi,
              highLatRule: highLatRule,
              targetUtcOffsetHours: tomorrowTargetOffset,
            );
            final hanafiCalc = OfflinePrayerCalculator.calculate(
              latitude: lat,
              longitude: lng,
              date: tomorrowDate,
              method: method,
              asrSchool: AsrSchool.hanafi,
              highLatRule: highLatRule,
              targetUtcOffsetHours: tomorrowTargetOffset,
            );
            final delay = hanafiCalc.asr.difference(shafiCalc.asr);
            tomorrowOfficialMap['asr'] = tomorrowOfficialMap['asr']!.add(delay);
          }
        }
      }
      final tomorrowTimes = tomorrowOfficialMap ?? OfflinePrayerCalculator.calculate(
        latitude: lat,
        longitude: lng,
        date: tomorrowDate,
        method: method,
        asrSchool: asrSchool,
        highLatRule: highLatRule,
        targetUtcOffsetHours: tomorrowTargetOffset,
        minuteOffsets: offsets,
      ).toMap();

      nextId = 'fajr';
      nextTime = tomorrowTimes['fajr'];
    }

    final items = prayerNames.map((p) {
      final id = p['id']!;
      final pTime = timesMap[id]!;
      return PrayerTimeItem(
        id: id,
        nameEn: p['en']!,
        nameAr: p['ar']!,
        nameKu: p['ku']!,
        time: pTime,
        isPassed: now.isAfter(pTime),
        isNext: id == nextId && (nextTime?.day == date.day),
      );
    }).toList();

    final hijriOffset = StorageService.getPrayerHijriOffset();
    final hijri = HijriDateInfo.fromGregorian(date, offsetDays: hijriOffset);

    return {
      'latitude': lat,
      'longitude': lng,
      'locationName': locationName,
      'locationNameKu': locationNameKu,
      'locationNameAr': locationNameAr,
      'locationNameEn': locationNameEn,
      'city': currentCity,
      'timezoneId': currentCity.timezoneId,
      'timezoneAbbr': timezoneAbbr,
      'targetUtcOffset': targetUtcOffset,
      'dataSource': dataSourceLabel,
      'isOfficialTimetable': isOfficial,
      'items': items,
      'nextId': nextId,
      'nextTime': nextTime,
      'hijriDate': hijri,
      'method': method,
      'asrSchool': asrSchool,
    };
  }

  /// Previews prayer times dynamically for any given configuration without saving to storage.
  static Future<Map<String, dynamic>> previewPrayerDayTimes({
    required DateTime date,
    required String methodId,
    required String asrSchoolStr,
    required String highLatStr,
    required Map<String, int> offsets,
    int hijriOffset = 0,
    WorldCity? city,
  }) async {
    final currentCity = city ?? WorldCitiesCatalog.byId(StorageService.getPrayerSelectedCity());
    final lat = currentCity.latitude;
    final lng = currentCity.longitude;
    final targetOffset = currentCity.resolveUtcOffset(date);
    final timezoneAbbr = currentCity.timezoneAbbreviation(date);

    final method = CalculationMethod.byId(methodId);
    final asrSchool = asrSchoolStr == 'hanafi' ? AsrSchool.hanafi : AsrSchool.shafi;
    final highLatRule = highLatStr == 'one_seventh'
        ? HighLatitudeRule.oneSeventh
        : (highLatStr == 'angle_based' ? HighLatitudeRule.angleBased : HighLatitudeRule.nightMiddle);

    final isKurdistanAwqaf = methodId == 'kurdistan_endowments';
    Map<String, DateTime>? officialTimesMap;
    bool isOfficial = false;

    if (isKurdistanAwqaf && currentCity.datasetKey != null) {
      final catalog = await _getOfficialCatalog();
      if (catalog != null && catalog.cities.containsKey(currentCity.datasetKey)) {
        final dayRecord = catalog.forDate(currentCity.datasetKey!, date);
        officialTimesMap = _parseOfficialDayTimes(date, dayRecord, offsets);
        isOfficial = true;

        if (asrSchool == AsrSchool.hanafi) {
          final shafiCalc = OfflinePrayerCalculator.calculate(
            latitude: lat,
            longitude: lng,
            date: date,
            method: method,
            asrSchool: AsrSchool.shafi,
            highLatRule: highLatRule,
            targetUtcOffsetHours: targetOffset,
          );
          final hanafiCalc = OfflinePrayerCalculator.calculate(
            latitude: lat,
            longitude: lng,
            date: date,
            method: method,
            asrSchool: AsrSchool.hanafi,
            highLatRule: highLatRule,
            targetUtcOffsetHours: targetOffset,
          );
          final delay = hanafiCalc.asr.difference(shafiCalc.asr);
          officialTimesMap['asr'] = officialTimesMap['asr']!.add(delay);
        }
      }
    }

    final timesMap = officialTimesMap ??
        OfflinePrayerCalculator.calculate(
          latitude: lat,
          longitude: lng,
          date: date,
          method: method,
          asrSchool: asrSchool,
          highLatRule: highLatRule,
          targetUtcOffsetHours: targetOffset,
          minuteOffsets: offsets,
        ).toMap();

    final hijri = HijriDateInfo.fromGregorian(date, offsetDays: hijriOffset);

    return {
      'times': timesMap,
      'isOfficialTimetable': isOfficial,
      'hijriDate': hijri,
      'timezoneAbbr': timezoneAbbr,
      'targetUtcOffset': targetOffset,
      'city': currentCity,
    };
  }

  static Map<String, DateTime> _parseOfficialDayTimes(
    DateTime date,
    PrayerDay day,
    Map<String, int> offsets,
  ) {
    DateTime parseTime(String hhmm, int offsetMinutes) {
      final parts = hhmm.split(':');
      final hour = int.tryParse(parts[0]) ?? 12;
      final minute = int.tryParse(parts[1]) ?? 0;
      final dt = DateTime(date.year, date.month, date.day, hour, minute);
      return dt.add(Duration(minutes: offsetMinutes));
    }

    return {
      'fajr': parseTime(day.fajr, offsets['fajr'] ?? 0),
      'sunrise': parseTime(day.sunrise, offsets['sunrise'] ?? 0),
      'dhuhr': parseTime(day.dhuhr, offsets['dhuhr'] ?? 0),
      'asr': parseTime(day.asr, offsets['asr'] ?? 0),
      'maghrib': parseTime(day.maghrib, offsets['maghrib'] ?? 0),
      'isha': parseTime(day.isha, offsets['isha'] ?? 0),
    };
  }
}
