class MateriModel {
  final int id;
  final int babid;
  final String judul;
  final int urutan;
  final bool isCompleted;
  final int xpDidapat;
  final int attempt;
  final int totalSoal;
  final int sudahDijawab;
  final int sisaSoal;

  MateriModel({
    required this.id,
    required this.babid,
    required this.judul,
    required this.urutan,
    required this.isCompleted,
    required this.xpDidapat,
    required this.attempt,
    required this.totalSoal,
    required this.sudahDijawab,
    required this.sisaSoal,
  });

  factory MateriModel.fromJson(Map<String, dynamic> json) => MateriModel(
    id:           json['id'],
    babid:        json['babid'] ?? 0,
    judul:        json['judul'] ?? '',
    urutan:       json['urutan'] ?? 0,
    isCompleted:  json['is_completed'] == true || json['is_completed'] == 1,
    xpDidapat:    json['xp_didapat'] ?? 0,
    attempt:      json['attempt'] ?? 0,
    totalSoal:    json['total_soal'] ?? 0,
    sudahDijawab: json['sudah_dijawab'] ?? 0,
    sisaSoal:     json['sisa_soal'] ?? 0,
  );

  double get progressPersen => totalSoal == 0 ? 0 : sudahDijawab / totalSoal;
}