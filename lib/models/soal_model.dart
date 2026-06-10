class SoalModel {
  final int id;
  final String pertanyaan;
  final String opsiA;
  final String opsiB;
  final String opsiC;
  final String opsiD;
  final int xpReward;
  final int babid;
  final bool sudahDijawab;

  // jawaban_benar TIDAK ada — disembunyikan oleh backend
  // validasi dilakukan di backend saat submit

  SoalModel({
    required this.id,
    required this.pertanyaan,
    required this.opsiA,
    required this.opsiB,
    required this.opsiC,
    required this.opsiD,
    required this.xpReward,
    required this.babid,
    required this.sudahDijawab,
  });

  factory SoalModel.fromJson(Map<String, dynamic> json) => SoalModel(
        id:           json['id'],
        pertanyaan:   json['pertanyaan'] ?? '',
        opsiA:        json['opsi_a'] ?? '',
        opsiB:        json['opsi_b'] ?? '',
        opsiC:        json['opsi_c'] ?? '',
        opsiD:        json['opsi_d'] ?? '',
        xpReward:     json['xp_reward'] ?? 0,
        babid:        json['babid'] ?? 0,
        sudahDijawab: json['sudah_dijawab'] ?? false,
      );

  /// Kembalikan list opsi dengan label & teks,
  /// sudah diacak (Fisher-Yates) untuk ditampilkan di UI.
  List<Map<String, String>> get opsiAcak {
    final opsi = [
      {'dbLabel': 'A', 'text': opsiA},
      {'dbLabel': 'B', 'text': opsiB},
      {'dbLabel': 'C', 'text': opsiC},
      {'dbLabel': 'D', 'text': opsiD},
    ];
    opsi.shuffle();
    const labels = ['A', 'B', 'C', 'D'];
    for (var i = 0; i < opsi.length; i++) {
      opsi[i]['displayLabel'] = labels[i];
    }
    return opsi;
  }
}