// models/topik_model.dart
import 'package:tanqiy/models/materi_model.dart';

class TopikModel {
  final int id;
  final int babid;
  final String judul;
  final int urutan;
  final List<MateriModel> materi;

  TopikModel({
    required this.id,
    required this.babid,
    required this.judul,
    required this.urutan,
    required this.materi,
  });

  factory TopikModel.fromJson(Map<String, dynamic> json) {
    return TopikModel(
      id:     json['id'],
      babid:  json['babid'],
      judul:  json['judul'],
      urutan: json['urutan'],
      materi: (json['materi'] as List<dynamic>)
          .map((e) => MateriModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}