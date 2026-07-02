/// Konfigurasi tiap level: ukuran grid dan durasi preview (lihat kartu di awal).
class LevelConfig {
  final int level;
  final int rows;
  final int columns;
  final double previewSeconds;

  const LevelConfig({
    required this.level,
    required this.rows,
    required this.columns,
    required this.previewSeconds,
  });

  int get totalCards => rows * columns;
  int get totalPairs => totalCards ~/ 2;
}

/// Daftar level: makin tinggi level, grid makin besar & waktu preview makin
/// lama (supaya tetap adil karena jumlah kartu yang harus dihafal lebih banyak).
const List<LevelConfig> kLevels = [
  LevelConfig(level: 1, rows: 2, columns: 3, previewSeconds: 3), // 3 pasang
  LevelConfig(level: 2, rows: 3, columns: 4, previewSeconds: 4), // 6 pasang
  LevelConfig(level: 3, rows: 4, columns: 4, previewSeconds: 5), // 8 pasang
  LevelConfig(level: 4, rows: 4, columns: 5, previewSeconds: 6), // 10 pasang
  LevelConfig(level: 5, rows: 5, columns: 6, previewSeconds: 7), // 15 pasang
];

/// Kumpulan emoji sebagai "gambar" kartu (biar tidak perlu asset gambar).
/// Harus memuat minimal sebanyak jumlah pasang terbanyak (level 5 = 15 pasang).
const List<String> kCardEmojis = [
  '🐪', '🦉', '🪈', '🪘', '📿', '🌵',
  '🏺', '⭐', '🌙', '🪐', '🐸', '🌍',
  '☕', '🔥', '⚡', '📜', '🏹', '🔭',
];
