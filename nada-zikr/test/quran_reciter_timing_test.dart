import 'package:flutter_test/flutter_test.dart';
import 'package:nada_zikrakanm/models/quran_reciter.dart';
import 'package:nada_zikrakanm/services/quran_timing_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Quran Reciter Timing & Highlighting', () {
    test('Identifies exact timing supported reciters correctly', () {
      final timingService = QuranTimingService.instance;

      // 7 supported reciters with QuranCDN timestamps
      expect(timingService.supportsExactTiming('alafasy'), isTrue);
      expect(timingService.supportsExactTiming('abdulbasit'), isTrue);
      expect(timingService.supportsExactTiming('sudais'), isTrue);
      expect(timingService.supportsExactTiming('shatri'), isTrue);
      expect(timingService.supportsExactTiming('husary'), isTrue);
      expect(timingService.supportsExactTiming('minshawi'), isTrue);
      expect(timingService.supportsExactTiming('dosari'), isTrue);

      // Full-surah reciters without exact ayah timestamps
      expect(timingService.supportsExactTiming('raad_kurdi'), isFalse);
      expect(timingService.supportsExactTiming('peshawa_kurdi'), isFalse);
      expect(timingService.supportsExactTiming('maher_meaqli'), isFalse);
      expect(timingService.supportsExactTiming('saad_ghamdi'), isFalse);
      expect(timingService.supportsExactTiming('shuraim'), isFalse);
      expect(timingService.supportsExactTiming('ajmy'), isFalse);
      expect(timingService.supportsExactTiming('nauina'), isFalse);
      expect(timingService.supportsExactTiming('ali_jaber'), isFalse);
      expect(timingService.supportsExactTiming('fares_abbad'), isFalse);
      expect(timingService.supportsExactTiming('nasser_qatami'), isFalse);
      expect(timingService.supportsExactTiming('islam_sobhi'), isFalse);
      expect(timingService.supportsExactTiming('mustafa_ismail'), isFalse);
    });

    test('All 19 reciters in kQuranReciters have unique valid IDs', () {
      expect(kQuranReciters.length, 19);
      final ids = kQuranReciters.map((r) => r.id).toSet();
      expect(ids.length, 19);
    });
  });
}
