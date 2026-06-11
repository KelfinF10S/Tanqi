// Data bab dari API-database
class BabModel {
  final int id;
  final String nama;
  final bool locked;
  final bool isCompleted;
  final int totalAttempt;
  final int totalSoal;
  final int sudahDijawab;
  final int sisaSoal;

  BabModel({
    required this.id,
    required this.nama,
    required this.locked,
    required this.isCompleted,
    required this.totalAttempt,
    required this.totalSoal,
    required this.sudahDijawab,
    required this.sisaSoal,
  });

  factory BabModel.fromJson(Map<String, dynamic> json) => BabModel(
        id:            json['id'],
        nama:          json['nama'] ?? '',
        locked:        json['locked'] ?? false,
        isCompleted:   json['is_completed'] ?? false,
        totalAttempt:  json['total_attempt'] ?? 0,
        totalSoal:     json['total_soal'] ?? 0,
        sudahDijawab:  json['sudah_dijawab'] ?? 0,
        sisaSoal:      json['sisa_soal'] ?? 0,
      );

  double get progressPersen =>
      totalSoal == 0 ? 0 : sudahDijawab / totalSoal;
}