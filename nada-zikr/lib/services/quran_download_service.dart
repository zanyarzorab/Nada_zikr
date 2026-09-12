import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../models/quran_reciter.dart';
import 'quran_timing_service.dart';

class QuranDownloadService {
  QuranDownloadService._();
  static final QuranDownloadService instance = QuranDownloadService._();

  /// Minimum byte size for a valid downloaded audio file (25 KB).
  /// Any file smaller is an interrupted download, HTML error response, or corrupt stub.
  static const int kMinValidAudioBytes = 25000;

  /// Notifier bumped whenever a surah is downloaded, deleted, or cleared.
  final ValueNotifier<int> downloadsRevisionNotifier = ValueNotifier<int>(0);

  void _notifyChange() {
    downloadsRevisionNotifier.value++;
  }

  Directory? _audioDir;

  Future<Directory> _getAudioDirectory() async {
    if (_audioDir != null && await _audioDir!.exists()) return _audioDir!;
    final appDocDir = await getApplicationDocumentsDirectory();
    final audioDir = Directory('${appDocDir.path}/quran_audio');
    if (!await audioDir.exists()) {
      await audioDir.create(recursive: true);
    }
    _audioDir = audioDir;
    return audioDir;
  }

  Future<String> getAudioFilePath(int surahNumber, String reciterId) async {
    final dir = await _getAudioDirectory();
    return '${dir.path}/${reciterId}_$surahNumber.mp3';
  }

  /// Verifies whether the surah is fully and validly downloaded on local storage.
  /// If a partial or corrupted stub is found, it automatically cleans it up.
  Future<bool> isSurahDownloaded(int surahNumber, String reciterId) async {
    try {
      final path = await getAudioFilePath(surahNumber, reciterId);
      final file = File(path);
      if (!await file.exists()) return false;

      final length = await file.length();
      if (length >= kMinValidAudioBytes) {
        return true;
      } else {
        // Corrupt or truncated partial file from an earlier failure — purge it
        try {
          await file.delete();
        } catch (_) {}
        return false;
      }
    } catch (_) {
      return false;
    }
  }

  /// Atomically downloads a surah audio file into a temporary file first,
  /// verifies integrity, and renames it to the permanent destination.
  /// Also pre-caches verse timestamps so highlighting works 100% offline.
  Future<File?> downloadSurah(
    int surahNumber,
    QuranReciter reciter, {
    void Function(double progress)? onProgress,
  }) async {
    final client = http.Client();
    IOSink? sink;
    File? tempFile;

    try {
      final primaryUrl = await QuranTimingService.instance.getMatchingAudioUrl(
        reciterId: reciter.id,
        surahNumber: surahNumber,
      );
      final fallbackUrl = reciter.getSurahUrl(surahNumber);

      final urlsToTry = <String>[
        if (primaryUrl != null && primaryUrl.isNotEmpty) primaryUrl,
        fallbackUrl,
      ];

      http.StreamedResponse? response;
      String? successfulUrl;

      for (final candidateUrl in urlsToTry) {
        try {
          final request = http.Request('GET', Uri.parse(candidateUrl));
          request.headers['User-Agent'] =
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36';

          final resp = await client.send(request).timeout(const Duration(seconds: 15));
          if (resp.statusCode == 200) {
            response = resp;
            successfulUrl = candidateUrl;
            break;
          }
        } catch (_) {
          continue;
        }
      }

      if (response == null || successfulUrl == null) {
        return null;
      }

      final totalBytes = response.contentLength ?? 0;
      int downloadedBytes = 0;

      final permanentPath = await getAudioFilePath(surahNumber, reciter.id);
      final tempPath = '$permanentPath.tmp';
      tempFile = File(tempPath);

      if (await tempFile.exists()) {
        try {
          await tempFile.delete();
        } catch (_) {}
      }

      sink = tempFile.openWrite();

      await for (final chunk in response.stream) {
        sink.add(chunk);
        downloadedBytes += chunk.length;
        if (totalBytes > 0 && onProgress != null) {
          onProgress((downloadedBytes / totalBytes).clamp(0.0, 1.0));
        }
      }

      await sink.flush();
      await sink.close();
      sink = null;

      // Validate downloaded file integrity
      final finalLength = await tempFile.length();
      final bool sizeValid = totalBytes > 0
          ? (finalLength >= (totalBytes * 0.98).toInt() && finalLength >= kMinValidAudioBytes)
          : (finalLength >= kMinValidAudioBytes);

      if (!sizeValid) {
        try {
          await tempFile.delete();
        } catch (_) {}
        return null;
      }

      final permanentFile = File(permanentPath);
      if (await permanentFile.exists()) {
        try {
          await permanentFile.delete();
        } catch (_) {}
      }

      await tempFile.rename(permanentPath);
      _notifyChange();

      // Pre-warm ayah timestamps in background so offline playback supports exact highlighting
      if (QuranTimingService.instance.supportsExactTiming(reciter.id)) {
        unawaited(QuranTimingService.instance.getAllTimestamps(
          reciterId: reciter.id,
          surahNumber: surahNumber,
          totalAyahs: 0,
        ));
      }

      return permanentFile;
    } catch (e) {
      if (sink != null) {
        try {
          await sink.close();
        } catch (_) {}
      }
      if (tempFile != null && await tempFile.exists()) {
        try {
          await tempFile.delete();
        } catch (_) {}
      }
      return null;
    } finally {
      client.close();
    }
  }

  Future<bool> deleteDownloadedSurah(int surahNumber, String reciterId) async {
    try {
      final path = await getAudioFilePath(surahNumber, reciterId);
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
        _notifyChange();
        return true;
      }
    } catch (_) {}
    return false;
  }

  /// Returns list of all surah numbers currently downloaded for the specified reciter.
  Future<List<int>> getDownloadedSurahs(String reciterId) async {
    final downloaded = <int>[];
    try {
      final dir = await _getAudioDirectory();
      final prefix = '${reciterId}_';
      final files = dir.listSync();
      for (final entity in files) {
        if (entity is File && entity.path.endsWith('.mp3')) {
          final fileName = entity.uri.pathSegments.last;
          if (fileName.startsWith(prefix) && entity.lengthSync() >= kMinValidAudioBytes) {
            final numberPart = fileName.substring(prefix.length).replaceAll('.mp3', '');
            final surahNum = int.tryParse(numberPart);
            if (surahNum != null) {
              downloaded.add(surahNum);
            }
          }
        }
      }
      downloaded.sort();
    } catch (_) {}
    return downloaded;
  }

  /// Searches for any valid downloaded audio file for the given surah number across any reciter.
  Future<String?> findAnyDownloadedFilePath(int surahNumber) async {
    try {
      final dir = await _getAudioDirectory();
      final files = dir.listSync();
      final suffix = '_$surahNumber.mp3';
      for (final entity in files) {
        if (entity is File && entity.path.endsWith(suffix)) {
          if (entity.lengthSync() >= kMinValidAudioBytes) {
            return entity.path;
          }
        }
      }
    } catch (_) {}
    return null;
  }

  /// Calculates total bytes used by downloaded Quran surahs (optionally filtered by reciter).
  Future<int> getTotalDownloadedBytes({String? reciterId}) async {
    int total = 0;
    try {
      final dir = await _getAudioDirectory();
      final files = dir.listSync();
      final prefix = reciterId != null ? '${reciterId}_' : null;
      for (final entity in files) {
        if (entity is File && entity.path.endsWith('.mp3')) {
          final fileName = entity.uri.pathSegments.last;
          if (prefix == null || fileName.startsWith(prefix)) {
            total += entity.lengthSync();
          }
        }
      }
    } catch (_) {}
    return total;
  }

  /// Deletes all downloaded surahs (optionally for a specific reciter, or for all reciters).
  Future<void> clearAllDownloads({String? reciterId}) async {
    try {
      final dir = await _getAudioDirectory();
      final files = dir.listSync();
      final prefix = reciterId != null ? '${reciterId}_' : null;
      for (final entity in files) {
        if (entity is File) {
          final fileName = entity.uri.pathSegments.last;
          if (fileName.endsWith('.tmp') ||
              (fileName.endsWith('.mp3') && (prefix == null || fileName.startsWith(prefix)))) {
            try {
              await entity.delete();
            } catch (_) {}
          }
        }
      }
    } catch (_) {}
    _notifyChange();
  }
}
