import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nada_zikrakanm/models/app_data.dart';
import 'package:nada_zikrakanm/screens/reading_screen.dart';
import 'package:nada_zikrakanm/widgets/quran_audio_player_widget.dart';

void main() {
  testWidgets('ReadingScreen renders on narrow 320px screen with text scaling without overflow',
      (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final morningCategory = AppData.azkarCategories.firstWhere((c) => c.id == 'morning');

    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(
            size: Size(320, 640),
            textScaler: TextScaler.linear(1.3),
          ),
          child: ReadingScreen(category: morningCategory),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(ReadingScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('ReadingScreen renders all categories on 320px width without overflow',
      (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    for (final catId in ['evening', 'sleep', 'wakeup', 'prayer']) {
      final category = AppData.azkarCategories.firstWhere((c) => c.id == catId);
      await tester.pumpWidget(
        MaterialApp(
          home: ReadingScreen(category: category),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('QuranAudioPlayerWidget renders on 320px width without overflow',
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
        home: Scaffold(
          body: QuranAudioPlayerWidget(
            surahNumber: 1,
            surahName: 'الفاتحة',
            totalAyahs: 7,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(QuranAudioPlayerWidget), findsOneWidget);
    FlutterError.onError = originalOnError;
    if (errorDetails != null) {
      // ignore: avoid_print
      print('FULL FLUTTER ERROR:\n${errorDetails!.toString()}');
    }
    expect(errorDetails, isNull);
  });
}
