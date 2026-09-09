import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';

import 'storage_service.dart';

/// Plays the Azan selected on Prayer Times. This is shared by the sound preview
/// and the prayer-time watcher so both paths always use the same source.
class AzanAudioService {
  AzanAudioService._();

  static final AzanAudioService instance = AzanAudioService._();

  final AudioPlayer _player = AudioPlayer();

  bool get isPlaying => _player.playing;
  Stream<bool> get isPlayingStream => _player.playingStream;

  static const Map<String, String> assetPaths = {
    'makkah': 'assets/azan/makkah.mp3',
    'madinah': 'assets/azan/madinah.mp3',
    'aqsa': 'assets/azan/aqsa.mp3',
    'abdulbasit': 'assets/azan/abdulbasit.mp3',
    'mishary': 'assets/azan/mishary.mp3',
    'haram_classic': 'assets/azan/haram_classic.mp3',
    'riyadh': 'assets/azan/riyadh.mp3',
    'dubai': 'assets/azan/dubai.mp3',
    'azan_short': 'assets/azan/azan_short.mp3',
    'azan_fajr': 'assets/azan/azan_fajr.mp3',
  };

  /// Configures the device audio session to playback mode.
  /// On iOS, this ensures the audio routes to the loudspeaker and plays
  /// EVEN IF the physical Ring/Silent switch on the iPhone is set to silent.
  Future<void> _configureAudioSession() async {
    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration(
        avAudioSessionCategory: AVAudioSessionCategory.playback,
        avAudioSessionCategoryOptions:
            AVAudioSessionCategoryOptions.defaultToSpeaker,
        avAudioSessionMode: AVAudioSessionMode.defaultMode,
        avAudioSessionRouteSharingPolicy:
            AVAudioSessionRouteSharingPolicy.defaultPolicy,
        avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
        androidAudioAttributes: AndroidAudioAttributes(
          contentType: AndroidAudioContentType.music,
          flags: AndroidAudioFlags.none,
          usage: AndroidAudioUsage.media,
        ),
        androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
        androidWillPauseWhenDucked: true,
      ));
    } catch (_) {}
  }

  static String resolveSafeSoundId(String? soundId) {
    final normalized = StorageService.normalizeAzanSoundId(soundId);
    if (normalized == 'silent' || normalized == 'vibrate') {
      return normalized;
    }
    if (assetPaths.containsKey(normalized)) {
      return normalized;
    }
    return 'makkah';
  }

  Future<void> playSelected() async {
    final soundId = await StorageService.getAzanSound();
    if (soundId == 'silent' || soundId == 'vibrate') {
      await stop();
      return;
    }
    final safeSoundId = resolveSafeSoundId(soundId);
    await play(safeSoundId);
  }

  Future<void> play(String soundId) async {
    final safeSoundId = resolveSafeSoundId(soundId);
    if (safeSoundId == 'silent' || safeSoundId == 'vibrate') {
      await stop();
      return;
    }
    final assetPath = assetPaths[safeSoundId];
    if (assetPath == null) return;

    await _configureAudioSession();
    await _player.stop();
    await _player.setAudioSource(
      AudioSource.asset(assetPath),
    );
    await _player.play();
  }

  Future<void> stop() => _player.stop();
}

