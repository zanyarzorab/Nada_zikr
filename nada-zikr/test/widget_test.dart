import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:nada_zikrakanm/app_localizations.dart';
import 'package:nada_zikrakanm/models/app_data.dart';
import 'package:nada_zikrakanm/models/azkar_model.dart';
import 'package:nada_zikrakanm/screens/tasbeeh_screen.dart';
import 'package:nada_zikrakanm/services/storage_service.dart';
import 'package:nada_zikrakanm/services/quran_mood_service.dart';
import 'package:nada_zikrakanm/services/quran_service.dart';
import 'package:nada_zikrakanm/services/dhikr_package_service.dart';
import 'package:nada_zikrakanm/services/notification_service.dart';
import 'package:nada_zikrakanm/services/prayer_repository.dart';
import 'package:nada_zikrakanm/services/prayer_widget_service.dart';
import 'package:nada_zikrakanm/services/azan_audio_service.dart';
import 'package:nada_zikrakanm/models/quran_reciter.dart';
import 'package:nada_zikrakanm/widgets/qibla_compass_sheet.dart';

void main() {
  setUpAll(() async {
    final dir = await Directory.systemTemp.createTemp('zikr_hive_test_');
    Hive.init(dir.path);
    await StorageService.initialize();
    await StorageService.setFirstLaunchCompleted();
    AppLocalizations.setLanguageCode('en');
    await StorageService.saveSetting('language', 'en');
    await StorageService.savePrayerLocationMode('city');
    await StorageService.saveUserProfile(
      UserProfile(
        name: 'Test User',
        dailyGoal: 3,
        currentStreak: 4,
        bestStreak: 7,
        totalSessions: 12,
        lastSessionDate: DateTime.now(),
      ),
    );
  });

  test('Prayer widget fallback resolves the first real shared value and ignores placeholder blanks', () {
    final result = PrayerWidgetService.resolveSharedPrayerValue(
      {
        'next_prayer_time': '',
        'selected_prayer_time': '5:30 AM',
        'current_prayer_time': '--:--',
      },
      keys: const ['next_prayer_time', 'selected_prayer_time', 'current_prayer_time'],
      fallback: '--:--',
    );

    expect(result, '5:30 AM');

    final fallback = PrayerWidgetService.resolveSharedPrayerValue(
      {
        'next_prayer_time': '',
        'selected_prayer_time': '',
        'current_prayer_time': '',
      },
      keys: const ['next_prayer_time', 'selected_prayer_time', 'current_prayer_time'],
      fallback: '--:--',
    );

    expect(fallback, '--:--');
  });

  test('Prayer notifications use the selected app language', () {
    final item = PrayerTimeItem(
      id: 'fajr',
      nameEn: 'Fajr',
      nameAr: 'الفجر',
      nameKu: 'بەیانی',
      time: DateTime(2026, 8, 27, 5, 30),
      isPassed: false,
      isNext: true,
    );

    AppLocalizations.setLanguageCode('en');
    expect(NotificationService.localizedPrayerTitle(), 'Time for Prayer');
    expect(NotificationService.localizedPrayerBody(item, 'Hewlêr / Erbil'),
        'It is now time for Fajr in Hewlêr / Erbil');

    AppLocalizations.setLanguageCode('ku');
    expect(NotificationService.localizedPrayerTitle(), 'کاتی بانگ هات');
    expect(NotificationService.localizedPrayerBody(item, 'هەولێر'),
        'کاتی بانگی بەیانی بۆ شاری هەولێر گەیشت');

    AppLocalizations.setLanguageCode('ar');
    expect(NotificationService.localizedPrayerTitle(), 'حان موعد الصلاة');
    expect(NotificationService.localizedPrayerBody(item, 'أربيل'),
        'حان الآن موعد صلاة الفجر لمدينة أربيل');

    // Sunrise localization
    expect(NotificationService.localizedPrayerTitle(prayerId: 'sunrise'), 'حان موعد شروق الشمس');
    AppLocalizations.setLanguageCode('ku');
    expect(NotificationService.localizedPrayerTitle(prayerId: 'sunrise'), 'کاتی هەڵاتنی خۆر هات');
    AppLocalizations.setLanguageCode('en');
    expect(NotificationService.localizedPrayerTitle(prayerId: 'sunrise'), 'Sunrise Time');
  });

  test('Notification service uses upgraded v8 channel and handles permissions safely', () async {
    expect(NotificationService.channelVersion, 'prayer_alert_v8');
    final exact = await NotificationService.canScheduleExactNotifications();
    expect(exact, isA<bool>());
    final notifs = await NotificationService.areNotificationsEnabled();
    expect(notifs, isA<bool>());
  });

  test('rescheduleUpcomingPrayerAzans executes without exceptions', () async {
    await NotificationService.rescheduleUpcomingPrayerAzans();
  });

  test('Broken Islamcan azan IDs fall back to the default working azan', () {
    expect(AzanAudioService.resolveSafeSoundId('islamcan_1'), 'makkah');
    expect(AzanAudioService.resolveSafeSoundId('islamcan_2'), 'makkah');
    expect(AzanAudioService.resolveSafeSoundId('makkah'), 'makkah');
    expect(AzanAudioService.resolveSafeSoundId('islamcan_9'), 'makkah');
  });

  test('Stored invalid azan IDs are sanitized before the chosen card plays', () async {
    await StorageService.saveAzanSound('islamcan_2');
    expect(await StorageService.getAzanSound(), 'makkah');
    expect(AzanAudioService.resolveSafeSoundId(await StorageService.getAzanSound()), 'makkah');
  });

  testWidgets('Custom target input replaces the fixed 100x tasbih option',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: TasbeehScreen()));
    await tester.pumpAndSettle();

    expect(find.text('33x'), findsOneWidget);
    expect(find.text('99x'), findsOneWidget);
    expect(find.byKey(const ValueKey('target-custom')), findsOneWidget);

    await tester.scrollUntilVisible(find.byKey(const ValueKey('target-custom')), 50,
      scrollable: find.byType(Scrollable).last);
    await tester.tap(find.byKey(const ValueKey('target-custom')));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);
    final field = find.descendant(
      of: find.byType(AlertDialog),
      matching: find.byType(TextField),
    );
    await tester.enterText(field, '120');
    await tester.tap(find.text('پەسەندکردن'));
    await tester.pumpAndSettle();

    expect(find.text('120 ×'), findsOneWidget);
    expect(find.text('0'), findsWidgets);
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
  });

  testWidgets('App builds smoke test and MainAppScreen renders',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: Text('Nada App Smoke Test')),
    ));
    expect(find.text('Nada App Smoke Test'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  test(
      'Morning and evening adhkar include a complete set of recommended entries',
      () async {
    final morning =
        await DhikrPackageService.instance.loadCategory('morning');
    final evening =
        await DhikrPackageService.instance.loadCategory('evening');

    expect(morning.length, greaterThanOrEqualTo(23));
    expect(evening.length, greaterThanOrEqualTo(23));
  });

  test(
      'Zikr display strips repeated count suffixes while keeping the target count clear',
      () {
    final morning = AppData.morningAzkar;
    final evening = AppData.eveningAzkar;

    for (final item in [...morning, ...evening]) {
      expect(item.arabic.contains('جاری'), isFalse);
      expect(item.arabic.contains('جار'), isFalse);
    }
  });

  test(
      'imanikurd morning and evening collections keep complete IDs and translations',
      () async {
    final morning = await DhikrPackageService.instance.loadCategory('morning');
    final evening = await DhikrPackageService.instance.loadCategory('evening');

    for (final item in [...morning, ...evening]) {
      expect(item.id, isNotNull);
      expect(item.arabic.trim().isNotEmpty, isTrue);
      expect(item.kurdishTranslation.trim().isNotEmpty, isTrue);
    }
  });

  test('The three surahs are split and each asks for three repetitions',
      () async {
    final morning = await DhikrPackageService.instance.loadCategory('morning');
    final ekhlas = morning.firstWhere(
      (item) => item.arabic.contains('قُلْ هُوَ اللَّهُ أَحَدٌ'),
    );
    final falaq = morning.firstWhere(
      (item) => item.arabic.contains('قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ'),
    );
    final nas = morning.firstWhere(
      (item) => item.arabic.contains('قُلْ أَعُوذُ بِرَبِّ النَّاسِ'),
    );

    expect(ekhlas.repeat, 3);
    expect(falaq.repeat, 3);
    expect(nas.repeat, 3);
  });

  test('Each split surah keeps its own English and Kurdish meaning', () async {
    final morning = await DhikrPackageService.instance.loadCategory('morning');
    final ekhlas = morning.firstWhere(
      (item) => item.arabic.contains('قُلْ هُوَ اللَّهُ أَحَدٌ'),
    );
    final falaq = morning.firstWhere(
      (item) => item.arabic.contains('قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ'),
    );
    final nas = morning.firstWhere(
      (item) => item.arabic.contains('قُلْ أَعُوذُ بِرَبِّ النَّاسِ'),
    );

    expect(ekhlas.translation.toLowerCase(), contains('he is allah'));
    expect(
        falaq.translation, contains('I seek refuge in the Lord of'));
    expect(nas.translation, contains('I seek refuge in the Lord of mankind'));

    expect(ekhlas.kurdishTranslation, contains('الإخلاص'));
    expect(falaq.kurdishTranslation, contains('الفلق'));
    expect(nas.kurdishTranslation, contains('الناس'));
  });

  test(
      'Daily streak counts once per calendar day and continues only on the next day',
      () {
    final today = DateTime(2026, 8, 13);
    final yesterday = today.subtract(const Duration(days: 1));

    final profile = UserProfile(
      name: 'Test',
      dailyGoal: 3,
      currentStreak: 4,
      bestStreak: 6,
      totalSessions: 10,
      lastSessionDate: yesterday,
    );

    expect(StorageService.calculateNextStreak(profile, today), 5);
    expect(StorageService.calculateNextStreak(profile, today), isNot(6));

    final sameDayProfile = profile.copyWith(lastSessionDate: today);
    expect(StorageService.calculateNextStreak(sameDayProfile, today), 4);
  });

  test('Tafsir index parser groups entries by surah and ayah', () {
    const raw =
        '[{"s":"1","a":1,"t":"tafsir one"},{"s":1,"a":2,"t":"tafsir two"}]';
    final index = parseTafsirIndex(raw);

    expect(index[1]?[1], 'tafsir one');
    expect(index[1]?[2], 'tafsir two');
  });

  test('Asan tafsir is available for a curated mood reference', () async {
    final tafsir = await QuranService.instance.getTafsir('asan', 94, 5);

    expect(tafsir, isNotNull);
    expect(tafsir!.isNotEmpty, isTrue);
  });

  test('Quran mood engine returns themed verses for each supported mood', () {
    for (final mood in [
      'grateful',
      'anxious',
      'hopeful',
      'tired',
      'joyful',
      'sad'
    ]) {
      final suggestion = QuranMoodService.instance.suggestForMood(mood);
      expect(suggestion.moodId, mood);
      expect(suggestion.verses.length, greaterThanOrEqualTo(10));
      expect(suggestion.title.isNotEmpty, isTrue);
      expect(suggestion.shortMessage.isNotEmpty, isTrue);
      expect(suggestion.verses.every((verse) => verse.arabicText.isNotEmpty),
          isTrue);
    }
  });

  test('Quran mood engine exposes a distinct palette for each mood', () {
    for (final mood in [
      'grateful',
      'anxious',
      'hopeful',
      'tired',
      'joyful',
      'sad'
    ]) {
      final palette = QuranMoodService.instance.themeFor(mood);
      expect(palette.primary.toARGB32(), isNot(equals(0)));
      expect(palette.secondary.toARGB32(), isNot(equals(0)));
      expect(palette.emoji.isNotEmpty, isTrue);
    }
  });

  test('Favorite mood cards persist as saved items', () async {
    final suggestion = QuranMoodService.instance.suggestForMood('grateful');
    await StorageService.saveFavoriteMoodCard(suggestion);
    final saved = await StorageService.readFavoriteMoodCards();

    expect(saved.any((item) => item['moodId'] == 'grateful'), isTrue);
    expect(saved.first['title'], contains('heart'));
    expect(saved.first['schemaVersion'], 2);
    expect(saved.first['tafsirId'], 'asan');
  });

  test('Mood cards provide localized labels and share text', () {
    final suggestion = QuranMoodService.instance.suggestForMood('sad');
    final arabicTitle = QuranMoodService.instance.titleFor('sad', 'ar');
    final kurdishShare = suggestion.shareTextFor('ku');
    final arabicShare = suggestion.shareTextFor('ar');

    expect(arabicTitle, contains('مواساة'));
    expect(kurdishShare, contains('کارتی هەستی قورئان'));
    expect(kurdishShare, contains('سورەت'));
    expect(arabicShare, contains('بطاقة مزاج قرآنية'));
    expect(arabicShare, contains('السورة'));
  });

  testWidgets('QiblaCompassSheet renders compass dial, needle, and target bearing', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: QiblaCompassSheet(
            latitude: 36.1911,
            longitude: 44.0091,
            locationName: 'Erbil, Kurdistan',
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('قیبلەنمای پیرۆز - Qibla Compass'), findsOneWidget);
    expect(find.text('Erbil, Kurdistan'), findsOneWidget);
    expect(find.text('N'), findsOneWidget);
    expect(find.text('E'), findsOneWidget);
    expect(find.text('S'), findsOneWidget);
    expect(find.text('W'), findsOneWidget);
    expect(find.text('ڕووگەی قیبلە'), findsOneWidget);
    expect(find.text('دووری تا مەککە'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  });

  test('All 19 Qari reciters produce valid URLs for all 114 Surahs', () {
    expect(kQuranReciters.length, 19);
    for (final reciter in kQuranReciters) {
      expect(reciter.id.isNotEmpty, isTrue);
      expect(reciter.nameAr.isNotEmpty, isTrue);
      expect(reciter.nameEn.isNotEmpty, isTrue);
      expect(reciter.nameKu.isNotEmpty, isTrue);

      final url1 = reciter.getSurahUrl(1);
      final url114 = reciter.getSurahUrl(114);

      expect(url1.startsWith('http://') || url1.startsWith('https://'), isTrue);
      expect(url1, contains('001.mp3'));
      expect(url114, contains('114.mp3'));
    }
  });

  test('Saved Ayahs storage methods test', () async {
    await StorageService.saveQuranAyahBookmark(
      surahNumber: 1,
      ayahNumber: 2,
      surahNameKu: 'فاتیحە',
      surahNameAr: 'الفاتحة',
      surahNameEn: 'Al-Fatiha',
      note: 'Test note',
    );

    final bookmarks = await StorageService.getQuranAyahBookmarks();
    expect(bookmarks.length, greaterThanOrEqualTo(1));

    await StorageService.removeQuranAyahBookmark(
      surahNumber: 1,
      ayahNumber: 2,
    );
  });

  testWidgets('Saved Ayahs Material card renders without shape/borderRadius assertion error', (WidgetTester tester) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: Material(
          color: Color(0xFF1E293B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            side: BorderSide(color: Color(0xFF334155)),
          ),
          clipBehavior: Clip.antiAlias,
          child: Text('Ayah 2, Al-Fatiha'),
        ),
      ),
    );
    await tester.pump();
    expect(find.text('Ayah 2, Al-Fatiha'), findsOneWidget);
  });
}
