import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:nada_zikrakanm/models/app_data.dart';
import 'package:nada_zikrakanm/screens/reading_screen.dart';
import 'package:nada_zikrakanm/services/storage_service.dart';
import 'package:nada_zikrakanm/app_localizations.dart';

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

void main() {
  setUpAll(() async {
    final dir = await Directory.systemTemp.createTemp('reading_test_hive_');
    Hive.init(dir.path);
    await StorageService.initialize();
  });

  final ayatKursiCat = AppData.azkarCategories.firstWhere((c) => c.id == 'ayat_kursi');

  testWidgets('ReadingScreen defaults to Kurdish meaning when locale is Kurdish and toggles to English on tap',
      (tester) async {
    tester.view.physicalSize = const Size(400, 1200);
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
        home: ReadingScreen(category: ayatKursiCat),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Kurdish badge is shown by default
    final kurdishBadge = find.text('مانای کوردی');
    await tester.ensureVisible(kurdishBadge);
    expect(kurdishBadge, findsOneWidget);
    expect(find.text('English'), findsOneWidget);

    // Verify Kurdish translation text is displayed
    expect(find.textContaining('خوا ئه‌و خوایه‌یه‌'), findsOneWidget);
    expect(find.textContaining('Allah - there is no deity except Him'), findsNothing);

    // Verify old expandable button does NOT exist
    expect(find.textContaining('پیشاندانی مانای ئینگلیزی'), findsNothing);

    // Tap the badge to switch to English
    await tester.tap(kurdishBadge);
    await tester.pumpAndSettle();

    // Now English meaning should be visible and Kurdish hidden
    final englishBadge = find.text('مانای ئینگلیزی');
    await tester.ensureVisible(englishBadge);
    expect(englishBadge, findsOneWidget);
    expect(find.text('کوردی'), findsOneWidget);
    expect(find.textContaining('Allah - there is no deity except Him'), findsOneWidget);
    expect(find.textContaining('خوا ئه‌و خوایه‌یه‌'), findsNothing);

    // Tap again to switch back to Kurdish
    await tester.tap(englishBadge);
    await tester.pumpAndSettle();

    expect(find.textContaining('خوا ئه‌و خوایه‌یه‌'), findsOneWidget);
    expect(find.textContaining('Allah - there is no deity except Him'), findsNothing);
  });

  testWidgets('ReadingScreen defaults to English meaning when locale is English',
      (tester) async {
    tester.view.physicalSize = const Size(400, 1200);
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
        home: ReadingScreen(category: ayatKursiCat),
      ),
    );
    await tester.pumpAndSettle();

    // In English locale, it defaults to English translation badge and text
    final englishBadge = find.text('English Translation');
    await tester.ensureVisible(englishBadge);
    expect(englishBadge, findsOneWidget);
    expect(find.text('Kurdish'), findsOneWidget);
    expect(find.textContaining('Allah - there is no deity except Him'), findsOneWidget);
    expect(find.textContaining('خوا ئه‌و خوایه‌یه‌'), findsNothing);

    // Tap the badge to toggle to Kurdish
    await tester.tap(englishBadge);
    await tester.pumpAndSettle();

    final kurdishBadge = find.text('Kurdish Meaning');
    await tester.ensureVisible(kurdishBadge);
    expect(kurdishBadge, findsOneWidget);
    expect(find.text('English'), findsOneWidget);
    expect(find.textContaining('خوا ئه‌و خوایه‌یه‌'), findsOneWidget);
    expect(find.textContaining('Allah - there is no deity except Him'), findsNothing);
  });

  testWidgets('ReadingScreen displays Arabic tap count, how many left, and navigation buttons in Arabic locale',
      (tester) async {
    tester.view.physicalSize = const Size(400, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ar'),
        supportedLocales: const [Locale('ku'), Locale('en'), Locale('ar')],
        localizationsDelegates: const [
          _TestAppLocDelegate('ar'),
          _TestMaterialLocDelegate(),
          _TestCupertinoLocDelegate(),
          _TestWidgetsLocDelegate(),
        ],
        home: ReadingScreen(category: ayatKursiCat),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Arabic Repeat header: 'العدد: 1'
    expect(find.text('العدد: 1'), findsOneWidget);

    // Verify Arabic tap instruction: 'اضغط مرة واحدة'
    expect(find.text('اضغط مرة واحدة'), findsOneWidget);

    // Verify navigation buttons: 'السابق', 'تسبيح', 'التالي'
    expect(find.text('السابق'), findsOneWidget);
    expect(find.text('تسبيح'), findsOneWidget);
    expect(find.text('التالي'), findsOneWidget);

    // Count 1 time to reach repeat count
    await tester.tap(find.text('تسبيح'));
    await tester.pumpAndSettle();

    // Verify Arabic completed label: 'تم الانتهاء'
    expect(find.text('تم الانتهاء'), findsOneWidget);

    // Tap count again to advance to next zikr
    await tester.tap(find.text('تسبيح'));
    await tester.pumpAndSettle();

    // Verify next zikr also displays Arabic repeat header
    expect(find.textContaining('العدد:'), findsOneWidget);
    expect(find.text('السابق'), findsOneWidget);
    expect(find.text('تسبيح'), findsOneWidget);
    expect(find.text('التالي'), findsOneWidget);
  });
}
