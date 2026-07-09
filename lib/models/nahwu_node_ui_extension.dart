import 'package:characters/characters.dart';
import 'package:flutter/material.dart';
import 'package:tanqiy/models/nahwu_node_model.dart';

/// Properti dekoratif untuk NahwuNode di level bab (fiil, isim, harf, dst).
/// Dipisah dari model data murni supaya NahwuNode tetap generik untuk semua
/// level (bab, sub-bab, aturan) — warna/ikon hanya relevan di level teratas.
extension NahwuNodeUi on NahwuNode {
  static const List<Color> _palette = [
    Color(0xFF4F86F7), // biru
    Color(0xFF34B37E), // hijau
    Color(0xFFE0863F), // oranye
    Color(0xFF9B6BD8), // ungu
    Color(0xFFE0576B), // merah muda
  ];

  /// Warna aksen stabil per node, ditentukan dari hash id (bukan index),
  /// supaya warnanya konsisten walau urutan list berubah.
  Color get accentColor => _palette[id.hashCode.abs() % _palette.length];

  /// Label ikon singkat untuk tab picker — huruf Arab pertama dari judul.
  String get iconLabel {
    final trimmed = judulArab.trim();
    return trimmed.isEmpty ? '?' : trimmed.characters.first;
  }
}