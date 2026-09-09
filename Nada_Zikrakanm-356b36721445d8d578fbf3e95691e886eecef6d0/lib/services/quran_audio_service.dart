import 'dart:async';
import 'dart:io';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import '../models/quran_reciter.dart';
import 'quran_download_service.dart';
import 'quran_timing_service.dart';
import 'storage_service.dart';

const Map<String, String> kAudioHeaders = {
  'User-Agent':
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
};

class QuranAudioService {
  QuranAudioService._();
  static final QuranAudioService instance = QuranAudioService._();

  final AudioPlayer _player = AudioPlayer();
  QuranReciter _selectedReciter = kQuranReciters.first;
  late final ValueNotifier<QuranReciter> reciterNotifier =
      ValueNotifier<QuranReciter>(_selectedReciter);
  int? _currentSurahNumber;
  String? _currentSurahName;

  /// The ayah number the audio is currently aligned to
  int? _currentAyahNumber;

  bool _initialized = false;

  /// Periodic timer that saves the audio position every 5 seconds while playing
  Timer? _positionSaveTimer;

  /// Per-ayah timestamps for the currently loaded surah: ayahNumber → ms
  Map<int, int> _ayahTimestamps = {};

  /// Sorted list of ayah numbers from _ayahTimestamps for binary search
  List<int> _sortedAyahNumbers = [];

  /// StreamController that emits the currently-playing ayah number
  final StreamController<int?> _currentAyahController =
      StreamController<int?>.broadcast();

  /// Total number of ayahs in the current surah (for proportional fallback)
  int _currentTotalAyahs = 0;
  bool _suppressPositionTracking = false;
  int _timingLoadToken = 0;
  int _playbackGeneration = 0;

  AudioPlayer get player => _player;
  QuranReciter get selectedReciter => _selectedReciter;
  int? get currentSurahNumber => _currentSurahNumber;
  String? get currentSurahName => _currentSurahName;
  int? get currentAyahNumber => _currentAyahNumber;

  bool _isPlayingFromLocalFile = false;
  String? _loadedFilePath;

  /// Whether the currently loaded audio source is an offline local file.
  bool get isPlayingFromLocalFile => _isPlayingFromLocalFile;

  /// Path to the currently loaded offline audio file, or null if streaming.
  String? get loadedFilePath => _loadedFilePath;

  Stream<PlayerState> get playerStateStream => _player.playerStateStream;
  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;

  /// Stream of the currently-playing ayah number (null when not playing)
  Stream<int?> get currentAyahStream => _currentAyahController.stream;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.music());
    } catch (_) {}
    final savedReciterId = await StorageService.readSetting(
        'selected_reciter_id',
        defaultValue: 'raad_kurdi');
    _selectedReciter = kQuranReciters.firstWhere(
      (r) => r.id == savedReciterId,
      orElse: () => kQuranReciters.first,
    );
    reciterNotifier.value = _selectedReciter;

    // Listen for surah completion → clear saved position
    _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed &&
          _currentSurahNumber != null) {
        StorageService.clearAudioPosition(
          surahNumber: _currentSurahNumber!,
          reciterId: _selectedReciter.id,
        );
        _currentAyahNumber = null;
        _currentAyahController.add(null);
      }
    });

    // Track position → compute current ayah in real time
    _player.positionStream.listen(_onPositionChanged);
  }

  /// Called on every position update to compute which ayah is currently playing
  void _onPositionChanged(Duration position) {
    if (_currentSurahNumber == null || _suppressPositionTracking) return;

    // If the selected reciter does NOT support exact timing/highlighting, never emit an ayah
    if (!hasExactTimingSupport) {
      if (_currentAyahNumber != null) {
        _currentAyahNumber = null;
        _currentAyahController.add(null);
      }
      return;
    }

    final posMs = position.inMilliseconds;
    int? ayah;

    if (_ayahTimestamps.isNotEmpty && _sortedAyahNumbers.isNotEmpty) {
      // Exact timing via binary search
      ayah = _computeAyahAtPosition(posMs);
    }

    if (ayah != null && ayah != _currentAyahNumber) {
      _currentAyahNumber = ayah;
      _currentAyahController.add(ayah);
    }
  }

  /// Binary search through sorted timestamps to find which ayah is at this position
  int? _computeAyahAtPosition(int posMs) {
    if (_sortedAyahNumbers.isEmpty) return null;

    int lo = 0;
    int hi = _sortedAyahNumbers.length - 1;
    int? result;

    while (lo <= hi) {
      final mid = (lo + hi) ~/ 2;
      final ayahNum = _sortedAyahNumbers[mid];
      final ts = _ayahTimestamps[ayahNum]!;
      if (ts <= posMs) {
        result = ayahNum;
        lo = mid + 1;
      } else {
        hi = mid - 1;
      }
    }
    return result;
  }

  /// Loads all timestamps for the current surah (called when audio starts)
  Future<void> _loadTimestampsForSurah(int surahNumber, int totalAyahs) async {
    final token = ++_timingLoadToken;
    final reciterId = _selectedReciter.id;
    _currentTotalAyahs = totalAyahs;
    final timestamps = await QuranTimingService.instance.getAllTimestamps(
      reciterId: reciterId,
      surahNumber: surahNumber,
      totalAyahs: totalAyahs,
    );
    if (token != _timingLoadToken ||
        _currentSurahNumber != surahNumber ||
        _selectedReciter.id != reciterId) {
      return;
    }
    _ayahTimestamps = timestamps;
    _sortedAyahNumbers = timestamps.keys.toList()..sort();
    if (!_suppressPositionTracking && _player.playing) {
      _onPositionChanged(_player.position);
    }
  }

  void _startPositionSaveTimer() {
    _positionSaveTimer?.cancel();
    _positionSaveTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      if (_currentSurahNumber == null) return;
      final position = _player.position;
      if (position.inSeconds > 0) {
        await StorageService.saveAudioPosition(
          surahNumber: _currentSurahNumber!,
          reciterId: _selectedReciter.id,
          positionSeconds: position.inMilliseconds / 1000.0,
        );
      }
    });
  }

  void _stopPositionSaveTimer() {
    _positionSaveTimer?.cancel();
    _positionSaveTimer = null;
  }

  void _resumePositionTracking() {
    _suppressPositionTracking = false;
    _onPositionChanged(_player.position);
  }

  Future<void> setReciter(QuranReciter reciter) async {
    _playbackGeneration++;
    final currentGen = _playbackGeneration;
    // Preserve the current position before switching
    final savedPositionMs = _player.position.inMilliseconds;
    final wasPlaying = _player.playing;
    final wasAyah = _currentAyahNumber;
    final wasSurah = _currentSurahNumber;
    final wasSurahName = _currentSurahName;
    final wasTotalAyahs = _currentTotalAyahs;

    _selectedReciter = reciter;
    reciterNotifier.value = reciter;
    await StorageService.saveSetting('selected_reciter_id', reciter.id);

    if (!hasExactTimingSupport) {
      _currentAyahNumber = null;
      _currentAyahController.add(null);
    }

    if (wasSurah != null && wasSurahName != null) {
      _suppressPositionTracking = true;
      _timingLoadToken++;
      _ayahTimestamps = {};
      _sortedAyahNumbers = [];

      await _player.stop();
      _currentSurahNumber = wasSurah;
      _currentSurahName = wasSurahName;
      _currentTotalAyahs = wasTotalAyahs;

      Duration seekTo = Duration(milliseconds: savedPositionMs);
      if (hasExactTimingSupport && wasAyah != null && wasAyah > 1) {
        final exactMs = await QuranTimingService.instance.getAyahTimestampMs(
          reciterId: _selectedReciter.id,
          surahNumber: wasSurah,
          ayahNumber: wasAyah,
        );
        if (exactMs != null) {
          seekTo = Duration(milliseconds: exactMs);
        }
      }

      await _loadAudioSource(wasSurah, initialPosition: seekTo);

      if (currentGen != _playbackGeneration) return;

      if (hasExactTimingSupport && wasTotalAyahs > 0) {
        _loadTimestampsForSurah(wasSurah, wasTotalAyahs);
        _currentAyahNumber = wasAyah ?? 1;
        _currentAyahController.add(_currentAyahNumber);
      } else {
        _currentAyahNumber = null;
        _currentAyahController.add(null);
      }

      if (wasPlaying) {
        await _player.play();
        _startPositionSaveTimer();
      }
      _resumePositionTracking();
    }
  }

  String getSurahAudioUrl(int surahNumber, {QuranReciter? reciter}) {
    final r = reciter ?? _selectedReciter;
    return r.getSurahUrl(surahNumber);
  }

  Future<void> _loadAudioSource(int surahNumber,
      {Duration? initialPosition}) async {
    final isOfflineAvailable =
        await QuranDownloadService.instance.isSurahDownloaded(
      surahNumber,
      _selectedReciter.id,
    );
    final filePath = await QuranDownloadService.instance.getAudioFilePath(
      surahNumber,
      _selectedReciter.id,
    );

    // 1. PRIMARY: If downloaded offline file exists for active reciter and is valid, ALWAYS prioritize playing from local disk!
    if (isOfflineAvailable) {
      final file = File(filePath);
      if (file.existsSync() &&
          file.lengthSync() >= QuranDownloadService.kMinValidAudioBytes) {
        try {
          await _player.setFilePath(
            filePath,
            initialPosition: initialPosition,
          );
          _isPlayingFromLocalFile = true;
          _loadedFilePath = filePath;
          return;
        } catch (_) {
          // If local playback failed unexpectedly, fall through to network stream
        }
      }
    }

    // 2. SECONDARY: Stream from network (using exact-timing matching URL if available, else standard reciter URL)
    try {
      final matchingUrl = await QuranTimingService.instance.getMatchingAudioUrl(
        reciterId: _selectedReciter.id,
        surahNumber: surahNumber,
      );
      if (matchingUrl != null && matchingUrl.isNotEmpty) {
        await _player.setAudioSource(
          AudioSource.uri(Uri.parse(matchingUrl), headers: kAudioHeaders),
          initialPosition: initialPosition,
        );
      } else {
        final url = getSurahAudioUrl(surahNumber);
        final audioSource = AudioSource.uri(
          Uri.parse(url),
          headers: kAudioHeaders,
        );
        await _player.setAudioSource(
          audioSource,
          initialPosition: initialPosition,
        );
      }
      _isPlayingFromLocalFile = false;
      _loadedFilePath = null;
    } catch (_) {
      // 3. FALLBACK: If network failed (e.g. offline/airplane mode), check once more if an offline file exists on disk
      final file = File(filePath);
      if (file.existsSync() &&
          file.lengthSync() >= QuranDownloadService.kMinValidAudioBytes) {
        try {
          await _player.setFilePath(filePath, initialPosition: initialPosition);
          _isPlayingFromLocalFile = true;
          _loadedFilePath = filePath;
          return;
        } catch (_) {}
      }

      // Also check if ANY reciter's downloaded file exists for this surah on disk
      final anyPath = await QuranDownloadService.instance.findAnyDownloadedFilePath(surahNumber);
      if (anyPath != null) {
        final f = File(anyPath);
        if (f.existsSync() && f.lengthSync() >= QuranDownloadService.kMinValidAudioBytes) {
          try {
            await _player.setFilePath(anyPath, initialPosition: initialPosition);
            _isPlayingFromLocalFile = true;
            _loadedFilePath = anyPath;
            return;
          } catch (_) {}
        }
      }

      // Final attempt without custom headers
      final url = getSurahAudioUrl(surahNumber);
      await _player.setUrl(url, initialPosition: initialPosition);
      _isPlayingFromLocalFile = false;
      _loadedFilePath = null;
    }
  }

  Future<void> playSurah(
    int surahNumber,
    String surahName, {
    QuranReciter? reciter,
    bool forceFromBeginning = false,
    int totalAyahs = 0,
  }) async {
    _playbackGeneration++;
    final currentGen = _playbackGeneration;
    await init();
    if (reciter != null) {
      _selectedReciter = reciter;
      await StorageService.savePreferredReciter(reciter.id);
    }

    _currentSurahNumber = surahNumber;
    _currentSurahName = surahName;
    _currentTotalAyahs = totalAyahs;
    if (hasExactTimingSupport) {
      _currentAyahNumber = 1;
      _currentAyahController.add(1);
    } else {
      _currentAyahNumber = null;
      _currentAyahController.add(null);
    }
    _timingLoadToken++;
    _ayahTimestamps = {};
    _sortedAyahNumbers = [];

    // Check saved position
    double? savedPosition;
    if (!forceFromBeginning) {
      savedPosition = await StorageService.getAudioPosition(
        surahNumber: surahNumber,
        reciterId: _selectedReciter.id,
      );
    }

    Duration? initialSeek;
    if (savedPosition != null && savedPosition > 0) {
      initialSeek = Duration(milliseconds: (savedPosition * 1000).toInt());
    }

    try {
      _suppressPositionTracking = true;
      _timingLoadToken++;
      _ayahTimestamps = {};
      _sortedAyahNumbers = [];
      await _player.stop();

      await _loadAudioSource(surahNumber, initialPosition: initialSeek);

      if (currentGen != _playbackGeneration) return;

      if (hasExactTimingSupport && totalAyahs > 0) {
        _loadTimestampsForSurah(surahNumber, totalAyahs);
      }
      await _player.play();
      _startPositionSaveTimer();
    } catch (_) {
      // Handled silently
    } finally {
      _suppressPositionTracking = false;
      if (_player.playing) {
        _onPositionChanged(_player.position);
      }
    }
  }

  /// Plays the surah starting immediately at the given ayah (for highlight reciters),
  /// or plays the surah for full-surah reciters without false highlights.
  Future<void> playFromAyah({
    required int surahNumber,
    required String surahName,
    required int ayahNumber,
    required int totalAyahs,
  }) async {
    _playbackGeneration++;
    final currentGen = _playbackGeneration;
    await init();

    _currentSurahNumber = surahNumber;
    _currentSurahName = surahName;
    _currentTotalAyahs = totalAyahs;

    if (hasExactTimingSupport) {
      _currentAyahNumber = ayahNumber;
      _currentAyahController.add(ayahNumber);
    } else {
      _currentAyahNumber = null;
      _currentAyahController.add(null);
    }

    try {
      _suppressPositionTracking = true;
      _timingLoadToken++;

      // 1. Immediately stop current audio
      await _player.stop();

      // 2. Resolve initial seek target BEFORE loading audio source
      Duration? initialSeek;
      if (hasExactTimingSupport) {
        if (ayahNumber <= 1) {
          initialSeek = Duration.zero;
        } else {
          final exactMs = await QuranTimingService.instance.getAyahTimestampMs(
            reciterId: _selectedReciter.id,
            surahNumber: surahNumber,
            ayahNumber: ayahNumber,
          );
          if (exactMs != null) {
            initialSeek = Duration(milliseconds: exactMs);
          }
        }
      }

      // 3. Load audio source
      await _loadAudioSource(surahNumber, initialPosition: initialSeek);

      if (currentGen != _playbackGeneration) return;

      // 4. Start playback
      await _player.play();
      _startPositionSaveTimer();

      // 5. Save position for resume
      final currentPos = initialSeek ?? _player.position;
      if (_currentSurahNumber == surahNumber) {
        await StorageService.saveAudioPosition(
          surahNumber: surahNumber,
          reciterId: _selectedReciter.id,
          positionSeconds: currentPos.inMilliseconds / 1000.0,
        );
      }

      // 6. Load all timestamps in background for live progress tracking
      if (hasExactTimingSupport && totalAyahs > 0) {
        _loadTimestampsForSurah(surahNumber, totalAyahs);
      }
    } catch (_) {
      // Handled gracefully
    } finally {
      _suppressPositionTracking = false;
      if (_player.playing) {
        _onPositionChanged(_player.position);
      }
    }
  }

  /// Returns the saved position in seconds for the given surah (for resume UI).
  Future<double?> getSavedPosition(int surahNumber) async {
    return StorageService.getAudioPosition(
      surahNumber: surahNumber,
      reciterId: _selectedReciter.id,
    );
  }

  /// Returns true if this reciter has exact API-based timing support.
  bool get hasExactTimingSupport =>
      QuranTimingService.instance.supportsExactTiming(_selectedReciter.id);

  Future<void> pause() async {
    await _player.pause();
    if (_currentSurahNumber != null) {
      final pos = _player.position;
      if (pos.inSeconds > 0) {
        await StorageService.saveAudioPosition(
          surahNumber: _currentSurahNumber!,
          reciterId: _selectedReciter.id,
          positionSeconds: pos.inMilliseconds / 1000.0,
        );
      }
    }
  }

  Future<void> resume() async {
    final surahNumber = _currentSurahNumber;
    if (surahNumber != null) {
      // If a local file has become available since the audio source was loaded,
      // reload directly from the local file so playback switches to offline!
      final hasLocal = await QuranDownloadService.instance.isSurahDownloaded(
        surahNumber,
        _selectedReciter.id,
      );
      if (hasLocal && !_isPlayingFromLocalFile) {
        final currentPos = _player.position;
        await _loadAudioSource(surahNumber, initialPosition: currentPos);
      }
    }

    if (_player.processingState == ProcessingState.idle ||
        _player.processingState == ProcessingState.completed) {
      if (surahNumber != null) {
        await _loadAudioSource(surahNumber, initialPosition: _player.position);
      }
    }

    await _player.play();
    _startPositionSaveTimer();
    _resumePositionTracking();
  }

  /// Seamlessly switches active playback to the newly downloaded offline file if matching the active surah.
  Future<void> switchToLocalFileIfAvailable(int surahNumber) async {
    if (_currentSurahNumber == surahNumber && !_isPlayingFromLocalFile) {
      final wasPlaying = _player.playing;
      final currentPos = _player.position;
      await _loadAudioSource(surahNumber, initialPosition: currentPos);
      if (wasPlaying) {
        await _player.play();
      }
    }
  }

  Future<void> stop() async {
    _playbackGeneration++;
    _stopPositionSaveTimer();
    final surahNumber = _currentSurahNumber;
    final reciterId = _selectedReciter.id;
    final position = _player.position;

    await _player.stop();

    _currentSurahNumber = null;
    _currentSurahName = null;
    _currentAyahNumber = null;
    _currentAyahController.add(null);
    _ayahTimestamps = {};
    _sortedAyahNumbers = [];
    _currentTotalAyahs = 0;
    _isPlayingFromLocalFile = false;
    _loadedFilePath = null;

    if (surahNumber != null && position.inSeconds > 0) {
      await StorageService.saveAudioPosition(
        surahNumber: surahNumber,
        reciterId: reciterId,
        positionSeconds: position.inMilliseconds / 1000.0,
      );
    }
  }

  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  Future<void> setSpeed(double speed) async {
    await _player.setSpeed(speed);
  }
}
