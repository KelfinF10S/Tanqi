class SoalModel {
  final int id;
  final int babid;
  final int materiid;       // ← baru
  final String pertanyaan;
  final String opsiA;
  final String opsiB;
  final String opsiC;
  final String opsiD;
  final int xpReward;
  final bool sudahDijawab;
  final String? penjelasan; // ← baru, nullable

  SoalModel({
    required this.id,
    required this.babid,
    required this.materiid,
    required this.pertanyaan,
    required this.opsiA,
    required this.opsiB,
    required this.opsiC,
    required this.opsiD,
    required this.xpReward,
    required this.sudahDijawab,
    this.penjelasan,
  });

  factory SoalModel.fromJson(Map<String, dynamic> json) => SoalModel(
    id:           json['id'],
    babid:        json['babid'] ?? 0,
    materiid:     json['materiid'] ?? 0,
    pertanyaan:   json['pertanyaan'] ?? '',
    opsiA:        json['pilihan_a'] ?? '',
    opsiB:        json['pilihan_b'] ?? '',
    opsiC:        json['pilihan_c'] ?? '',
    opsiD:        json['pilihan_d'] ?? '',
    xpReward:     json['xp_reward'] ?? 0,
    sudahDijawab: json['sudah_dijawab'] ?? false,
    penjelasan:   json['penjelasan'],
  );

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