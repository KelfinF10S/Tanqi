/// Model data untuk satu entri kata dalam kamus.
///
/// Setiap entri memiliki kata berbahasa Arab ([arab]), terjemahan/arti
/// dalam bahasa Indonesia ([arti]), dan kategori tata bahasa ([kategori])
/// yaitu salah satu dari: "Huruf", "Isim", atau "Fi'il".
class KamusEntry {
  final String arab;
  final String arti;
  final String kategori;

  const KamusEntry({
    required this.arab,
    required this.arti,
    required this.kategori,
  });

  factory KamusEntry.fromJson(Map<String, dynamic> json) {
    return KamusEntry(
      arab: json['arab'] as String,
      arti: json['arti'] as String,
      kategori: json['kategori'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'arab': arab,
        'arti': arti,
        'kategori': kategori,
      };
}

/// Daftar kategori tata bahasa yang tersedia pada kamus, digunakan untuk
/// membangun filter/chip pada halaman kamus.
class KamusKategori {
  static const String semua = 'Semua';
  static const String huruf = 'Huruf';
  static const String isim = 'Isim';
  static const String fiil = "Fi'il";

  static const List<String> semuaKategori = [semua, huruf, isim, fiil];
}
