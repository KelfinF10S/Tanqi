import 'package:tanqiy/models/definisi_data_model.dart';
import 'package:tanqiy/models/nahwu_node_model.dart';   // ganti dari kategori_kata_model.dart
import 'package:tanqiy/models/stimulus_data_model.dart';

class MateriBAB {
  final String id;
  final String judulArab;
  final String judulLatin;
  final String aplikasi;
  final StimulusData? stimulus;
  final DefinisiData? definisi;
  final List<NahwuNode> bab;   // <-- ini yang harus diganti dari List<KategoriKata>

  MateriBAB({
    required this.id,
    required this.judulArab,
    required this.judulLatin,
    required this.aplikasi,
    this.stimulus,
    this.definisi,
    this.bab = const [],
  });

  factory MateriBAB.fromJson(Map<String, dynamic> j) => MateriBAB(
        id: j['id'] ?? '',
        judulArab: j['judul'] ?? '',
        judulLatin: j['judul_latin'] ?? '',
        aplikasi: j['aplikasi'] ?? '',
        stimulus: j['stimulus'] != null
            ? StimulusData.fromJson(j['stimulus'] as Map<String, dynamic>)
            : null,
        definisi: j['definisi'] != null
            ? DefinisiData.fromJson(j['definisi'] as Map<String, dynamic>)
            : null,
        bab: (j['bab'] as List<dynamic>? ?? [])
            .map((e) => NahwuNode.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}