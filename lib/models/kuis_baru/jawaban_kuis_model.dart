// models/jawaban_kuis_model.dart

class JawabanKuisModel {
  final String message;
  final bool isCorrect;
  final dynamic jawabanBenar;
  final String? penjelasan;
  final bool kuisSelesai;
  final bool babSelesai;
  final double nilai;
  final int xpEarned;      // <-- baru: 0 kalau tidak dapat XP baru
  final int totalXp;  

  JawabanKuisModel({
    required this.message,
    required this.isCorrect,
    required this.jawabanBenar,
    this.penjelasan,
    required this.kuisSelesai,
    required this.babSelesai,
    required this.nilai,
    required this.xpEarned,
    required this.totalXp,
  });

  factory JawabanKuisModel.fromJson(Map<String, dynamic> json) =>
      JawabanKuisModel(
        message: json['message'] ?? '',
        isCorrect: json['is_correct'] ?? false,
        jawabanBenar: json['jawaban_benar'],
        penjelasan: json['penjelasan'],
        kuisSelesai: json['kuis_selesai'] ?? false,
        babSelesai: json['bab_selesai'] ?? false,
        nilai: (json['nilai'] ?? 0).toDouble(),
        xpEarned: json['xp_earned'] ?? 0,
        totalXp: json['total_xp'] ?? 0,
      );
}