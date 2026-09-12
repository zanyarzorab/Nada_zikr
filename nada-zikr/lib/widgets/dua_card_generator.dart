import 'package:flutter/material.dart';
import '../app_localizations.dart';
import '../models/azkar_model.dart';
import '../services/app_share_service.dart';
import 'app_theme.dart';

class DuaCardGeneratorDialog extends StatelessWidget {
  final Azkar azkar;

  const DuaCardGeneratorDialog({Key? key, required this.azkar}) : super(key: key);

  void _shareDuaCard(BuildContext context, String lang, bool isKurdish) {
    final buffer = StringBuffer();
    buffer.writeln('✦ نه‌دا • NADA ✦');
    buffer.writeln();
    buffer.writeln(azkar.arabic);
    buffer.writeln();
    if (azkar.kurdishTranslation.isNotEmpty) {
      buffer.writeln('📖 مانای کوردی:');
      buffer.writeln(azkar.kurdishTranslation);
      buffer.writeln();
    }
    if (azkar.translation.isNotEmpty &&
        azkar.translation != azkar.kurdishTranslation) {
      buffer.writeln('🌐 English Translation:');
      buffer.writeln(azkar.translation);
      buffer.writeln();
    }
    if (azkar.source.isNotEmpty) {
      buffer.writeln('— ${azkar.source}');
      buffer.writeln();
    }
    buffer.writeln('لە ڕێگەی ئەپی نەدا (Nada) بۆ زیکر و دوعاکان 🌟');

    AppShareService.share(context, buffer.toString());
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final lang = loc?.locale.languageCode ?? 'ku';
    final isKurdish = lang == 'ku';

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: SafeArea(
        top: false,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
          child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.darkBg,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: AppColors.gold.withValues(alpha: 0.4), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      loc?.translate('shareCard') ?? 'کارتی زیکر',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: isKurdish ? AppTheme.kurdishTitle(fontSize: 18, color: AppColors.gold) : AppTheme.englishTitle(fontSize: 18, color: AppColors.gold),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: AppColors.cream),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Scrollable decorative card preview
              Flexible(
                child: SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppColors.darkPanel, AppColors.softSurface],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.panelBorderColor),
                    ),
                    child: Column(
                      children: [
                        Text('✦ NADA • نەدا ✦', style: TextStyle(color: AppColors.gold, letterSpacing: 3, fontSize: 12)),
                        const SizedBox(height: 16),
                        Text(
                          azkar.arabic,
                          textAlign: TextAlign.center,
                          style: AppTheme.arabicTitle(fontSize: 20, color: AppColors.cream),
                          textDirection: TextDirection.rtl,
                        ),
                        const SizedBox(height: 14),
                        Divider(color: AppColors.gold.withValues(alpha: 0.2)),
                        const SizedBox(height: 10),
                        if (azkar.kurdishTranslation.isNotEmpty) ...[
                          Text(
                            azkar.kurdishTranslation,
                            textAlign: TextAlign.center,
                            style: AppTheme.kurdishText(fontSize: 14, color: AppColors.gold),
                            textDirection: TextDirection.rtl,
                          ),
                        ],
                        if (azkar.translation.isNotEmpty &&
                            azkar.translation != azkar.kurdishTranslation) ...[
                          const SizedBox(height: 8),
                          Text(
                            azkar.translation,
                            textAlign: TextAlign.center,
                            style: AppTheme.englishText(
                                fontSize: 12,
                                color: AppColors.cream.withValues(alpha: 0.85)),
                            textDirection: TextDirection.ltr,
                          ),
                        ],
                        const SizedBox(height: 14),
                        Text(
                          '— ${azkar.source}',
                          style: AppTheme.englishText(fontSize: 11, color: AppColors.mutedText),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.gold,
                    foregroundColor: AppColors.darkBg,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  icon: const Icon(Icons.share_outlined, size: 20),
                  label: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      isKurdish ? 'بڵاوکردنەوەی کارتی زیکر' : 'Share Dua Card',
                      style: isKurdish ? AppTheme.kurdishTitle(fontSize: 14, color: AppColors.darkBg) : AppTheme.englishTitle(fontSize: 14, color: AppColors.darkBg),
                    ),
                  ),
                  onPressed: () {
                    _shareDuaCard(context, lang, isKurdish);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    ),
    );
  }
}
