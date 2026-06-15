class JawabanModel {
  final String message;
  final bool isCorrect;
  final String jawabanBenar;
  final int xpDidapat;
  final bool materiSelesai;
  final bool babSelesai;
  final double nilai;
  final String? penjelasan; // ← tambah ini

  JawabanModel({
    required this.message,
    required this.isCorrect,
    required this.jawabanBenar,
    required this.xpDidapat,
    required this.materiSelesai,
    required this.babSelesai,
    required this.nilai,
    this.penjelasan,
  });

  factory JawabanModel.fromJson(Map<String, dynamic> json) => JawabanModel(
    message:       json['message']       ?? '',
    isCorrect:     json['is_correct']    ?? false,
    jawabanBenar:  json['jawaban_benar'] ?? '',
    xpDidapat:     json['xp_didapat']    ?? 0,
    materiSelesai: json['materi_selesai'] ?? false,
    babSelesai:    json['bab_selesai']   ?? false,
    nilai:         (json['nilai']        ?? 0).toDouble(),
    penjelasan:    json['penjelasan'],   // ← tambah ini
  );
}