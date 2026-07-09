/// Definisi umum di level root bab (dipakai BAB 2 & BAB 3, mis. definisi
/// i'rab atau definisi jumlah). Null di [MateriBAB.definisi] untuk bab yang
/// tidak punya definisi umum di root (mis. BAB 1).
class DefinisiData {
  final String arab;
  final String latin;
  final String? sumber;

  DefinisiData({
    required this.arab,
    required this.latin,
    this.sumber,
  });

  factory DefinisiData.fromJson(Map<String, dynamic> j) => DefinisiData(
        arab: j['arab'] ?? '',
        latin: j['latin'] ?? '',
        sumber: j['sumber'],
      );

  Map<String, dynamic> toJson() => {
        'arab': arab,
        'latin': latin,
        if (sumber != null) 'sumber': sumber,
      };
}
