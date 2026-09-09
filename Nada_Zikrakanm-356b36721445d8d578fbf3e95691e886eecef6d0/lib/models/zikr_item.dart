import 'package:flutter/material.dart';

class ZikrItem {
  final String id;
  final String titleEn;
  final String titleKu;
  final String titleAr;
  final int target;

  const ZikrItem({
    required this.id,
    required this.titleEn,
    required this.titleKu,
    required this.titleAr,
    this.target = 33,
  });

  String title(Locale locale) {
    switch (locale.languageCode) {
      case 'ar':
        return titleAr;
      case 'ku':
        return titleKu;
      default:
        return titleEn;
    }
  }
}
