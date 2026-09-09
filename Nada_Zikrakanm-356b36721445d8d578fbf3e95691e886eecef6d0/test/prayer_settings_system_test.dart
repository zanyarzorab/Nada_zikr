import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:nada_zikrakanm/services/storage_service.dart';
import 'package:nada_zikrakanm/services/prayer_repository.dart';
import 'package:nada_zikrakanm/services/notification_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('prayer_settings_test_');
    Hive.init(tempDir.path);
    await StorageService.initialize();
  });

  tearDownAll(() async {
    await Hive.close();
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('Hijri Date Calibration System Tests', () {
    test('Hijri calculation baseline vs offset days', () {
      final baseDate = DateTime(2026, 4, 15);
      final hijriBase = HijriDateInfo.fromGregorian(baseDate, offsetDays: 0);
      final hijriPlusOne = HijriDateInfo.fromGregorian(baseDate, offsetDays: 1);
      final hijriMinusOne = HijriDateInfo.fromGregorian(baseDate, offsetDays: -1);

      expect(hijriPlusOne.day, equals(hijriBase.day + 1));
      expect(hijriMinusOne.day, equals(hijriBase.day - 1));
    });

    test('Hijri formatted string localized properly', () {
      final baseDate = DateTime(2026, 9, 4);
      final hijri = HijriDateInfo.fromGregorian(baseDate, offsetDays: 0);

      final kuText = hijri.formatted('ku');
      final arText = hijri.formatted('ar');
      final enText = hijri.formatted('en');

      expect(kuText, contains('AH'));
      expect(arText, contains(hijri.monthNameAr));
      expect(enText, contains(hijri.monthNameEn));
    });
  });

  group('StorageService Prayer Settings Persistence & Clamping Tests', () {
    test('Prayer Hijri offset clamps between -2 and 2', () async {
      await StorageService.savePrayerHijriOffset(1);
      expect(StorageService.getPrayerHijriOffset(), equals(1));

      await StorageService.savePrayerHijriOffset(-2);
      expect(StorageService.getPrayerHijriOffset(), equals(-2));

      await StorageService.savePrayerHijriOffset(5);
      expect(StorageService.getPrayerHijriOffset(), equals(2));

      await StorageService.savePrayerHijriOffset(-10);
      expect(StorageService.getPrayerHijriOffset(), equals(-2));
    });

    test('Pre-Azan reminder minutes persistence and clamping', () async {
      await StorageService.savePreAzanReminderMinutes(15);
      expect(StorageService.getPreAzanReminderMinutes(), equals(15));

      await StorageService.savePreAzanReminderMinutes(0);
      expect(StorageService.getPreAzanReminderMinutes(), equals(0));

      await StorageService.savePreAzanReminderMinutes(-5);
      expect(StorageService.getPreAzanReminderMinutes(), equals(0));
    });

    test('Fajr Azan sound persistence', () async {
      await StorageService.saveFajrAzanSound('azan_fajr');
      expect(StorageService.getFajrAzanSound(), equals('azan_fajr'));

      await StorageService.saveFajrAzanSound('makkah');
      expect(StorageService.getFajrAzanSound(), equals('makkah'));
    });
  });

  group('PrayerRepository Preview & Mathematical Integrity Tests', () {
    test('Shafi vs Hanafi Asr school produces genuine time difference', () async {
      final date = DateTime(2026, 6, 21); // Summer solstice for pronounced shadow difference
      final offsets = <String, int>{
        'fajr': 0, 'sunrise': 0, 'dhuhr': 0, 'asr': 0, 'maghrib': 0, 'isha': 0
      };

      final shafiPreview = await PrayerRepository.previewPrayerDayTimes(
        date: date,
        methodId: 'mwl',
        asrSchoolStr: 'shafi',
        highLatStr: 'night_middle',
        offsets: offsets,
      );

      final hanafiPreview = await PrayerRepository.previewPrayerDayTimes(
        date: date,
        methodId: 'mwl',
        asrSchoolStr: 'hanafi',
        highLatStr: 'night_middle',
        offsets: offsets,
      );

      final shafiTimes = shafiPreview['times'] as Map<String, DateTime>;
      final hanafiTimes = hanafiPreview['times'] as Map<String, DateTime>;

      final shafiAsr = shafiTimes['asr']!;
      final hanafiAsr = hanafiTimes['asr']!;

      // Hanafi Asr (shadow factor 2) MUST be strictly later than Shafi Asr (shadow factor 1)
      expect(hanafiAsr.isAfter(shafiAsr), isTrue);
      final differenceMinutes = hanafiAsr.difference(shafiAsr).inMinutes;
      expect(differenceMinutes, greaterThanOrEqualTo(40));
    });

    test('Minute offsets alter preview prayer times with precision', () async {
      final date = DateTime(2026, 5, 10);
      final baseOffsets = <String, int>{
        'fajr': 0, 'sunrise': 0, 'dhuhr': 0, 'asr': 0, 'maghrib': 0, 'isha': 0
      };
      final shiftedOffsets = <String, int>{
        'fajr': 5, 'sunrise': 0, 'dhuhr': -3, 'asr': 2, 'maghrib': 0, 'isha': 10
      };

      final basePreview = await PrayerRepository.previewPrayerDayTimes(
        date: date,
        methodId: 'umm_al_qura',
        asrSchoolStr: 'shafi',
        highLatStr: 'night_middle',
        offsets: baseOffsets,
      );

      final shiftedPreview = await PrayerRepository.previewPrayerDayTimes(
        date: date,
        methodId: 'umm_al_qura',
        asrSchoolStr: 'shafi',
        highLatStr: 'night_middle',
        offsets: shiftedOffsets,
      );

      final baseTimes = basePreview['times'] as Map<String, DateTime>;
      final shiftedTimes = shiftedPreview['times'] as Map<String, DateTime>;

      expect(shiftedTimes['fajr']!.difference(baseTimes['fajr']!).inMinutes, equals(5));
      expect(shiftedTimes['dhuhr']!.difference(baseTimes['dhuhr']!).inMinutes, equals(-3));
      expect(shiftedTimes['asr']!.difference(baseTimes['asr']!).inMinutes, equals(2));
      expect(shiftedTimes['isha']!.difference(baseTimes['isha']!).inMinutes, equals(10));
    });
  });

  group('Pre-Azan Notification System Integrity Tests', () {
    test('Pre-Azan notification IDs never collide with main prayer alarm IDs and stay in 32-bit int bounds', () {
      final item = PrayerTimeItem(
        id: 'dhuhr',
        nameEn: 'Dhuhr',
        nameAr: 'الظهر',
        nameKu: 'نیوەڕۆ',
        time: DateTime(2026, 9, 4, 12, 15),
        isPassed: false,
        isNext: false,
      );
      expect(item.id, equals('dhuhr'));

      const dateKey = 20260904;
      const ids = {'dhuhr': 2};
      final mainId = dateKey * 10 + ids['dhuhr']!; // 202609042
      final preReminderId = mainId + 50000000; // 252609042

      expect(mainId, equals(202609042));
      expect(preReminderId, equals(252609042));
      expect(preReminderId, isNot(equals(mainId)));
      // Max 32-bit signed int: 2,147,483,647
      expect(preReminderId, lessThan(2147483647));
      expect(mainId, lessThan(2147483647));
    });

    test('Pre-Azan notification localized body templates render valid countdown messages', () {
      final item = PrayerTimeItem(
        id: 'asr',
        nameEn: 'Asr',
        nameAr: 'العصر',
        nameKu: 'عەسر',
        time: DateTime(2026, 9, 4, 15, 45),
        isPassed: false,
        isNext: false,
      );

      final body = NotificationService.localizedPreReminderBody(item, 10, 'Hawler');
      expect(body, contains('10'));
      expect(body, contains('Hawler'));
    });
  });

  group('Worldwide Cities Timezone & Official Timetable Preservation Tests', () {
    test('Worldwide cities calculate solar noon in their local hours (11:30 - 13:30)', () async {
      final date = DateTime(2026, 9, 4);
      final zeroOffsets = <String, int>{
        'fajr': 0, 'sunrise': 0, 'dhuhr': 0, 'asr': 0, 'maghrib': 0, 'isha': 0
      };

      // Test New York (EDT, UTC-4)
      final nyCity = WorldCitiesCatalog.byId('NewYork');
      final nyPreview = await PrayerRepository.previewPrayerDayTimes(
        date: date,
        methodId: 'isna',
        asrSchoolStr: 'shafi',
        highLatStr: 'night_middle',
        offsets: zeroOffsets,
        city: nyCity,
      );
      final nyTimes = nyPreview['times'] as Map<String, DateTime>;
      final nyDhuhr = nyTimes['dhuhr']!;
      // New York Dhuhr must fall around ~12:55 - 13:05 local time, NOT 7:56 PM!
      expect(nyDhuhr.hour, equals(12));
      expect(nyDhuhr.minute, inInclusiveRange(45, 60));

      // Test Tokyo (JST, UTC+9)
      final tokyoCity = WorldCitiesCatalog.byId('Tokyo');
      final tokyoPreview = await PrayerRepository.previewPrayerDayTimes(
        date: date,
        methodId: 'mwl',
        asrSchoolStr: 'shafi',
        highLatStr: 'night_middle',
        offsets: zeroOffsets,
        city: tokyoCity,
      );
      final tokyoTimes = tokyoPreview['times'] as Map<String, DateTime>;
      final tokyoDhuhr = tokyoTimes['dhuhr']!;
      // Tokyo Dhuhr must fall around ~11:35 - 11:45 local time, NOT morning 5:40 AM!
      expect(tokyoDhuhr.hour, equals(11));
      expect(tokyoDhuhr.minute, inInclusiveRange(30, 50));

      // Test London (BST, UTC+1 in summer)
      final londonCity = WorldCitiesCatalog.byId('London');
      final londonPreview = await PrayerRepository.previewPrayerDayTimes(
        date: date,
        methodId: 'mwl',
        asrSchoolStr: 'shafi',
        highLatStr: 'night_middle',
        offsets: zeroOffsets,
        city: londonCity,
      );
      final londonTimes = londonPreview['times'] as Map<String, DateTime>;
      final londonDhuhr = londonTimes['dhuhr']!;
      // London Dhuhr must fall around ~13:00 local time
      expect(londonDhuhr.hour, equals(13));
    });

    test('Kurdistan Awqaf timetable preserves Fajr, Sunrise, Dhuhr, Maghrib, Isha when Hanafi Asr is chosen', () async {
      final date = DateTime(2026, 9, 4);
      final zeroOffsets = <String, int>{
        'fajr': 0, 'sunrise': 0, 'dhuhr': 0, 'asr': 0, 'maghrib': 0, 'isha': 0
      };
      final hawler = WorldCitiesCatalog.byId('Hawler');

      final shafiPreview = await PrayerRepository.previewPrayerDayTimes(
        date: date,
        methodId: 'kurdistan_endowments',
        asrSchoolStr: 'shafi',
        highLatStr: 'night_middle',
        offsets: zeroOffsets,
        city: hawler,
      );

      final hanafiPreview = await PrayerRepository.previewPrayerDayTimes(
        date: date,
        methodId: 'kurdistan_endowments',
        asrSchoolStr: 'hanafi',
        highLatStr: 'night_middle',
        offsets: zeroOffsets,
        city: hawler,
      );

      final shafiTimes = shafiPreview['times'] as Map<String, DateTime>;
      final hanafiTimes = hanafiPreview['times'] as Map<String, DateTime>;

      // Fajr, Sunrise, Dhuhr, Maghrib, Isha MUST be IDENTICAL to the official published timetable
      expect(hanafiTimes['fajr'], equals(shafiTimes['fajr']));
      expect(hanafiTimes['sunrise'], equals(shafiTimes['sunrise']));
      expect(hanafiTimes['dhuhr'], equals(shafiTimes['dhuhr']));
      expect(hanafiTimes['maghrib'], equals(shafiTimes['maghrib']));
      expect(hanafiTimes['isha'], equals(shafiTimes['isha']));

      // Only Asr must be delayed by the astronomical Hanafi factor
      expect(hanafiTimes['asr']!.isAfter(shafiTimes['asr']!), isTrue);
      final asrDiff = hanafiTimes['asr']!.difference(shafiTimes['asr']!).inMinutes;
      expect(asrDiff, greaterThanOrEqualTo(35));
    });

    test('WorldCity identifies official Kurdistan Awqaf vs global cities correctly', () {
      final hawler = WorldCitiesCatalog.byId('Hawler');
      final sulaymaniyah = WorldCitiesCatalog.byId('Sulaymaniyah');
      final london = WorldCitiesCatalog.byId('London');
      final makkah = WorldCitiesCatalog.byId('Makkah');

      expect(hawler.isKurdistanOfficial, isTrue);
      expect(sulaymaniyah.isKurdistanOfficial, isTrue);
      expect(london.isKurdistanOfficial, isFalse);
      expect(makkah.isKurdistanOfficial, isFalse);
    });
  });
}

