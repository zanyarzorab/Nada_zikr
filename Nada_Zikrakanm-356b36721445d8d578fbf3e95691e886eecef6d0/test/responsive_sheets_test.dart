import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:nada_zikrakanm/models/azkar_model.dart';
import 'package:nada_zikrakanm/screens/hadith_screen.dart';
import 'package:nada_zikrakanm/screens/tasbeeh_screen.dart';
import 'package:nada_zikrakanm/services/hadith_service.dart';
import 'package:nada_zikrakanm/services/storage_service.dart';
import 'package:nada_zikrakanm/widgets/dua_card_generator.dart';
import 'package:nada_zikrakanm/widgets/reciter_selector_sheet.dart';

void main() {
  setUpAll(() async {
    final dir = await Directory.systemTemp.createTemp('sheets_test_hive_');
    Hive.init(dir.path);
    await StorageService.initialize();
    await HadithService.loadAllHadiths();
  });
  testWidgets('ReciterSelectorSheet renders on 320px screen with 1.5x font scale without overflow',
      (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    FlutterErrorDetails? errorDetails;
    final originalOnError = FlutterError.onError;
    FlutterError.onError = (details) {
      errorDetails = details;
    };

    await tester.pumpWidget(
      const MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(
            size: Size(320, 640),
            textScaler: TextScaler.linear(1.5),
          ),
          child: Scaffold(
            body: ReciterSelectorSheet(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    FlutterError.onError = originalOnError;
    expect(errorDetails, isNull);
    expect(find.byType(ReciterSelectorSheet), findsOneWidget);
  });

  testWidgets('DuaCardGeneratorDialog renders on 320px screen with 1.5x font scale without overflow',
      (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    FlutterErrorDetails? errorDetails;
    final originalOnError = FlutterError.onError;
    FlutterError.onError = (details) {
      errorDetails = details;
    };

    final testAzkar = Azkar(
      id: 1,
      arabic: 'اللهم بك أصبحنا وبك أمسينا وبك نحيا وبك نموت وإليك النشور',
      translation: 'O Allah, by You we enter the morning and by You we enter the evening.',
      kurdishTranslation: 'خودایە بە تۆوە بەیانیمان کردەوە و بە تۆوە ئێوارە دەکەینەوە.',
      repeat: 1,
      source: 'صحيح الترمذي',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(
            size: Size(320, 640),
            textScaler: TextScaler.linear(1.5),
          ),
          child: Scaffold(
            body: DuaCardGeneratorDialog(azkar: testAzkar),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    FlutterError.onError = originalOnError;
    expect(errorDetails, isNull);
    expect(find.byType(DuaCardGeneratorDialog), findsOneWidget);
  });

  testWidgets('TasbeehScreen renders on 320px screen with 1.5x font scale without overflow',
      (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    FlutterErrorDetails? errorDetails;
    final originalOnError = FlutterError.onError;
    FlutterError.onError = (details) {
      errorDetails = details;
    };

    await tester.pumpWidget(
      const MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(
            size: Size(320, 640),
            textScaler: TextScaler.linear(1.5),
          ),
          child: TasbeehScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    FlutterError.onError = originalOnError;
    expect(errorDetails, isNull);
    expect(find.byType(TasbeehScreen), findsOneWidget);
  });

  testWidgets('HadithScreen renders on 320px screen with 1.5x font scale without overflow',
      (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final errors = <FlutterErrorDetails>[];
    final originalOnError = FlutterError.onError;
    FlutterError.onError = (details) {
      errors.add(details);
    };

    try {
      await tester.pumpWidget(
        const MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(
              size: Size(320, 640),
              textScaler: TextScaler.linear(1.5),
            ),
            child: HadithScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();
    } finally {
      FlutterError.onError = originalOnError;
    }

    if (errors.isNotEmpty) {
      // ignore: avoid_print
      print('HADITH_SCREEN_ERROR: ${errors.first.exception}');
    }
    expect(errors, isEmpty);
    expect(find.byType(HadithScreen), findsOneWidget);
  });
}


