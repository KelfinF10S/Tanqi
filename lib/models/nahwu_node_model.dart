/// Satu contoh ayat/kalimat, dipakai baik sebagai `contoh_stimulus` (single)
/// maupun sebagai elemen `contoh[]` di dalam [Aturan].
class ContohItem {
  final String arab;
  final String? sumber;
  final String? terjemah;
  final String? kategoriArab;
  final String? kategoriLatin;
  final String? analisisArab;
  final String? analisisLatin;

  ContohItem({
    required this.arab,
    this.sumber,
    this.terjemah,
    this.kategoriArab,
    this.kategoriLatin,
    this.analisisArab,
    this.analisisLatin,
  });

  factory ContohItem.fromJson(Map<String, dynamic> j) => ContohItem(
        arab: j['arab'] ?? '',
        sumber: j['sumber'],
        terjemah: j['terjemah'],
        kategoriArab: j['kategori_arab'],
        kategoriLatin: j['kategori_latin'],
        analisisArab: j['analisis_arab'],
        analisisLatin: j['analisis_latin'],
      );

  Map<String, dynamic> toJson() => {
        'arab': arab,
        if (sumber != null) 'sumber': sumber,
        if (terjemah != null) 'terjemah': terjemah,
        if (kategoriArab != null) 'kategori_arab': kategoriArab,
        if (kategoriLatin != null) 'kategori_latin': kategoriLatin,
        if (analisisArab != null) 'analisis_arab': analisisArab,
        if (analisisLatin != null) 'analisis_latin': analisisLatin,
      };
}

/// Satu "tanda" / kategori aturan nahwu (mis. tanda rafa', huruf jar,
/// huruf 'athaf), lengkap dengan daftar contohnya.
class Aturan {
  final String? labelArab;
  final String? labelLatin;
  final String? keteranganArab;
  final String? keteranganLatin;
  final List<ContohItem> contoh;

  Aturan({
    this.labelArab,
    this.labelLatin,
    this.keteranganArab,
    this.keteranganLatin,
    this.contoh = const [],
  });

  factory Aturan.fromJson(Map<String, dynamic> j) => Aturan(
        labelArab: j['label_arab'],
        labelLatin: j['label_latin'],
        keteranganArab: j['keterangan_arab'],
        keteranganLatin: j['keterangan_latin'],
        contoh: (j['contoh'] as List<dynamic>? ?? [])
            .map((e) => ContohItem.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        if (labelArab != null) 'label_arab': labelArab,
        if (labelLatin != null) 'label_latin': labelLatin,
        if (keteranganArab != null) 'keterangan_arab': keteranganArab,
        if (keteranganLatin != null) 'keterangan_latin': keteranganLatin,
        'contoh': contoh.map((e) => e.toJson()).toList(),
      };
}

/// Baris tabel perbandingan (dipakai mis. untuk tabel bina majhul: madhi vs
/// mudhari'). `kolom` bersifat bebas key-nya agar fleksibel per konteks.
class TabelItem {
  final String? labelArab;
  final String? labelLatin;
  final Map<String, String> kolom;

  TabelItem({this.labelArab, this.labelLatin, this.kolom = const {}});

  factory TabelItem.fromJson(Map<String, dynamic> j) => TabelItem(
        labelArab: j['label_arab'],
        labelLatin: j['label_latin'],
        kolom: Map<String, String>.from(j['kolom'] ?? {}),
      );

  Map<String, dynamic> toJson() => {
        if (labelArab != null) 'label_arab': labelArab,
        if (labelLatin != null) 'label_latin': labelLatin,
        'kolom': kolom,
      };
}

/// Node rekursif universal untuk semua materi nahwu (fi'il, isim, i'rab,
/// jumlah ismiyyah, dst). Satu bentuk ini menampung seluruh bab 1-3 (dan
/// bab-bab berikutnya) tanpa perlu model terpisah per topik.
///
/// Aturan render di UI:
/// - `hasAturan`  -> render sebagai daftar kartu tanda/aturan + contoh
/// - `hasTabel`   -> render sebagai tabel perbandingan
/// - `hasChildren`-> render sebagai accordion/expansion ke sub-materi
class NahwuNode {
  final String id;
  final int? nomor;
  final String judulArab;
  final String judulLatin;
  final String? definisiArab;
  final String? definisiLatin;
  final String? introArab;
  final String? introLatin;
  final ContohItem? contohStimulus;
  final List<Aturan> aturan;
  final List<TabelItem> tabel;
  final List<NahwuNode> children;

  NahwuNode({
    required this.id,
    this.nomor,
    required this.judulArab,
    required this.judulLatin,
    this.definisiArab,
    this.definisiLatin,
    this.introArab,
    this.introLatin,
    this.contohStimulus,
    this.aturan = const [],
    this.tabel = const [],
    this.children = const [],
  });

  factory NahwuNode.fromJson(Map<String, dynamic> j) => NahwuNode(
        id: j['id'] ?? '',
        nomor: j['nomor'],
        judulArab: j['judul_arab'] ?? '',
        judulLatin: j['judul_latin'] ?? '',
        definisiArab: j['definisi_arab'],
        definisiLatin: j['definisi_latin'],
        introArab: j['intro_arab'],
        introLatin: j['intro_latin'],
        contohStimulus: j['contoh_stimulus'] != null
            ? ContohItem.fromJson(j['contoh_stimulus'] as Map<String, dynamic>)
            : null,
        aturan: (j['aturan'] as List<dynamic>? ?? [])
            .map((e) => Aturan.fromJson(e as Map<String, dynamic>))
            .toList(),
        tabel: (j['tabel'] as List<dynamic>? ?? [])
            .map((e) => TabelItem.fromJson(e as Map<String, dynamic>))
            .toList(),
        children: (j['children'] as List<dynamic>? ?? [])
            .map((e) => NahwuNode.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        if (nomor != null) 'nomor': nomor,
        'judul_arab': judulArab,
        'judul_latin': judulLatin,
        if (definisiArab != null) 'definisi_arab': definisiArab,
        if (definisiLatin != null) 'definisi_latin': definisiLatin,
        if (introArab != null) 'intro_arab': introArab,
        if (introLatin != null) 'intro_latin': introLatin,
        if (contohStimulus != null) 'contoh_stimulus': contohStimulus!.toJson(),
        if (aturan.isNotEmpty) 'aturan': aturan.map((e) => e.toJson()).toList(),
        if (tabel.isNotEmpty) 'tabel': tabel.map((e) => e.toJson()).toList(),
        if (children.isNotEmpty)
          'children': children.map((e) => e.toJson()).toList(),
      };

  bool get hasAturan => aturan.isNotEmpty;
  bool get hasTabel => tabel.isNotEmpty;
  bool get hasChildren => children.isNotEmpty;

  /// Cari node dengan [id] tertentu di dalam subtree ini (termasuk diri
  /// sendiri), secara depth-first. Berguna karena struktur sekarang
  /// rekursif — mis. mencari node "fiil_madhi" langsung dari root bab
  /// tanpa tahu berapa level dalamnya.
  NahwuNode? findById(String targetId) {
    if (id == targetId) return this;
    for (final child in children) {
      final found = child.findById(targetId);
      if (found != null) return found;
    }
    return null;
  }

  /// Ratakan subtree ini (termasuk diri sendiri) menjadi List<NahwuNode>,
  /// depth-first. Berguna untuk indexing/search di seluruh materi.
  List<NahwuNode> flatten() {
    return [this, for (final child in children) ...child.flatten()];
  }
}
