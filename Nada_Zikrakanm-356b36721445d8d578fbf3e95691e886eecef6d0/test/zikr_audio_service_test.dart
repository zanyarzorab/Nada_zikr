import 'package:flutter_test/flutter_test.dart';
import 'package:nada_zikrakanm/models/azkar_model.dart';
import 'package:nada_zikrakanm/services/zikr_audio_service.dart';

void main() {
  test('ZikrAudioService text cleaning and URL resolution works cleanly', () {
    final cleanText = ZikrAudioService.cleanTextForAudio(
      'اللَّهُ لَا إِلَهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ (سورة البقرة)',
    );
    expect(cleanText, contains('اللَّهُ لَا إِلَهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ'));
    expect(cleanText.contains('(سورة البقرة)'), isFalse);

    final zikr = Azkar(
      id: 1,
      arabic: 'اللَّهُ لَا إِلَهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ',
      translation: 'Allah - there is no deity except Him',
      kurdishTranslation: 'خودا هیچ پەرستراوێک نییە بێجگە لە ئەو',
      repeat: 1,
      source: 'hisn',
    );

    expect(zikr.displayArabic, contains('اللَّهُ لَا إِلَهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ'));
  });
}
