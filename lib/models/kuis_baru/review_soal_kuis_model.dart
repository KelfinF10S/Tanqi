// models/review_soal_kuis_model.dart

class ReviewSoalKuisModel {
  final int id;
  final String tipe;
  final int urutan;
  final String pertanyaan;
  final Map<String, dynamic> konten;
  final dynamic jawabanBenar;
  final dynamic jawabanUser;
  final bool? isCorrect;
  final String? penjelasan;

  ReviewSoalKuisModel({
    required this.id,
    required this.tipe,
    required this.urutan,
    required this.pertanyaan,
    required this.konten,
    required this.jawabanBenar,
    this.jawabanUser,
    this.isCorrect,
    this.penjelasan,
  });

  factory ReviewSoalKuisModel.fromJson(Map<String, dynamic> json) =>
      ReviewSoalKuisModel(
        id: json['id'],
        tipe: json['tipe'],
        urutan: json['urutan'],
        pertanyaan: json['pertanyaan'],
        konten: Map<String, dynamic>.from(json['konten'] ?? {}),
        jawabanBenar: json['jawaban_benar'],
        jawabanUser: json['jawaban_user'],
        isCorrect: json['is_correct'],
        penjelasan: json['penjelasan'],
      );
}