class BabModel {
  final int id;
  final String nama;
  final bool locked;
  final bool isCompleted;
  final int totalSoal;
  final int sudahDijawab;
  final int sisaSoal;

  BabModel({
    required this.id,
    required this.nama,
    required this.locked,
    required this.isCompleted,
    required this.totalSoal,
    required this.sudahDijawab,
    required this.sisaSoal,
  });

  factory BabModel.fromJson(Map<String, dynamic> json) => BabModel(
    id:          json['id'],
    nama:        json['judul'] ?? '',
    locked:      json['locked'] == true || json['locked'] == 1,
    isCompleted: json['is_completed'] == true || json['is_completed'] == 1,
    totalSoal:   json['total_soal'] ?? 0,
    sudahDijawab: json['sudah_dijawab'] ?? 0,
    sisaSoal:    json['sisa_soal'] ?? 0,
  );

  double get progressPersen => totalSoal == 0 ? 0 : sudahDijawab / totalSoal;
}