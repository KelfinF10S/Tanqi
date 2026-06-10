class JawabanModel {
  final String message;
  final bool isCorrect;
  final String jawabanBenar;
  final int xpDidapat;
  final bool dapatXp;

  JawabanModel({
    required this.message,
    required this.isCorrect,
    required this.jawabanBenar,
    required this.xpDidapat,
    required this.dapatXp,
  });

  factory JawabanModel.fromJson(Map<String, dynamic> json) =>
      JawabanModel(
        message:      json['message'] ?? '',
        isCorrect:    json['is_correct'] ?? false,
        jawabanBenar: json['jawaban_benar'] ?? '',
        xpDidapat:    json['xp_didapat'] ?? 0,
        dapatXp:      json['dapat_xp'] ?? true,
      );
}