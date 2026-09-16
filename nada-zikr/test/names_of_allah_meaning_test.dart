import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nada_zikrakanm/screens/names_of_allah_screen.dart';
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
  testWidgets('NamesOfAllahScreen list view defaults to Kurdish and toggles to English on tap',
      (tester) async {
    tester.view.physicalSize = const Size(450, 1000);
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
        home: const NamesOfAllahScreen(),
      ),
    );
    await tester.pump();
    while (find.byType(CircularProgressIndicator).evaluate().isNotEmpty) {
      await tester.pump(const Duration(milliseconds: 50));
    }

    // Switch to list view
    final listIcon = find.byIcon(Icons.view_list_rounded);
    expect(listIcon, findsOneWidget);
    await tester.tap(listIcon);
    await tester.pump(const Duration(milliseconds: 250));

    // In Kurdish locale, it should display Kurdish badge and Kurdish translation
    final kurdishBadge = find.text('مانای کوردی').first;
    await tester.ensureVisible(kurdishBadge);
    expect(kurdishBadge, findsOneWidget);
    expect(find.text('English').first, findsOneWidget);

    // Tap badge to switch to English
    await tester.tap(kurdishBadge);
    await tester.pump(const Duration(milliseconds: 250));

    // Now English meaning badge should be displayed
    final englishBadge = find.text('مانای ئینگلیزی').first;
    await tester.ensureVisible(englishBadge);
    expect(englishBadge, findsOneWidget);
    expect(find.text('کوردی').first, findsOneWidget);

    // Tap again to switch back to Kurdish
    await tester.tap(englishBadge);
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.text('مانای کوردی').first, findsOneWidget);
    expect(find.text('English').first, findsOneWidget);
  });

  testWidgets('NamesOfAllahScreen defaults to English when locale is English',
      (tester) async {
    tester.view.physicalSize = const Size(450, 1000);
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
        home: const NamesOfAllahScreen(),
      ),
    );
    await tester.pump();
    while (find.byType(CircularProgressIndicator).evaluate().isNotEmpty) {
      await tester.pump(const Duration(milliseconds: 50));
    }

    // Switch to list view
    final listIcon = find.byIcon(Icons.view_list_rounded);
    expect(listIcon, findsOneWidget);
    await tester.tap(listIcon);
    await tester.pump(const Duration(milliseconds: 250));

    // In English locale, it defaults to English Meaning
    final englishBadge = find.text('English Meaning').first;
    await tester.ensureVisible(englishBadge);
    expect(englishBadge, findsOneWidget);
    expect(find.text('Kurdish').first, findsOneWidget);

    // Tap badge to switch to Kurdish
    await tester.tap(englishBadge);
    await tester.pump(const Duration(milliseconds: 250));

    final kurdishBadge = find.text('Kurdish Meaning').first;
    await tester.ensureVisible(kurdishBadge);
    expect(kurdishBadge, findsOneWidget);
    expect(find.text('English').first, findsOneWidget);
  });
}
