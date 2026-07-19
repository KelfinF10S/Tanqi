// models/kuis_meta_model.dart

class KuisMetaModel {
  final int id;
  final int babid;
  final String judul;
  final double passingScore;
  final int xpPerSoal;
  final int totalSoal;
  final int sudahDijawab;
  final int attempt;
  final bool isCompleted;
  final double nilai;

  KuisMetaModel({
    required this.id,
    required this.babid,
    required this.judul,
    required this.passingScore,
    required this.xpPerSoal,
    required this.totalSoal,
    required this.sudahDijawab,
    required this.attempt,
    required this.isCompleted,
    required this.nilai,
  });

  factory KuisMetaModel.fromJson(Map<String, dynamic> json) => KuisMetaModel(
    id: json['id'],
    babid: json['babid'],
    judul: json['judul'] ?? 'Kuis',
    passingScore: (json['passing_score'] ?? 70).toDouble(),
    xpPerSoal: json['xp_per_soal'] ?? 0,
    totalSoal: json['total_soal'] ?? 0,
    sudahDijawab: json['sudah_dijawab'] ?? 0,
    attempt: json['attempt'] ?? 1,
    isCompleted: json['is_completed'] ?? false,
    nilai: (json['nilai'] ?? 0).toDouble(),
  );
}
