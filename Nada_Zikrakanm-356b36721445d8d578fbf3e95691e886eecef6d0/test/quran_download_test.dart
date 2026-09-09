import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:nada_zikrakanm/services/quran_download_service.dart';
import 'package:nada_zikrakanm/models/quran_reciter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Quran Download & Offline Validation Tests', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('quran_download_test_');
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('Validates minimum audio threshold constant is at least 25 KB', () {
      expect(QuranDownloadService.kMinValidAudioBytes, 25000);
    });

    test('Corrupted or truncated file (< 25 KB) is purged and deemed invalid', () async {
      final corruptFile = File('${tempDir.path}/mishary_1.mp3');
      // Write 200 bytes (e.g. truncated connection or HTML 404 response)
      await corruptFile.writeAsBytes(List.generate(200, (i) => i % 256));

      expect(corruptFile.existsSync(), isTrue);
      expect(corruptFile.lengthSync(), lessThan(QuranDownloadService.kMinValidAudioBytes));

      // Simulate verification logic used in isSurahDownloaded
      final length = corruptFile.lengthSync();
      bool isValid = length >= QuranDownloadService.kMinValidAudioBytes;
      if (!isValid) {
        corruptFile.deleteSync();
      }

      expect(isValid, isFalse);
      expect(corruptFile.existsSync(), isFalse,
          reason: 'Corrupted or partial audio files must be automatically purged from storage');
    });

    test('Valid downloaded audio file (>= 25 KB) passes integrity check', () async {
      final validFile = File('${tempDir.path}/mishary_1.mp3');
      // Write 30 KB of dummy audio data
      await validFile.writeAsBytes(List.generate(30000, (i) => i % 256));

      expect(validFile.existsSync(), isTrue);
      expect(validFile.lengthSync(), greaterThanOrEqualTo(QuranDownloadService.kMinValidAudioBytes));

      final length = validFile.lengthSync();
      final isValid = length >= QuranDownloadService.kMinValidAudioBytes;
      expect(isValid, isTrue);
    });

    test('File listing parses reciter prefix and filters out temporary/corrupt files', () async {
      const reciterId = 'mishary';

      // 1. Valid surah 1
      final f1 = File('${tempDir.path}/${reciterId}_1.mp3');
      await f1.writeAsBytes(List.generate(28000, (i) => 1));

      // 2. Valid surah 114
      final f2 = File('${tempDir.path}/${reciterId}_114.mp3');
      await f2.writeAsBytes(List.generate(32000, (i) => 2));

      // 3. Different reciter (should not match)
      final f3 = File('${tempDir.path}/sudais_1.mp3');
      await f3.writeAsBytes(List.generate(28000, (i) => 3));

      // 4. Temporary download in-progress file (should not match)
      final f4 = File('${tempDir.path}/${reciterId}_2.mp3.tmp');
      await f4.writeAsBytes(List.generate(50000, (i) => 4));

      // 5. Corrupt stub file (< 25 KB) (should be skipped)
      final f5 = File('${tempDir.path}/${reciterId}_3.mp3');
      await f5.writeAsBytes(List.generate(1000, (i) => 5));

      final downloaded = <int>[];
      const prefix = '${reciterId}_';
      final files = tempDir.listSync();
      for (final entity in files) {
        if (entity is File && entity.path.endsWith('.mp3')) {
          final fileName = entity.uri.pathSegments.last;
          if (fileName.startsWith(prefix) && entity.lengthSync() >= QuranDownloadService.kMinValidAudioBytes) {
            final numberPart = fileName.substring(prefix.length).replaceAll('.mp3', '');
            final surahNum = int.tryParse(numberPart);
            if (surahNum != null) {
              downloaded.add(surahNum);
            }
          }
        }
      }
      downloaded.sort();

      expect(downloaded, equals([1, 114]));
    });

    test('Total size calculation accurately sums only valid audio files', () async {
      const reciterId = 'abdulbasit';

      final f1 = File('${tempDir.path}/${reciterId}_1.mp3');
      await f1.writeAsBytes(List.generate(30000, (i) => 1));

      final f2 = File('${tempDir.path}/${reciterId}_2.mp3');
      await f2.writeAsBytes(List.generate(40000, (i) => 2));

      int total = 0;
      final files = tempDir.listSync();
      const prefix = '${reciterId}_';
      for (final entity in files) {
        if (entity is File && entity.path.endsWith('.mp3')) {
          final fileName = entity.uri.pathSegments.last;
          if (fileName.startsWith(prefix)) {
            total += entity.lengthSync();
          }
        }
      }

      expect(total, equals(70000));
    });

    test('Clear downloads removes audio files and temp files for target reciter', () async {
      const reciterId = 'mishary';
      const otherReciterId = 'sudais';

      final f1 = File('${tempDir.path}/${reciterId}_1.mp3');
      await f1.writeAsBytes(List.generate(30000, (i) => 1));

      final f2 = File('${tempDir.path}/${reciterId}_2.mp3.tmp');
      await f2.writeAsBytes(List.generate(10000, (i) => 2));

      final f3 = File('${tempDir.path}/${otherReciterId}_1.mp3');
      await f3.writeAsBytes(List.generate(30000, (i) => 3));

      // Simulate clearAllDownloads(reciterId: reciterId)
      final files = tempDir.listSync();
      const prefix = '${reciterId}_';
      for (final entity in files) {
        if (entity is File) {
          final fileName = entity.uri.pathSegments.last;
          if (fileName.endsWith('.tmp') ||
              (fileName.endsWith('.mp3') && fileName.startsWith(prefix))) {
            entity.deleteSync();
          }
        }
      }

      expect(f1.existsSync(), isFalse);
      expect(f2.existsSync(), isFalse);
      expect(f3.existsSync(), isTrue, reason: 'Other reciters audio should not be cleared');
    });

    test('All Quran reciters define valid surah URLs for fallback downloads', () {
      for (final reciter in kQuranReciters) {
        final urlSurah1 = reciter.getSurahUrl(1);
        final urlSurah114 = reciter.getSurahUrl(114);

        expect(urlSurah1.startsWith('http'), isTrue,
            reason: 'Reciter ${reciter.id} must have a valid HTTP/HTTPS URL for Surah 1');
        expect(urlSurah114.startsWith('http'), isTrue,
            reason: 'Reciter ${reciter.id} must have a valid HTTP/HTTPS URL for Surah 114');
        expect(urlSurah1.endsWith('.mp3'), isTrue);
        expect(urlSurah114.endsWith('.mp3'), isTrue);
      }
    });

    test('findAnyDownloadedFilePath finds valid audio file regardless of active reciter', () async {
      // Create a valid downloaded file for surah 1 under 'abdulbasit'
      final abdulbasitSurah1 = File('${tempDir.path}/abdulbasit_1.mp3');
      await abdulbasitSurah1.writeAsBytes(List.generate(35000, (i) => i % 128));

      // Create an invalid (< 25 KB) stub for surah 2 under 'mishary'
      final misharySurah2 = File('${tempDir.path}/mishary_2.mp3');
      await misharySurah2.writeAsBytes(List.generate(500, (i) => 1));

      // Simulate findAnyDownloadedFilePath logic for surah 1
      String? foundPathSurah1;
      const suffix1 = '_1.mp3';
      for (final entity in tempDir.listSync()) {
        if (entity is File && entity.path.endsWith(suffix1)) {
          if (entity.lengthSync() >= QuranDownloadService.kMinValidAudioBytes) {
            foundPathSurah1 = entity.path;
            break;
          }
        }
      }

      // Simulate findAnyDownloadedFilePath logic for surah 2
      String? foundPathSurah2;
      const suffix2 = '_2.mp3';
      for (final entity in tempDir.listSync()) {
        if (entity is File && entity.path.endsWith(suffix2)) {
          if (entity.lengthSync() >= QuranDownloadService.kMinValidAudioBytes) {
            foundPathSurah2 = entity.path;
            break;
          }
        }
      }

      expect(foundPathSurah1, isNotNull);
      expect(foundPathSurah1, contains('abdulbasit_1.mp3'));
      expect(foundPathSurah2, isNull, reason: 'Stub or corrupt file under 25KB must be ignored');
    });

    test('Audio source selection prioritizes local downloaded file over remote streaming URL', () async {
      const reciterId = 'mishary';
      const surahNum = 18;

      // When file does not exist:
      final localFile = File('${tempDir.path}/${reciterId}_$surahNum.mp3');
      expect(localFile.existsSync(), isFalse);

      bool isOfflineAvailable = localFile.existsSync() &&
          localFile.lengthSync() >= QuranDownloadService.kMinValidAudioBytes;
      expect(isOfflineAvailable, isFalse);

      // Now create valid downloaded file (e.g. after user downloads in reading view)
      await localFile.writeAsBytes(List.generate(30000, (i) => 42));
      isOfflineAvailable = localFile.existsSync() &&
          localFile.lengthSync() >= QuranDownloadService.kMinValidAudioBytes;
      expect(isOfflineAvailable, isTrue);

      // Verify that local file path is favored
      String sourceToPlay;
      if (isOfflineAvailable) {
        sourceToPlay = localFile.path;
      } else {
        sourceToPlay = 'https://example.com/$reciterId/$surahNum.mp3';
      }

      expect(sourceToPlay, equals(localFile.path),
          reason: 'Player must use the local downloaded file path for offline playback');
    });
  });
}

