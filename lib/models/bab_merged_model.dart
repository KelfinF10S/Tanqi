import 'package:tanqiy/models/materibab_model.dart';

import 'bab_model.dart';

// ──────────────────────────────────────────────────────────────────────────────
// BabMerged
// Gabungan data bab dari 2 sumber:
//   - MateriBAB  → JSON lokal (materi, judul, stimulus, kategori kata)
//   - BabModel   → API/DB    (progress, locked, soal, xp)
//
// Penggabungan dilakukan via id: MateriBAB.id (String) == BabModel.id.toString()
// ──────────────────────────────────────────────────────────────────────────────

class BabMerged {
  final MateriBAB materi;
  final BabModel? quiz;

  BabMerged({required this.materi, this.quiz});

  String get id          => materi.id;
  String get judulArab   => materi.judulArab;
  String get judulLatin  => materi.judulLatin;
  String get aplikasi    => materi.aplikasi;

  bool   get locked        => quiz?.locked       ?? true;
  bool   get isCompleted   => quiz?.isCompleted  ?? false;
  double get nilai         => quiz?.nilai         ?? 0.0; 
  int    get totalSoal     => quiz?.totalSoal    ?? 0;
  int    get sudahDijawab  => quiz?.sudahDijawab ?? 0;
  int    get sisaSoal      => quiz?.sisaSoal     ?? 0;
  double get progressPersen => quiz?.progressPersen ?? 0.0;

  bool get hasQuiz => quiz != null;
}