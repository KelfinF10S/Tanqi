// models/soal_kuis_model.dart

class SoalKuisModel {
  final int id;
  final int kuisid;
  final String tipe; // 'multiple_choice' | 'drag_drop' | 'tap_object'
  final int urutan;
  final String pertanyaan;
  final Map<String, dynamic> konten;
  final String? penjelasan;
  final dynamic jawabanBenar; // hanya terisi saat review, null saat soal_aktif

  SoalKuisModel({
    required this.id,
    required this.kuisid,
    required this.tipe,
    required this.urutan,
    required this.pertanyaan,
    required this.konten,
    this.penjelasan,
    this.jawabanBenar,
  });

  factory SoalKuisModel.fromJson(Map<String, dynamic> json) => SoalKuisModel(
        id: json['id'],
        kuisid: json['kuisid'],
        tipe: json['tipe'],
        urutan: json['urutan'],
        pertanyaan: json['pertanyaan'],
        konten: Map<String, dynamic>.from(json['konten'] ?? {}),
        penjelasan: json['penjelasan'],
        jawabanBenar: json['jawaban_benar'],
      );
}