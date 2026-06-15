import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:tanqiy/core/const.dart';
import 'package:tanqiy/data/auth_local.dart';
import 'package:tanqiy/models/bab_merged_model.dart';
import 'package:tanqiy/models/bab_model.dart';
import 'package:tanqiy/models/materibab_model.dart';
import 'package:tanqiy/models/materi_model.dart';
import 'package:tanqiy/models/soal_model.dart';
import 'package:tanqiy/models/jawaban_model.dart';
import 'package:tanqiy/models/review_soal_model.dart';
import 'package:tanqiy/models/topik_model.dart';

final String _baseUrl = AppConst.baseUrl;

// ──────────────────────────────────────────────────────────────────────────────
// BabController
// ──────────────────────────────────────────────────────────────────────────────
class BabController extends GetxController {
  final babList = <BabMerged>[].obs;
  final slugToMateriId = <String, int>{}.obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchBab();
  }

  Future<Map<String, String>> _headers() async {
    final token = await AuthStorage.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Future<List<MateriBAB>> _loadMateriLokal() async {
    final raw = await rootBundle.loadString('lib/assets/materi_bab.json');
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => MateriBAB.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> fetchBab() async {
    try {
      isLoading.value = true;

      final materiList = await _loadMateriLokal();

      List<BabModel> quizList = [];
      try {
        quizList = await _fetchBabFromApi();
      } catch (e) {
        debugPrint('[BabController] API gagal (lanjut tanpa quiz): $e');
      }

      final quizMap = {for (final b in quizList) b.id.toString(): b};

      babList.value = materiList
          .map((m) => BabMerged(materi: m, quiz: quizMap[m.id]))
          .toList();
    } catch (e) {
      errorMessage.value = 'Gagal memuat bab: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<List<BabModel>> _fetchBabFromApi() async {
    final res = await http.get(
      Uri.parse('$_baseUrl/api/bab/'),
      headers: await _headers(),
    );
    if (res.statusCode != 200) throw Exception('API error ${res.statusCode}');
    final body = jsonDecode(res.body);
    final list = body['data'] as List<dynamic>;
    return list
        .map((e) => BabModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // Reset per materi (bukan per bab)
  Future<void> resetMateri(int materiId) async {
    try {
      isLoading.value = true;
      final res = await http.delete(
        Uri.parse('$_baseUrl/api/jawaban/reset/$materiId'),
        headers: await _headers(),
      );
      final body = jsonDecode(res.body);
      if (res.statusCode == 200) {
        await fetchBab();
        Get.snackbar(
          'Berhasil',
          body['message'],
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar(
          'Gagal',
          body['message'] ?? 'Terjadi kesalahan',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal reset materi: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadSlugMap(int babId) async {
    try {
      final res = await http.get(
        Uri.parse('$_baseUrl/api/bab/$babId/topik'),
        headers: await _headers(),
      );
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        final topikList = body['topik'] as List<dynamic>;
        final map = <String, int>{};
        for (final t in topikList) {
          for (final m in t['materi'] as List<dynamic>) {
            map[m['judul'] as String] = m['id'] as int;
          }
        }
        slugToMateriId.value = map;
      }
    } catch (e) {
      debugPrint('[BabController] loadSlugMap gagal: $e');
    }
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// TopikController — list topik + materi dalam satu bab
// ──────────────────────────────────────────────────────────────────────────────
class TopikController extends GetxController {
  final topikList = <TopikModel>[].obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  Future<Map<String, String>> _headers() async {
    final token = await AuthStorage.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Future<void> loadTopik(int babId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final res = await http.get(
        Uri.parse('$_baseUrl/api/bab/$babId/topik'),
        headers: await _headers(),
      );
      if (res.statusCode != 200) throw Exception('API error ${res.statusCode}');

      final body = jsonDecode(res.body);
      final list = body['topik'] as List<dynamic>;
      topikList.value = list
          .map((e) => TopikModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      errorMessage.value = 'Gagal memuat topik: $e';
    } finally {
      isLoading.value = false;
    }
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// MateriController — list materi dalam satu bab
// ──────────────────────────────────────────────────────────────────────────────
class MateriController extends GetxController {
  final materiList = <MateriModel>[].obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  Future<Map<String, String>> _headers() async {
    final token = await AuthStorage.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Future<void> loadMateri(int babId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final res = await http.get(
        Uri.parse('$_baseUrl/api/bab/$babId/materi'),
        headers: await _headers(),
      );
      if (res.statusCode != 200) throw Exception('API error ${res.statusCode}');

      final body = jsonDecode(res.body);
      final list = body['materi'] as List<dynamic>;
      materiList.value = list
          .map((e) => MateriModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      errorMessage.value = 'Gagal memuat materi: $e';
    } finally {
      isLoading.value = false;
    }
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// QuizController — soal dalam satu materi
// ──────────────────────────────────────────────────────────────────────────────
// babkuis_controller.dart — ganti class QuizController

class QuizController extends GetxController {
  final soalList = <SoalModel>[].obs;
  final isLoading = false.obs;
  final isSubmitting = false.obs;
  final errorMessage = ''.obs;

  final currentIndex = 0.obs;
  final opsiPerSoal = <int, List<Map<String, String>>>{}.obs; // acak per soal
  final selectedPerSoal = <int, String>{}.obs; // dbLabel yg dipilih per soal
  final hasilPerSoal = <int, JawabanModel>{}.obs; // hasil submit per soal

  // State global
  final quizSelesai = false.obs; // semua soal sudah dijawab & di-submit
  final materiSelesai = false.obs;
  final babSelesai = false.obs;
  final nilaiAkhir = 0.0.obs;
  final totalXp = 0.obs;
  final showReview = false.obs;

  bool get isLastSoal => currentIndex.value == soalList.length - 1;
  bool get isFirstSoal => currentIndex.value == 0;

  SoalModel? get soalAktif =>
      soalList.isNotEmpty ? soalList[currentIndex.value] : null;

  String get selectedLabel => selectedPerSoal[currentIndex.value] ?? '';

  JawabanModel? get hasilAktif => hasilPerSoal[currentIndex.value];

  // Status soal aktif: 'idle' | 'selected' | 'answered'
  String get statusAktif {
    if (hasilPerSoal.containsKey(currentIndex.value)) return 'answered';
    if (selectedPerSoal.containsKey(currentIndex.value)) return 'selected';
    return 'idle';
  }

  Future<Map<String, String>> _headers() async {
    final token = await AuthStorage.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  // Di QuizController — ganti method loadSoal & tambah _restoreFromReview

  Future<void> loadSoal(int materiId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Reset state
      currentIndex.value = 0;
      soalList.clear();
      opsiPerSoal.clear();
      selectedPerSoal.clear();
      hasilPerSoal.clear();
      quizSelesai.value = false;
      showReview.value = false;
      materiSelesai.value = false;
      babSelesai.value = false;
      nilaiAkhir.value = 0.0;
      totalXp.value = 0;

      // 1️⃣ Coba review endpoint dulu
      final reviewRes = await http.get(
        Uri.parse('$_baseUrl/api/bab/materi/$materiId/review'),
        headers: await _headers(),
      );

      if (reviewRes.statusCode == 200) {
        // Materi sudah selesai — restore dari review
        await _restoreFromReview(materiId, reviewRes);
        return;
      }

      // 2️⃣ Belum selesai — load soal biasa
      final res = await http.get(
        Uri.parse('$_baseUrl/api/bab/materi/$materiId/soal'),
        headers: await _headers(),
      );
      if (res.statusCode != 200) throw Exception('API error ${res.statusCode}');

      final body = jsonDecode(res.body);
      final list = body['soal'] as List<dynamic>;
      soalList.value = list
          .map((e) => SoalModel.fromJson(e as Map<String, dynamic>))
          .toList();

      for (int i = 0; i < soalList.length; i++) {
        opsiPerSoal[i] = soalList[i].opsiAcak;
      }
      opsiPerSoal.refresh();
    } catch (e) {
      errorMessage.value = 'Gagal memuat soal: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _restoreFromReview(int materiId, http.Response reviewRes) async {
    final body = jsonDecode(reviewRes.body);
    final reviewList = body['soal'] as List<dynamic>;

    // Rebuild soalList dari data review (field sama dengan SoalModel)
    soalList.value = reviewList
        .map((e) => SoalModel.fromJson(e as Map<String, dynamic>))
        .toList();

    // Rebuild opsi — karena sudah selesai, urutan tidak perlu diacak lagi
    // Tampilkan opsi as-is dari soal
    for (int i = 0; i < soalList.length; i++) {
      opsiPerSoal[i] = soalList[i].opsiAcak; // seed acak tetap dari model
    }
    opsiPerSoal.refresh();

    // Restore jawaban & hasil per soal
    int xpTotal = 0;
    for (int i = 0; i < reviewList.length; i++) {
      final r = reviewList[i] as Map<String, dynamic>;
      final jawabanUser = r['jawaban_user'] as String?;
      final jawabanBenar = r['jawaban_benar'] as String? ?? '';
      final isCorrect = r['is_correct'] as bool? ?? false;
      final penjelasan = r['penjelasan'] as String?; // null kalau salah

      if (jawabanUser != null) {
        selectedPerSoal[i] = jawabanUser;

        // Rekonstruksi JawabanModel dari data review
        // XP tidak diketahui per-soal dari review, set 0 (sudah diterima sebelumnya)
        hasilPerSoal[i] = JawabanModel(
          message: '',
          isCorrect: isCorrect,
          jawabanBenar: jawabanBenar,
          xpDidapat: 0,
          materiSelesai: true,
          babSelesai: false, // tidak diketahui dari review, aman di-false
          nilai:
              (body['materi'] as Map<String, dynamic>?)?['nilai']?.toDouble() ??
              0.0,
          penjelasan:
              penjelasan, // ← tambah field ini ke JawabanModel (lihat bawah)
        );

        if (isCorrect)
          xpTotal++; // placeholder, XP asli sudah dicatat di server
      }
    }

    selectedPerSoal.refresh();
    hasilPerSoal.refresh();

    totalXp.value = xpTotal;
    quizSelesai.value = true;
    materiSelesai.value = true;
    showReview.value = false; // user tetap harus tekan tombol review
  }

  void pilihJawaban(String dbLabel) {
    // Tidak bisa ubah jawaban yang sudah di-submit
    if (hasilPerSoal.containsKey(currentIndex.value)) return;
    selectedPerSoal[currentIndex.value] = dbLabel;
    selectedPerSoal.refresh();
  }

  Future<void> submitJawaban() async {
    final idx = currentIndex.value;
    if (selectedPerSoal[idx] == null || isSubmitting.value) return;
    if (hasilPerSoal.containsKey(idx)) return; // sudah disubmit

    try {
      isSubmitting.value = true;

      final res = await http.post(
        Uri.parse('$_baseUrl/api/jawaban/'),
        headers: await _headers(),
        body: jsonEncode({
          'soal_id': soalList[idx].id,
          'jawaban': selectedPerSoal[idx],
        }),
      );
      final body = jsonDecode(res.body);

      if (res.statusCode == 409) {
        // Sudah pernah dijawab — anggap selesai tanpa data baru
        hasilPerSoal[idx] = JawabanModel.fromJson({
          ...body,
          'materi_selesai': false,
          'bab_selesai': false,
          'nilai': 0.0,
          'xp_didapat': 0,
        });
      } else {
        hasilPerSoal[idx] = JawabanModel.fromJson(body);
      }
      hasilPerSoal.refresh();

      // Akumulasi XP
      totalXp.value += hasilPerSoal[idx]!.xpDidapat;

      // Cek apakah semua soal sudah dijawab
      if (hasilPerSoal.length == soalList.length) {
        quizSelesai.value = true;
        // Ambil flag dari soal terakhir yg punya materiSelesai = true
        final lastHasil = hasilPerSoal.values.firstWhere(
          (h) => h.materiSelesai,
          orElse: () => hasilPerSoal[idx]!,
        );
        materiSelesai.value = lastHasil.materiSelesai;
        babSelesai.value = lastHasil.babSelesai;
        nilaiAkhir.value = lastHasil.nilai;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal mengirim jawaban: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  void goToSoal(int index) {
    if (index < 0 || index >= soalList.length) return;
    currentIndex.value = index;
  }

  void nextSoal() => goToSoal(currentIndex.value + 1);
  void prevSoal() => goToSoal(currentIndex.value - 1);
}

// ──────────────────────────────────────────────────────────────────────────────
// ReviewController — review soal setelah materi selesai
// ──────────────────────────────────────────────────────────────────────────────
class ReviewController extends GetxController {
  final soalList = <ReviewSoalModel>[].obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  Future<Map<String, String>> _headers() async {
    final token = await AuthStorage.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  // GET /api/bab/materi/<id>/review
  Future<void> loadReview(int materiId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final res = await http.get(
        Uri.parse('$_baseUrl/api/bab/materi/$materiId/review'),
        headers: await _headers(),
      );
      if (res.statusCode != 200) throw Exception('API error ${res.statusCode}');

      final body = jsonDecode(res.body);
      final list = body['soal'] as List<dynamic>;
      soalList.value = list
          .map((e) => ReviewSoalModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      errorMessage.value = 'Gagal memuat review: $e';
    } finally {
      isLoading.value = false;
    }
  }
}
