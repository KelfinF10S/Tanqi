import 'dart:ui';

import 'package:tanqiy/core/colors.dart';

class KategoriKata {
  final String id, judulArab, judulLatin, definisiArab, definisiLatin;
  final int nomor;
  final List<dynamic> subBab;
  final List<dynamic> tandaUmum;

  KategoriKata({
    required this.id,      required this.nomor,
    required this.judulArab, required this.judulLatin,
    required this.definisiArab, required this.definisiLatin,
    required this.subBab,  required this.tandaUmum,
  });

  factory KategoriKata.fromJson(Map<String, dynamic> j) => KategoriKata(
        id:            j['id'],
        nomor:         j['nomor'],
        judulArab:     j['judul_arab'],
        judulLatin:    j['judul_latin'],
        definisiArab:  j['definisi_arab'],
        definisiLatin: j['definisi_latin'],
        subBab:        j['sub_bab']    ?? [],
        tandaUmum:     j['tanda_umum'] ?? [],
      );

  Color get accentColor {
    switch (id) {
      case 'fiil':  return AppColors.gold;
      case 'isim':  return AppColors.emerald;
      case 'harf':  return AppColors.sky;
      default:      return AppColors.gold;
    }
  }

  String get iconLabel {
    switch (id) {
      case 'fiil':  return 'ف';
      case 'isim':  return 'ا';
      case 'harf':  return 'ح';
      default:      return '؟';
    }
  }
}