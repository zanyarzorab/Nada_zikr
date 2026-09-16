import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nada_zikrakanm/app_localizations.dart';
import 'package:nada_zikrakanm/models/general_dua_model.dart';
import 'package:nada_zikrakanm/models/hadith_model.dart';
import 'package:nada_zikrakanm/models/quran_dua_model.dart';
import 'package:nada_zikrakanm/screens/general_duas_screen.dart';
import 'package:nada_zikrakanm/screens/hadith_screen.dart';
import 'package:nada_zikrakanm/screens/quran_duas_screen.dart';
import 'package:nada_zikrakanm/services/general_dua_service.dart';
import 'package:nada_zikrakanm/services/hadith_service.dart';
import 'package:nada_zikrakanm/services/quran_dua_service.dart';

class _TestAppLocDelegate extends LocalizationsDelegate<AppLocalizations> {
  final String lang;
  const _TestAppLocDelegate(this.lang);

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(Locale(lang));
  }

  @override
  bool shouldReload(_TestAppLocDelegate old) => old.lang != lang;
}

class _TestMaterialLocDelegate extends LocalizationsDelegate<MaterialLocalizations> {
  const _TestMaterialLocDelegate();
  @override
  bool isSupported(Locale locale) => true;
  @override
  Future<MaterialLocalizations> load(Locale locale) {
    final frameworkLocale = locale.languageCode == 'ku' ? const Locale('ar') : locale;
    return GlobalMaterialLocalizations.delegate.load(frameworkLocale);
  }
  @override
  bool shouldReload(_TestMaterialLocDelegate old) => false;
}

class _TestCupertinoLocDelegate extends LocalizationsDelegate<CupertinoLocalizations> {
  const _TestCupertinoLocDelegate();
  @override
  bool isSupported(Locale locale) => true;
  @override
  Future<CupertinoLocalizations> load(Locale locale) {
    final frameworkLocale = locale.languageCode == 'ku' ? const Locale('en') : locale;
    return GlobalCupertinoLocalizations.delegate.load(frameworkLocale);
  }
  @override
  bool shouldReload(_TestCupertinoLocDelegate old) => false;
}

class _TestWidgetsLocDelegate extends LocalizationsDelegate<WidgetsLocalizations> {
  const _TestWidgetsLocDelegate();
  @override
  bool isSupported(Locale locale) => true;
  @override
  Future<WidgetsLocalizations> load(Locale locale) {
    final frameworkLocale = locale.languageCode == 'ku' ? const Locale('ar') : locale;
    return GlobalWidgetsLocalizations.delegate.load(frameworkLocale);
  }
  @override
  bool shouldReload(_TestWidgetsLocDelegate old) => false;
}

const _mockGeneralDua = GeneralDuaItem(
  id: 1,
  category: 'guidance',
  title: 'دوعای هیدایەت',
  arabic: 'اللَّهُمَّ إِنِّي أَسْأَلُكَ الْهُدَى وَالتُّقَى',
  easyTajweed: '',
  kurdishMeaning: 'خودایە داوای هیدایەت و پارێزگاریت لێ دەکەم',
  englishMeaning: 'O Allah, I ask You for guidance and piety',
  hadithSource: 'صحيح مسلم',
);

const _mockQuranDua = QuranDuaItem(
  id: 1,
  surah: 'Al-Baqarah',
  ayah: '201',
  arabic: 'رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً',
  easyTajweed: '',
  kurdishMeaning: 'پەروەردگارمان! چاکەمان پێ ببەخشە لە دنیادا',
  englishMeaning: 'Our Lord, give us in this world that which is good',
);

const _mockHadith = HadithItem(
  id: 1,
  chapter: 'ئیمان',
  chapterEn: 'Faith',
  narratorAr: 'عَنْ عُمَرَ بْنِ الْخَطَّابِ',
  textAr: 'إِنَّمَا الأَعْمَالُ بِالنِّيَّاتِ',
  textKu: 'کردەوەکان بەپێی نیەتەکانن',
  textEn: 'Actions are according to intentions',
  source: 'صحيح البخاري',
  grade: 'صحيح',
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    GeneralDuaService.setMockDuas([_mockGeneralDua]);
    QuranDuaService.setMockDuas([_mockQuranDua]);
    HadithService.setMockHadiths([_mockHadith]);
  });

  testWidgets('GeneralDuasScreen defaults to Kurdish and toggles to English on badge tap',
      (tester) async {
    tester.view.physicalSize = const Size(500, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ku'),
        supportedLocales: const [Locale('ku'), Locale('en')],
        localizationsDelegates: const [
          _TestAppLocDelegate('ku'),
          _TestMaterialLocDelegate(),
          _TestCupertinoLocDelegate(),
          _TestWidgetsLocDelegate(),
        ],
        home: const GeneralDuasScreen(),
      ),
    );
    await tester.pump();
    while (find.byType(CircularProgressIndicator).evaluate().isNotEmpty) {
      await tester.pump(const Duration(milliseconds: 50));
    }

    // Kurdish badge should be visible
    final kurdishBadge = find.text('📖 مانای دوعا (کوردی)').first;
    await tester.ensureVisible(kurdishBadge);
    expect(kurdishBadge, findsOneWidget);
    expect(find.text('English').first, findsOneWidget);
    expect(find.text('خودایە داوای هیدایەت و پارێزگاریت لێ دەکەم').first, findsOneWidget);

    // Old expandable toggle should NOT exist
    expect(find.textContaining('پیشاندانی مانای ئینگلیزی'), findsNothing);

    // Tap badge to switch to English
    await tester.tap(kurdishBadge);
    await tester.pump(const Duration(milliseconds: 200));

    // Now English badge and text should be visible
    expect(find.text('مانای ئینگلیزی').first, findsOneWidget);
    expect(find.text('کوردی').first, findsOneWidget);
    expect(find.text('O Allah, I ask You for guidance and piety').first, findsOneWidget);
  });

  testWidgets('GeneralDuasScreen in English locale defaults to English meaning',
      (tester) async {
    tester.view.physicalSize = const Size(500, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        supportedLocales: const [Locale('ku'), Locale('en')],
        localizationsDelegates: const [
          _TestAppLocDelegate('en'),
          _TestMaterialLocDelegate(),
          _TestCupertinoLocDelegate(),
          _TestWidgetsLocDelegate(),
        ],
        home: const GeneralDuasScreen(),
      ),
    );
    await tester.pump();
    while (find.byType(CircularProgressIndicator).evaluate().isNotEmpty) {
      await tester.pump(const Duration(milliseconds: 50));
    }

    // English badge should be visible by default in English locale
    expect(find.text('English Translation').first, findsOneWidget);
    expect(find.text('Kurdish').first, findsOneWidget);
    expect(find.text('O Allah, I ask You for guidance and piety').first, findsOneWidget);
  });

  testWidgets('QuranDuasScreen defaults to Kurdish and toggles to English on badge tap',
      (tester) async {
    tester.view.physicalSize = const Size(500, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ku'),
        supportedLocales: const [Locale('ku'), Locale('en')],
        localizationsDelegates: const [
          _TestAppLocDelegate('ku'),
          _TestMaterialLocDelegate(),
          _TestCupertinoLocDelegate(),
          _TestWidgetsLocDelegate(),
        ],
        home: const QuranDuasScreen(),
      ),
    );
    await tester.pump();
    while (find.byType(CircularProgressIndicator).evaluate().isNotEmpty) {
      await tester.pump(const Duration(milliseconds: 50));
    }

    // Kurdish Tafsir badge should be visible
    final kurdishBadge = find.text('📖 تەفسیری ئاسان (کوردی)').first;
    await tester.ensureVisible(kurdishBadge);
    expect(kurdishBadge, findsOneWidget);
    expect(find.text('English').first, findsOneWidget);
    expect(find.text('پەروەردگارمان! چاکەمان پێ ببەخشە لە دنیادا').first, findsOneWidget);

    // Old expandable toggle should NOT exist
    expect(find.textContaining('پیشاندانی مانای ئینگلیزی'), findsNothing);

    // Tap badge to switch to English
    await tester.tap(kurdishBadge);
    await tester.pump(const Duration(milliseconds: 200));

    // Now English badge should be visible
    expect(find.text('مانای ئینگلیزی').first, findsOneWidget);
    expect(find.text('کوردی').first, findsOneWidget);
    expect(find.text('Our Lord, give us in this world that which is good').first, findsOneWidget);
  });

  testWidgets('HadithScreen defaults to Kurdish and toggles to English on badge tap',
      (tester) async {
    tester.view.physicalSize = const Size(500, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ku'),
        supportedLocales: const [Locale('ku'), Locale('en')],
        localizationsDelegates: const [
          _TestAppLocDelegate('ku'),
          _TestMaterialLocDelegate(),
          _TestCupertinoLocDelegate(),
          _TestWidgetsLocDelegate(),
        ],
        home: const HadithScreen(),
      ),
    );
    await tester.pump();
    while (find.byType(CircularProgressIndicator).evaluate().isNotEmpty) {
      await tester.pump(const Duration(milliseconds: 50));
    }

    // Kurdish Hadith badge should be visible
    final kurdishBadge = find.text('📜 مانای فەرموودە (کوردی)').first;
    await tester.ensureVisible(kurdishBadge);
    expect(kurdishBadge, findsOneWidget);
    expect(find.text('English').first, findsOneWidget);
    expect(find.text('کردەوەکان بەپێی نیەتەکانن').first, findsOneWidget);

    // Old expandable toggle should NOT exist
    expect(find.textContaining('مانای ئینگلیزی (English)'), findsNothing);

    // Tap badge to switch to English
    await tester.tap(kurdishBadge);
    await tester.pump(const Duration(milliseconds: 200));

    // Now English badge should be visible
    expect(find.text('مانای ئینگلیزی').first, findsOneWidget);
    expect(find.text('کوردی').first, findsOneWidget);
    expect(find.text('Actions are according to intentions').first, findsOneWidget);
  });
}
