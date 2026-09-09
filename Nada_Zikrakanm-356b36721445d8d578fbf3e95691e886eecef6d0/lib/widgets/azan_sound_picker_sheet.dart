import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';

import '../app_localizations.dart';
import '../services/azan_audio_service.dart';
import '../services/notification_service.dart';
import '../services/storage_service.dart';
import 'app_theme.dart';

class AzanSoundPickerSheet {
  const AzanSoundPickerSheet._();

  static const _options = <_AzanOption>[
    _AzanOption(
      'makkah',
      'Makkah Adhan',
      'بانگی مەککەی پیرۆز',
      'Masjid al-Haram, Makkah Mukarramah',
      'مزگەوتی حەڕام، مەککەی پیرۆز',
      Icons.mosque_rounded,
    ),
    _AzanOption(
      'madinah',
      'Madinah Adhan',
      'بانگی مەدینەی منەوەرە',
      'Al-Masjid an-Nabawi, Madinah',
      'مزگەوتی پێغەمبەر ﷺ، مەدینە',
      Icons.mosque_rounded,
    ),
    _AzanOption(
      'aqsa',
      'Al-Aqsa Adhan',
      'بانگی مزگەوتی ئەقسا',
      'Al-Masjid al-Aqsa, Jerusalem (Al-Quds)',
      'مزگەوتی پیرۆزی ئەقسا، قودس',
      Icons.mosque_rounded,
    ),
    _AzanOption(
      'abdulbasit',
      'Abdul Basit Adhan',
      'بانگی شێخ عەبدولباست',
      'Classic Egyptian Studio Adhan',
      'دەنگی شێخ عەبدولباست عەبدولسەمەد',
      Icons.mic_rounded,
    ),
    _AzanOption(
      'mishary',
      'Mishary Alafasy Adhan',
      'بانگی میشاری ئەلعەفاسی',
      'Sheikh Mishary Rashid Alafasy',
      'دەنگی شێخ میشاری ڕاشد ئەلعەفاسی',
      Icons.mic_rounded,
    ),
    _AzanOption(
      'haram_classic',
      'Haram Classic',
      'بانگی کلاسیکی حەڕەم',
      'Historic Makkah Haram Recitation',
      'بانگی کۆن و مێژوویی حەڕەمی پیرۆز',
      Icons.mosque_rounded,
    ),
    _AzanOption(
      'riyadh',
      'Riyadh Adhan',
      'بانگی ڕیاز',
      'Saudi Mosque Style Adhan',
      'بانگی شێوازی مزگەوتەکانی ڕیاز',
      Icons.mosque_rounded,
    ),
    _AzanOption(
      'dubai',
      'Dubai Adhan',
      'بانگی دوبەی',
      'Grand Mosque of Dubai Adhan',
      'بانگی مزگەوتی گەورەی دوبەی',
      Icons.mosque_rounded,
    ),
    _AzanOption(
      'azan_short',
      'Azan Short (Mishary)',
      'بانگی کورتی ئەلعەفاسی',
      'Short Mishary Alafasy ringtone tone',
      'بانگی کورتی شێخ میشاری ڕاشد ئەلعەفاسی',
      Icons.notifications_active_rounded,
    ),
    _AzanOption(
      'azan_fajr',
      'Special Adhan',
      'بانگ',
      'Melodic Fajr Adhan tone',
      'بانگ و دەنگی تایبەتی نوێژی بەیانی',
      Icons.wb_twilight_rounded,
    ),
    _AzanOption(
      'vibrate',
      'Vibration Only',
      'تەنها لەرزین (ڤایبرەیشن)',
      'Vibrate at prayer times without sound',
      'لەرزین لە کاتی بانگدان بەبێ دەنگ',
      Icons.vibration_rounded,
    ),
    _AzanOption(
      'silent',
      'Silent Mode',
      'بێ دەنگ',
      'Visual notification only',
      'ئاگادارکردنەوەی بینراو بەبێ دەنگ و لەرزین',
      Icons.notifications_off_rounded,
    ),
  ];

  static Future<void> show(BuildContext context, {ValueChanged<String>? onSelected}) async {
    final player = AudioPlayer();
    var selectedId = AzanAudioService.resolveSafeSoundId(
      await StorageService.getAzanSound(),
    );
    String? playingId;
    final language = AppLocalizations.languageCode;
    final isKurdish = language == 'ku';

    if (!context.mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
          decoration: BoxDecoration(
            color: AppColors.darkPanel,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            border: Border.all(color: AppColors.gold.withValues(alpha: .4), width: 1.5),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                Container(
                width: 44,
                height: 5,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.volume_up_rounded, color: AppColors.gold, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      isKurdish ? 'دەنگی بانگدان و ئاگادارکردنەوە' : 'Azan & Notification Sound',
                      style: isKurdish
                          ? AppTheme.kurdishTitle(fontSize: 18, color: AppColors.cream)
                          : AppTheme.englishTitle(fontSize: 18, color: AppColors.cream),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(sheetContext),
                    icon: Icon(Icons.close_rounded, color: AppColors.faintText),
                  ),
                ],
              ),
              const Divider(color: Colors.white12, height: 18),
              Expanded(
                child: ListView.separated(
                  itemCount: _options.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final option = _options[index];
                    final safeOptionId = AzanAudioService.resolveSafeSoundId(option.id);
                    final selected = safeOptionId == selectedId;
                    final playing = safeOptionId == playingId;
                    final assetPath = AzanAudioService.assetPaths[safeOptionId];
                    final hasAudio = assetPath != null;

                    return Container(
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.gold.withValues(alpha: .14)
                            : AppColors.panelColor,
                        border: Border.all(
                          color: selected ? AppColors.gold : AppColors.panelBorderColor,
                          width: selected ? 1.5 : 1.0,
                        ),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(18),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: () async {
                            final safeId = AzanAudioService.resolveSafeSoundId(option.id);
                            await player.stop();
                            if (safeId == 'vibrate') {
                              HapticFeedback.mediumImpact();
                            }
                            await StorageService.saveAzanSound(safeId);
                            await NotificationService.rescheduleUpcomingPrayerAzans();
                            setSheetState(() {
                              selectedId = safeId;
                              playingId = null;
                            });
                            onSelected?.call(safeId);
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: selected
                                        ? AppColors.gold.withValues(alpha: 0.25)
                                        : Colors.white.withValues(alpha: 0.05),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    option.icon,
                                    color: selected ? AppColors.gold : AppColors.cream,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        isKurdish ? option.nameKu : option.name,
                                        textDirection: isKurdish ? TextDirection.rtl : TextDirection.ltr,
                                        style: isKurdish
                                            ? AppTheme.kurdishTitle(
                                                fontSize: 14,
                                                color: selected ? AppColors.gold : AppColors.cream,
                                              )
                                            : AppTheme.englishText(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: selected ? AppColors.gold : AppColors.cream,
                                              ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        isKurdish ? option.descKu : option.desc,
                                        style: AppTheme.englishText(
                                          fontSize: 11,
                                          color: selected
                                              ? AppColors.gold.withValues(alpha: 0.8)
                                              : AppColors.faintText,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (hasAudio)
                                  IconButton(
                                    tooltip: playing ? (isKurdish ? 'ڕاگرتن' : 'Stop') : (isKurdish ? 'گوێگرتن' : 'Listen'),
                                    icon: Icon(
                                      playing ? Icons.stop_circle_rounded : Icons.play_circle_fill_rounded,
                                      color: playing ? Colors.amber : AppColors.gold,
                                      size: 28,
                                    ),
                                    onPressed: () async {
                                      try {
                                        if (playing) {
                                          await player.stop();
                                          setSheetState(() => playingId = null);
                                        } else {
                                          await player.stop();
                                          await player.setAudioSource(AudioSource.asset(assetPath));
                                          await player.play();
                                          setSheetState(() => playingId = safeOptionId);
                                        }
                                      } catch (_) {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(isKurdish ? 'ناتوانرێت دەنگەکە لێبدرێت' : 'Unable to play this recording.'),
                                            ),
                                          );
                                        }
                                        setSheetState(() => playingId = null);
                                      }
                                    },
                                  ),
                                const SizedBox(width: 4),
                                if (selected)
                                  Icon(Icons.check_circle_rounded, color: AppColors.gold, size: 22),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
    await player.stop();
    await player.dispose();
  }
}

class _AzanOption {
  const _AzanOption(
    this.id,
    this.name,
    this.nameKu,
    this.desc,
    this.descKu,
    this.icon,
  );

  final String id;
  final String name;
  final String nameKu;
  final String desc;
  final String descKu;
  final IconData icon;
}
