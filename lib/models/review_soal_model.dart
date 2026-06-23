class ReviewSoalModel {
  final int id;
  final String pertanyaan;
  final String opsiA;
  final String opsiB;
  final String opsiC;
  final String opsiD;
  final String jawabanBenar;
  final String? jawabanUser;
  final bool? isCorrect;
  final String? penjelasan; // hanya muncul kalau jawaban benar

  ReviewSoalModel({
    required this.id,
    required this.pertanyaan,
    required this.opsiA,
    required this.opsiB,
    required this.opsiC,
    required this.opsiD,
    required this.jawabanBenar,
    this.jawabanUser,
    this.isCorrect,
    this.penjelasan,
  });

  factory ReviewSoalModel.fromJson(Map<String, dynamic> json) => ReviewSoalModel(
    id:           json['id'],
    pertanyaan:   json['pertanyaan'] ?? '',
    opsiA:        json['pilihan_a'] ?? '',
    opsiB:        json['pilihan_b'] ?? '',
    opsiC:        json['pilihan_c'] ?? '',
    opsiD:        json['pilihan_d'] ?? '',
    jawabanBenar: json['jawaban_benar'] ?? '',
    jawabanUser:  json['jawaban_user'],
    isCorrect:    json['is_correct'],
    penjelasan:   json['penjelasan'],
  );
}