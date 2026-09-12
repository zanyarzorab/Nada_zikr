import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nada_zikrakanm/services/quran_service.dart';
import 'package:nada_zikrakanm/widgets/sign_language_text_widget.dart';

void main() {
  group('Sign Language Fingerspelling Quran Tests', () {
    test('Cleans Arabic text for sign language mapping properly', () {
      const ayah = 'ٱلَّذِينَ يُؤْمِنُونَ بِٱلْغَيْبِ';
      final clean = SignLanguageTextWidget.cleanArabicText(ayah);
      expect(clean.contains('ّ'), isFalse);
      expect(clean.contains('َ'), isFalse);
      expect(clean.contains('ِ'), isFalse);
      expect(clean.contains('ُ'), isFalse);
      expect(clean.contains('ْ'), isFalse);
      expect(clean.isNotEmpty, isTrue);
    });

    test('Quran Tafsir options include sign language option', () {
      final signOption = kQuranTafsirOptions.any((opt) => opt.id == 'sign');
      expect(signOption, isTrue);
    });

    test('QuranService returns sign language mode identifier', () async {
      final result = await QuranService.instance.getTafsir('sign', 1, 1);
      expect(result, '__SIGN_LANGUAGE_MODE__');
    });

    testWidgets('Renders long words on narrow screen without overflow',
        (tester) async {
      tester.view.physicalSize = const Size(320, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      const longAyah = 'فَأَسْقَيْنَٰكُمُوهُ وَمَآ أَنتُمْ لَهُۥ بِخَٰزِنِينَ';
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.rtl,
          child: SignLanguageTextWidget(text: longAyah),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(SignLanguageTextWidget), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
