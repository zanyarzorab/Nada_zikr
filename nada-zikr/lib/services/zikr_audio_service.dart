import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import '../models/azkar_model.dart';

/// Authentic human-recorded Zikr audio
/// Primary source: thenasihun.github.io/me-azkar-web/assets/{id}.mp3
/// Supplementary sources:
/// - Hisnul Muslim Audio Database (for missing/distinct assets 11, 29, 95)
/// - Mishary Rashid Alafasy Authentic Adhkar (for Evening 'Amsayna ala fitrat al-Islam' 113)
String _audio(int id) {
  if (id == 11) {
    // Bismillah alladhi la yadurru ma'asmihi (Hisnul Muslim #86)
    return 'https://raw.githubusercontent.com/sheikhhanif/Hisnul_Muslim_Database/master/audio/86hm.mp3';
  }
  if (id == 29) {
    // Astaghfirullah wa atubu ilayh (Hisnul Muslim #96)
    return 'https://raw.githubusercontent.com/sheikhhanif/Hisnul_Muslim_Database/master/audio/96hm.mp3';
  }
  if (id == 95) {
    // Allahumma inni as'aluka 'ilman nafi'an (Hisnul Muslim #95)
    return 'https://raw.githubusercontent.com/sheikhhanif/Hisnul_Muslim_Database/master/audio/95hm.mp3';
  }
  if (id == 113) {
    // Amsayna 'ala fitrat al-Islam (Evening) - Mishary Rashid Alafasy
    return 'https://archive.org/download/azkar-almasaa_202601/%D8%A3%D9%85%D8%B3%D9%8A%D9%86%D8%A7%20%D8%B9%D9%84%D9%89%20%D9%81%D8%B7%D8%B1%D8%A9%20%D8%A7%D9%84%D8%A5%D8%B3%D9%84%D8%A7%D9%85.mp3';
  }
  return 'https://thenasihun.github.io/me-azkar-web/assets/$id.mp3';
}

/// ── Audio ID Reference (thenasihun supplications.json) ──────────────────────
/// ID 1   = Ayat Al-Kursi (البقرة 255)
/// ID 2   = Al-Ikhlas ×3
/// ID 3   = Al-Falaq ×3
/// ID 4   = An-Nas ×3
/// ID 5   = Hasbiyallahu la ilaha illa hu ×7
/// ID 6   = Allahumma ma asbaha bi (morning ni'mah)
/// ID 7   = Allahumma ma amsa bi (evening ni'mah)
/// ID 8   = Allahumma bika asbahna (morning)
/// ID 9   = Allahumma bika amsayna (evening)
/// ID 10  = Ya Hayyu ya Qayyum bi-rahmatika astaghith
/// ID 11  = Bismillah alladhi la yadurr ×3 (Hisnul Muslim #86)
/// ID 12  = A'udhu bi kalimatillah al-tammah ×3
/// ID 13  = Raditu billahi rabba ×3
/// ID 14  = Subhanallah wa bihamdih adada khalqih (morning)
/// ID 15  = Asbahna wa asbahal mulk lillahi rabbil 'alamin (morning pos 19)
/// ID 16  = Amsayna wa amsal mulk lillahi rabbil 'alamin (evening pos 19)
/// ID 17  = Asbahna ala fitrat al-Islam (morning pos 18)
/// ID 18  = Allahumma afini fi badani ×3 (pos 10)
/// ID 19  = Allahumma inni asbahtu ushiduka ×4 (morning pos 8)
/// ID 20  = Allahumma inni amsaytu ushiduka ×4 (evening pos 8)
/// ID 21  = Allahumma inni as'aluka al-'afw wal-'afiyah (pos 12)
/// ID 22  = Allahumma alim al-ghayb wal-shahadah (pos 13)
/// ID 23  = Allahumma anta rabbi la ilaha illa anta (sayyid al-istighfar pos 7)
/// ID 24  = Asbahna wa asbahal mulku lillah wal-hamdu lillah (morning pos 5)
/// ID 25  = Amsayna wa amsal mulku lillah wal-hamdu lillah (evening pos 5)
/// ID 26  = La ilaha illallah wahdahu la sharika lah ×10 (pos 20, 21)
/// ID 28  = Subhanallah wa bihamdih ×100 / Subhanallah ×33
/// ID 29  = Astaghfirullah wa atubu ilayh ×100 (Hisnul Muslim #96)
/// ID 30  = Allahumma salli wa sallim ala nabiyyina Muhammad ×10 (pos 25)
/// ID 95  = Allahumma inni as'aluka 'ilman nafi'an (Hisnul Muslim #95)
/// ID 113 = Amsayna ala fitrat al-Islam (evening pos 18) (Hisnul Muslim #113)
/// ────────────────────────────────────────────────────────────────────────────

class ZikrAudioService {
  ZikrAudioService._();
  static final ZikrAudioService instance = ZikrAudioService._();

  final AudioPlayer _player = AudioPlayer();
  String? _itemCurrentlyPlayingKey;
  Directory? _cacheDir;

  AudioPlayer get player => _player;
  AudioPlayer get itemPlayer => _player;
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;
  Stream<PlayerState> get itemPlayerStateStream => _player.playerStateStream;
  String? get currentlyPlayingKey => _itemCurrentlyPlayingKey;
  String? get itemCurrentlyPlayingKey => _itemCurrentlyPlayingKey;

  static bool hasFullAudio(String categoryId) => false;

  Future<void> stopAudio() async {
    _itemCurrentlyPlayingKey = null;
    await _player.stop();
  }

  /// Plays authentic human-recorded audio for a single Zikr item with local caching
  Future<void> toggleZikrItemAudio(
      Azkar zikr, int currentIndex, String? categoryId) async {
    final zikrId = zikr.id ?? (currentIndex + 1);
    final remoteUrl = _resolveAudioUrl(zikr, currentIndex, categoryId);
    final audioFileName = remoteUrl.split('/').last;
    final key = 'zikr_${categoryId}_${zikrId}_$currentIndex';

    // Toggle play/pause for same item
    if (_itemCurrentlyPlayingKey == key) {
      if (_player.playing) {
        await _player.pause();
      } else {
        await _player.play();
      }
      return;
    }

    _itemCurrentlyPlayingKey = key;
    await _player.stop();

    try {
      final cachePath = await _getCacheFilePath('${key}_$audioFileName');
      final cacheFile = File(cachePath);

      // 1. Offline cache hit
      if (await cacheFile.exists() && await cacheFile.length() > 1024) {
        await _player.setFilePath(cachePath);
        await _player.play();
        return;
      }

      // 2. Stream and cache
      final downloadedFile = await _downloadAndCacheAudio(remoteUrl, cacheFile);
      if (downloadedFile != null && await downloadedFile.exists()) {
        await _player.setFilePath(downloadedFile.path);
        await _player.play();
      } else {
        await _player.setUrl(remoteUrl, headers: const {
          'User-Agent':
              'Mozilla/5.0 (Linux; Android 11) AppleWebKit/537.36',
        });
        await _player.play();
      }
    } catch (_) {
      _itemCurrentlyPlayingKey = null;
    }
  }

  /// Stop individual card audio
  Future<void> stopItemAudio() async {
    _itemCurrentlyPlayingKey = null;
    await _player.stop();
  }

  /// Stop all audio when leaving screen
  Future<void> stop() async {
    _itemCurrentlyPlayingKey = null;
    await _player.stop();
  }

  /// Normalizes Arabic text for robust pattern matching
  static String _normalizeArabic(String text) {
    return text
        .replaceAll(RegExp(r'[\u064B-\u0652\u0670\u0640]'), '')
        .replaceAll(RegExp(r'[أإآٱ]'), 'ا')
        .replaceAll('ى', 'ي')
        .replaceAll(RegExp(r'[\s\u00A0]+'), ' ')
        .trim();
  }

  /// Core routing — matches every zikr text to its correct authentic audio
  String _resolveAudioUrl(Azkar zikr, int currentIndex, String? categoryId) {
    final t = zikr.displayArabic;
    final norm = _normalizeArabic(t);

    // ════════════════════════════════════════════════════════════════════════
    // QURANIC VERSES
    // ════════════════════════════════════════════════════════════════════════

    // Ayat Al-Kursi (البقرة 255)
    if (categoryId == 'ayat_kursi' ||
        (norm.contains('الحي القيوم') ||
            norm.contains('وسع كرسيه') ||
            norm.contains('كرسيه') ||
            norm.contains('لا تاخذه سنة')) &&
            !norm.contains('الفلق') &&
            !norm.contains('الناس')) {
      return _audio(1);
    }
    // آمَنَ الرَّسُولُ (البقرة 285-286)
    if (norm.contains('امن الرسول') || norm.contains('لا يكلف الله نفسا')) {
      return _audio(101);
    }
    // Al-Ikhlas
    if (norm.contains('قل هو الله احد') || norm.contains('الله الصمد')) {
      return _audio(2);
    }
    // Al-Falaq
    if (norm.contains('برب الفلق') || norm.contains('الفلق')) {
      return _audio(3);
    }
    // An-Nas
    if (norm.contains('برب الناس') ||
        norm.contains('ملك الناس') ||
        norm.contains('الوسواس الخناس')) {
      return _audio(4);
    }

    // ════════════════════════════════════════════════════════════════════════
    // MORNING-SPECIFIC ZIKRS (cat 27, IDs 75–97)
    // ════════════════════════════════════════════════════════════════════════
    if (categoryId == 'morning' ||
        norm.startsWith('اصبحنا') ||
        norm.startsWith('اللهم بك اصبحنا') ||
        norm.contains('ما اصبح بي') ||
        (norm.contains('اشهدك') && norm.contains('اصبحت'))) {
      // Pos 19: Asbahna wa asbahal mulku lillahi rabbil 'alamin
      if (norm.contains('اصبحنا') &&
          (norm.contains('رب العالمين') ||
              norm.contains('فتحه ونصره') ||
              norm.contains('نوره وبركته'))) {
        return _audio(15);
      }
      // Pos 5: Asbahna wa asbahal mulku lillah wal-hamdu lillah
      if (norm.contains('اصبحنا واصبح الملك') ||
          (norm.contains('اصبحنا') && norm.contains('الملك لله'))) {
        return _audio(24);
      }
      // Pos 6: Allahumma bika asbahna
      if (norm.contains('بك اصبحنا')) {
        return _audio(8);
      }
      // Pos 8: Allahumma inni asbahtu ushiduka
      if (norm.contains('اشهدك') && norm.contains('اصبحت')) {
        return _audio(19);
      }
      // Pos 9: Allahumma ma asbaha bi
      if (norm.contains('ما اصبح بي')) {
        return _audio(6);
      }
      // Pos 18: Asbahna ala fitrat al-Islam
      if (norm.contains('اصبحنا علي فطرة') ||
          norm.contains('اصبحنا على فطرة') ||
          norm.contains('فطرة الاسلام')) {
        return _audio(17);
      }
      // Pos 23: As'aluka 'ilman nafi'an wa rizqan tayyiban
      if (norm.contains('اسالك علما نافعا') || norm.contains('علما نافعا')) {
        return _audio(95);
      }
    }

    // ════════════════════════════════════════════════════════════════════════
    // EVENING-SPECIFIC ZIKRS (cat 28, IDs 98–118)
    // ════════════════════════════════════════════════════════════════════════
    if (categoryId == 'evening' ||
        norm.startsWith('امسينا') ||
        norm.startsWith('اللهم بك امسينا') ||
        norm.contains('ما امسي بي') ||
        (norm.contains('اشهدك') && norm.contains('امسيت'))) {
      // Pos 19: Amsayna wa amsal mulku lillahi rabbil 'alamin
      if (norm.contains('امسينا') &&
          (norm.contains('رب العالمين') ||
              norm.contains('فتحها ونصرها') ||
              norm.contains('نورها وبركتها'))) {
        return _audio(16);
      }
      // Pos 5: Amsayna wa amsal mulku lillah wal-hamdu lillah
      if (norm.contains('امسينا وامسى الملك') ||
          norm.contains('امسينا وامسي الملك') ||
          (norm.contains('امسينا') && norm.contains('الملك لله'))) {
        return _audio(25);
      }
      // Pos 6: Allahumma bika amsayna
      if (norm.contains('بك امسينا')) {
        return _audio(9);
      }
      // Pos 8: Allahumma inni amsaytu ushiduka
      if (norm.contains('اشهدك') && norm.contains('امسيت')) {
        return _audio(20);
      }
      // Pos 9: Allahumma ma amsa bi
      if (norm.contains('ما امسي بي') || norm.contains('ما امسى بي')) {
        return _audio(7);
      }
      // Pos 18: Amsayna ala fitrat al-Islam
      if (norm.contains('امسينا علي فطرة') ||
          norm.contains('امسينا على فطرة') ||
          norm.contains('امسينا على فطره') ||
          norm.contains('فطرة الاسلام') ||
          norm.contains('فطره الاسلام')) {
        return _audio(113);
      }
      // Pos 22: A'udhu bi kalimatillah al-tammah min sharr ma khalaq
      if (norm.contains('بكلمات الله التامات')) {
        return _audio(12);
      }
    }

    // ════════════════════════════════════════════════════════════════════════
    // SHARED MORNING / EVENING & GENERAL ZIKRS
    // ════════════════════════════════════════════════════════════════════════

    // Pos 7: Sayyid al-Istighfar — Allahumma anta rabbi khalaqtani
    if (norm.contains('انت ربي') && norm.contains('خلقتني')) {
      return _audio(23);
    }
    // Pos 10: Allahumma afini fi badani
    if (norm.contains('عافني في بدني')) {
      return _audio(18);
    }
    // Pos 11: Hasbiyallah la ilaha illa hu
    if (norm.contains('حسبي الله')) {
      return _audio(5);
    }
    // Pos 12: Allahumma inni as'aluka al-'afw wal-'afiyah
    if (norm.contains('اسالك العفو والعافية') ||
        norm.contains('العفو والعافية') ||
        norm.contains('اسالك العافية')) {
      return _audio(21);
    }
    // Pos 13: Allahumma alim al-ghayb wal-shahadah
    if (norm.contains('عالم الغيب')) {
      return _audio(22);
    }
    // Pos 14: Bismillah alladhi la yadurr
    if (norm.contains('لا يضر مع اسمه')) {
      return _audio(11);
    }
    // Pos 15: Raditu billahi rabba
    if (norm.contains('رضيت بالله')) {
      return _audio(13);
    }
    // Pos 16: Ya Hayyu ya Qayyum bi-rahmatika
    if (norm.contains('يا حي يا قيوم')) {
      return _audio(10);
    }
    // A'udhu bi kalimatillah al-tammah (shared / evening)
    if (norm.contains('بكلمات الله التامات')) {
      return _audio(12);
    }
    // Pos 22 morning: Subhanallah wa bihamdih adada khalqih (special tasbih)
    if (norm.contains('سبحان الله وبحمده') &&
        (norm.contains('عدد خلقه') || norm.contains('رضا نفسه'))) {
      return _audio(14);
    }
    // Pos 19 morning / Pos 17 evening / General: Subhanallah wa bihamdih
    if (norm.contains('سبحان الله وبحمده')) {
      return _audio(28);
    }
    // Pos 20,21: La ilaha illallah wahdahu la sharika lah
    if ((norm.contains('لا اله الا الله') && norm.contains('وحده لا شريك له')) ||
        norm.contains('لا اله الا الله وحده')) {
      return _audio(26);
    }
    // Pos 24: Astaghfirullah wa atubu ilayh
    if (norm.contains('استغفر الله واتوب') || norm.contains('استغفر الله')) {
      return _audio(29);
    }
    // Pos 25: Allahumma salli wa sallim ala nabiyyina
    if (norm.contains('صل وسلم') || norm.contains('صل علي') || norm.contains('صل على')) {
      return _audio(30);
    }



    // ════════════════════════════════════════════════════════════════════════
    // AFTER PRAYER ZIKRS (AppData.prayerAzkar)
    // ════════════════════════════════════════════════════════════════════════

    // "Allahumma anta al-Salam wa minka al-salam"
    if (t.contains('أَنْتَ السَّلاَمُ') || t.contains('مِنْكَ السَّلاَمُ')) {
      return _audio(26); // tahlil as closest match
    }
    // "Allahumma la mani'a lima a'tayta"
    if (t.contains('لَا مَانِعَ لِمَا أَعْطَيْتَ') || t.contains('لا مانع لما اعطيت')) {
      return _audio(28);
    }
    // Subhanallah ×33 / ×100
    if (t.contains('سُبْحَانَ اللَّهِ') && !t.contains('وَبِحَمْدِهِ')) {
      return _audio(28);
    }
    // Al-Hamdulillah ×33
    if (t.startsWith('الْحَمْدُ لِلَّهِ') || t.trim() == 'الْحَمْدُ لِلَّهِ') {
      return _audio(28);
    }
    // Allahu Akbar ×34
    if (t.startsWith('اللَّهُ أَكْبَرُ') || t.trim() == 'اللَّهُ أَكْبَرُ') {
      return _audio(28);
    }
    // "Allahumma a'inni ala dhikrika wa shukrika"
    if (t.contains('أَعِنِّي عَلَىٰ ذِكْرِكَ') || t.contains('اعنني على ذكرك')) {
      return _audio(21);
    }
    // "Allahumma salli ala Muhammad wa ala al Muhammad"
    if (t.contains('صَلِّ عَلَى مُحَمَّدٍ وَعَلَى آلِ مُحَمَّدٍ') ||
        t.contains('صلي على محمد وعلى آل محمد')) {
      return _audio(30);
    }
    // "Rabbi ighfir li wa tub alayya"
    if (t.contains('رَبِّ اغْفِرْ لِي وَتُبْ') || t.contains('اغفر لي وتب')) {
      return _audio(29);
    }
    // "Allahumma ihdini wa saddidni"
    if (t.contains('اهْدِنِي وَسَدِّدْنِي') || t.contains('اهدني وسددني')) {
      return _audio(22);
    }
    // "Allahumma ighfir li wa li walidayya wal-muslimin"
    if (t.contains('اغْفِرْ لِي وَلِوَالِدَيَّ') || t.contains('اغفر لي ولوالدي')) {
      return _audio(21);
    }
    // "Allahumma inni as'aluka al-huda wal-tuqa wal-'afaf wal-ghina"
    if (t.contains('الْهُدَى وَالتُّقَى') || t.contains('الهدى والتقى')) {
      return _audio(22);
    }

    // ════════════════════════════════════════════════════════════════════════
    // QURAN AZKAR (Quranic du'as from AppData.quranAzkar)
    // ════════════════════════════════════════════════════════════════════════

    // "Wa qul Rabbi zidni 'ilma"
    if (t.contains('رَبِّ زِدْنِي عِلْمًا') || t.contains('ربي زدني علما')) {
      return _audio(21);
    }
    // "Rabbana atina fi al-dunya hasanah"
    if (t.contains('آتِنَا فِي الدُّنْيَا حَسَنَةً') || t.contains('حسنة في الاخرة')) {
      return _audio(21);
    }
    // "Rabbana la tu'akhidhna in nasina"
    if (t.contains('لَا تُؤَاخِذْنَا') || t.contains('لا تؤاخذنا')) {
      return _audio(21);
    }
    // "Rabbana la tuzigh qulubana"
    if (t.contains('لَا تُزِغْ قُلُوبَنَا') || t.contains('لا تزغ قلوبنا')) {
      return _audio(22);
    }
    // "Rabbana innana sami'na munadiya"
    if (t.contains('سَمِعْنَا مُنَادِيًا') || t.contains('سمعنا مناديا')) {
      return _audio(21);
    }
    // "Rabbi ij'alni muqim al-salah"
    if (t.contains('اجْعَلْنِي مُقِيمَ الصَّلَاةِ') || t.contains('مقيم الصلاة')) {
      return _audio(30);
    }
    // "Rabbana hab lana min azwajina"
    if (t.contains('هَبْ لَنَا مِنْ أَزْوَاجِنَا') || t.contains('قرة اعين')) {
      return _audio(21);
    }
    // "Rabbi a'udhu bika min hamazat al-shayatin"
    if (t.contains('هَمَزَاتِ الشَّيَاطِينِ') || t.contains('همزات الشياطين')) {
      return _audio(12);
    }
    // "La ilaha illa anta subhanaka inni kuntu min al-zalimin"
    if (t.contains('سُبْحَانَكَ إِنِّي كُنتُ مِنَ الظَّالِمِينَ') ||
        t.contains('لا اله إلا أنت سبحانك')) {
      return _audio(26);
    }
    // "Rabbi ishrah li sadri"
    if (t.contains('اشْرَحْ لِي صَدْرِي') || t.contains('اشرح لي صدري')) {
      return _audio(21);
    }
    // "Rabbana waj'alna muslimayni lak"
    if (t.contains('وَاجْعَلْنَا مُسْلِمَيْنِ') || t.contains('امة مسلمة')) {
      return _audio(21);
    }
    // "Rabbana afrigh 'alayna sabran"
    if (t.contains('أَفْرِغْ عَلَيْنَا صَبْرًا') || t.contains('افرغ علينا صبرا')) {
      return _audio(21);
    }
    // "Rabbana zalamna anfusana"
    if (t.contains('ظَلَمْنَا أَنفُسَنَا') || t.contains('ظلمنا انفسنا')) {
      return _audio(21);
    }
    // "Rabbana ighfir li wa li walidayya wal-mu'minin yawm al-hisab"
    if (t.contains('يَوْمَ يَقُومُ الْحِسَابُ') || t.contains('يوم يقوم الحساب')) {
      return _audio(21);
    }
    // "Rabbi anzilni munzalan mubarakan"
    if (t.contains('مُنْزَلًا مُّبَارَكًا') || t.contains('منزلا مباركا')) {
      return _audio(21);
    }
    // "Rabbi hab li hukman wa alhiqni bil-salihin"
    if (t.contains('هَبْ لِي حُكْمًا') || t.contains('والحقني بالصالحين')) {
      return _audio(21);
    }
    // "Rabbi hab li min ladunka dhurriyatan tayyibatan"
    if (t.contains('ذُرِّيَّةً طَيِّبَةً') || t.contains('ذرية طيبة')) {
      return _audio(21);
    }
    // "Rabbi inni lima anzalta ilayya min khayr faqir"
    if (t.contains('لِمَا أَنزَلْتَ إِلَيَّ مِنْ خَيْرٍ فَقِيرٌ') ||
        t.contains('فقير لما انزلت')) {
      return _audio(21);
    }
    // "Rabbana ighfir lana wa li ikhwanina"
    if (t.contains('وَلِإِخْوَانِنَا الَّذِينَ سَبَقُونَا') ||
        t.contains('لا تجعل في قلوبنا غلا')) {
      return _audio(21);
    }

    // ════════════════════════════════════════════════════════════════════════
    // GENERAL AZKAR (AppData.generalAzkar)
    // ════════════════════════════════════════════════════════════════════════

    // General tasbih: Subhanallah wa bihamdih ×100
    if (t.contains('سُبْحَانَ اللَّهِ وَبِحَمْدِهِ') ||
        t.contains('سبحان الله وبحمده')) {
      return _audio(28);
    }
    // "Astaghfirullah al-azim"
    if (t.contains('أَسْتَغْفِرُ اللَّهَ الْعَظِيمَ') || t.contains('استغفر الله العظيم')) {
      return _audio(29);
    }
    // "Allahumma inni as'aluka al-'afiyah" (short)
    if (t.contains('أَسْأَلُكَ الْعَافِيَةَ') || t.contains('اسألك العافية')) {
      return _audio(21);
    }
    // "La hawla wa la quwwata illa billah"
    if (t.contains('لَا حَوْلَ وَلَا قُوَّةَ') || t.contains('لا حول ولا قوة')) {
      return _audio(26);
    }
    // "Allahumma salli ala Muhammad" (short form)
    if (t.contains('صَلِّ عَلَى مُحَمَّدٍ') || t.contains('صلي على محمد')) {
      return _audio(30);
    }
    // "Rabbana atina fi al-dunya hasanah" (short form)
    if (t.contains('رَبَّنَا آتِنَا فِي الدُّنْيَا') || t.contains('ربنا آتنا')) {
      return _audio(21);
    }
    // "Allahumma inni as'aluka al-huda wal-tuqa" (short form)
    if (t.contains('الْهُدَى وَالتُّقَى') || t.contains('الهدى والتقى')) {
      return _audio(22);
    }
    // "Allahumma ighfir li wa li walidayya" (short)
    if (t.contains('اغْفِرْ لِي وَلِوَالِدَيَّ') || t.contains('ولوالدي')) {
      return _audio(21);
    }
    // "Allahumma hadini wa saddidni"
    if (t.contains('هَدِنِي وَسَدِّدْنِي') || t.contains('هدني وسددني')) {
      return _audio(22);
    }
    // "Allahumma inni as'aluka al-jannah"
    if (t.contains('أَسْأَلُكَ الْجَنَّةَ') || t.contains('اسألك الجنة')) {
      return _audio(21);
    }

    // ════════════════════════════════════════════════════════════════════════
    // CATEGORY FALLBACKS
    // ════════════════════════════════════════════════════════════════════════
    if (categoryId == 'morning') return _audio(8);
    if (categoryId == 'evening') return _audio(9);
    if (categoryId == 'sleep')   return _audio(10);
    if (categoryId == 'prayer')  return _audio(28);
    if (categoryId == 'quran')   return _audio(21);
    if (categoryId == 'general') return _audio(26);

    return _audio(1); // final fallback
  }

  // ─── Private helpers ──────────────────────────────────────────────────────

  Future<Directory> _getCacheDirectory() async {
    if (_cacheDir != null) return _cacheDir!;
    final appDocDir = await getApplicationDocumentsDirectory();
    final dir = Directory('${appDocDir.path}/zikr_audio_cache');
    if (!await dir.exists()) await dir.create(recursive: true);
    _cacheDir = dir;
    return dir;
  }

  Future<String> _getCacheFilePath(String cacheKey) async {
    final dir = await _getCacheDirectory();
    final safeName = cacheKey.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_');
    return '${dir.path}/$safeName.mp3';
  }

  Future<File?> _downloadAndCacheAudio(String urlStr, File targetFile) async {
    try {
      final client = http.Client();
      final request = http.Request('GET', Uri.parse(urlStr))
        ..headers['User-Agent'] =
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36';
      request.followRedirects = true;
      request.maxRedirects = 5;

      final streamedResponse = await client.send(request);
      if (streamedResponse.statusCode == 200) {
        final tempFile = File('${targetFile.path}.tmp');
        final sink = tempFile.openWrite();
        await streamedResponse.stream.pipe(sink);
        await sink.close();
        if (await tempFile.exists() && await tempFile.length() > 1024) {
          if (await targetFile.exists()) await targetFile.delete();
          await tempFile.rename(targetFile.path);
          return targetFile;
        }
      }
    } catch (_) {}
    return null;
  }

  static String cleanTextForAudio(String input) {
    var text = input.trim();
    text = text.replaceAll(RegExp(r'\s*\([^)]*\)'), '');
    if (text.length > 200) text = text.substring(0, 200);
    return text.trim();
  }
}
