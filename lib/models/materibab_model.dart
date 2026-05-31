import 'package:tanqiy/models/kategori_kata_model.dart';
import 'package:tanqiy/models/stimulus_data_model.dart';

class MateriBAB {
  final String id;
  final String judulArab;
  final String judulLatin;
  final String aplikasi;
  final StimulusData stimulus;
  final List<KategoriKata> bab;

  MateriBAB({
    required this.id,
    required this.judulArab,
    required this.judulLatin,
    required this.aplikasi,
    required this.stimulus,
    required this.bab,
  });
  
  factory MateriBAB.fromJson(Map<String, dynamic> j) => MateriBAB(
        id:         j['id'],
        judulArab:  j['judul'],
        judulLatin: j['judul_latin'],
        aplikasi:   j['aplikasi'],
        stimulus:   StimulusData.fromJson(j['stimulus']),
        bab:        (j['bab'] as List).map((e) => KategoriKata.fromJson(e)).toList(),
      );
}