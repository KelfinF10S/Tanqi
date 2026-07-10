class StimulusData {
  final String ayatArab;
  final String terjemah;
  final String sumber;
  final String narasi;

  StimulusData({
    required this.ayatArab,
    required this.terjemah,
    required this.sumber,
    required this.narasi,
  });

  factory StimulusData.fromJson(Map<String, dynamic> j) => StimulusData(
        ayatArab: j['ayat_arab'] ?? '',
        terjemah: j['terjemah'] ?? '',
        sumber: j['sumber'] ?? '',
        narasi: j['narasi'] ?? '',
      );
}