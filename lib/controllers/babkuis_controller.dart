import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:tanqiy/core/colors.dart';
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
import 'package:tanqiy/widgets/snackbar.dart';

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
// QuizController — pengatur kuis
// ──────────────────────────────────────────────────────────────────────────────
class QuizController extends GetxController {
  final soalList = <SoalModel>[].obs;

  final isLoading = false.obs;
  final isSubmitting = false.obs;
  final errorMessage = ''.obs;

  final currentIndex = 0.obs;

  final opsiPerSoal = <int, List<Map<String, String>>>{}.obs;
  final selectedPerSoal = <int, String>{}.obs;
  final hasilPerSoal = <int, JawabanModel>{}.obs;

  final quizSelesai = false.obs;
  final materiSelesai = false.obs;
  final babSelesai = false.obs;

  final nilaiAkhir = 0.0.obs;
  final totalXp = 0.obs;

  final showReview = false.obs;

  // supaya dialog unlock tidak muncul terus
  final unlockDialogShown = false.obs;

  bool get isLastSoal => currentIndex.value == soalList.length - 1;

  bool get isFirstSoal => currentIndex.value == 0;

  SoalModel? get soalAktif =>
      soalList.isNotEmpty ? soalList[currentIndex.value] : null;

  String get selectedLabel => selectedPerSoal[currentIndex.value] ?? '';

  JawabanModel? get hasilAktif => hasilPerSoal[currentIndex.value];

  String get statusAktif {
    if (hasilPerSoal.containsKey(currentIndex.value)) {
      return 'answered';
    }

    if (selectedPerSoal.containsKey(currentIndex.value)) {
      return 'selected';
    }

    return 'idle';
  }

  Future<Map<String, String>> _headers() async {
    final token = await AuthStorage.getToken();

    return {
      'Content-Type': 'application/json',

      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Future<void> loadSoal(int materiId) async {
    try {
      isLoading.value = true;

      errorMessage.value = '';

      currentIndex.value = 0;

      soalList.clear();

      opsiPerSoal.clear();

      selectedPerSoal.clear();

      hasilPerSoal.clear();

      quizSelesai.value = false;

      showReview.value = false;

      materiSelesai.value = false;

      babSelesai.value = false;

      nilaiAkhir.value = 0;

      totalXp.value = 0;

      unlockDialogShown.value = false;

      final reviewRes = await http.get(
        Uri.parse('$_baseUrl/api/bab/materi/$materiId/review'),
        headers: await _headers(),
      );

      if (reviewRes.statusCode == 200) {
        await _restoreFromReview(reviewRes);

        return;
      }

      final res = await http.get(
        Uri.parse('$_baseUrl/api/bab/materi/$materiId/soal'),
        headers: await _headers(),
      );

      if (res.statusCode != 200) {
        throw Exception('API error ${res.statusCode}');
      }

      final body = jsonDecode(res.body);

      final list = body['soal'] as List<dynamic>;

      soalList.value = list.map((e) => SoalModel.fromJson(e)).toList();

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

  Future<void> _restoreFromReview(http.Response reviewRes) async {
    final body = jsonDecode(reviewRes.body);

    final reviewList = body['soal'] as List<dynamic>;
    final materi = body['materi'] as Map<String, dynamic>?;
    final bab = body['bab'] as Map<String, dynamic>?;

    soalList.value = reviewList.map((e) => SoalModel.fromJson(e)).toList();

    for (int i = 0; i < soalList.length; i++) {
      opsiPerSoal[i] = soalList[i].opsiAcak;
    }

    int xp = 0;

    for (int i = 0; i < reviewList.length; i++) {
      final r = reviewList[i];

      final user = r['jawaban_user'];

      if (user == null) continue;

      selectedPerSoal[i] = user;

      hasilPerSoal[i] = JawabanModel(
        message: '',
        isCorrect: r['is_correct'],
        jawabanBenar: r['jawaban_benar'] ?? '',
        xpDidapat: 0,
        materiSelesai: true,
        babSelesai: bab?['is_completed'] ?? false,
        nilai: (bab?['nilai'] ?? 0).toDouble(),
        penjelasan: r['penjelasan'],
      );

      if (r['is_correct'] == true) {
        xp++;
      }
    }

    totalXp.value = xp;

    quizSelesai.value = true;
    materiSelesai.value = true;
    babSelesai.value = bab?['is_completed'] ?? false;
    nilaiAkhir.value = (bab?['nilai'] ?? 0).toDouble();

    hasilPerSoal.refresh();
    selectedPerSoal.refresh();
  }

  void pilihJawaban(String dbLabel) {
    if (hasilPerSoal.containsKey(currentIndex.value)) {
      return;
    }

    selectedPerSoal[currentIndex.value] = dbLabel;

    selectedPerSoal.refresh();
  }

  Future<void> submitJawaban() async {
    final idx = currentIndex.value;

    if (selectedPerSoal[idx] == null || isSubmitting.value) {
      return;
    }

    if (hasilPerSoal.containsKey(idx)) {
      return;
    }

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

      hasilPerSoal[idx] = res.statusCode == 409
          ? JawabanModel.fromJson({
              ...body,
              'materi_selesai': false,
              'bab_selesai': false,
              'nilai': 0,
              'xp_didapat': 0,
            })
          : JawabanModel.fromJson(body);

      hasilPerSoal.refresh();

      totalXp.value += hasilPerSoal[idx]!.xpDidapat;

      if (hasilPerSoal.length == soalList.length) {
        quizSelesai.value = true;

        final hasil = hasilPerSoal.values.firstWhere(
          (h) => h.materiSelesai,
          orElse: () => hasilPerSoal[idx]!,
        );

        materiSelesai.value = hasil.materiSelesai;

        babSelesai.value = hasil.babSelesai;

        nilaiAkhir.value = hasil.nilai;

        await Get.find<BabController>().fetchBab();

        if (babSelesai.value &&
            nilaiAkhir.value >= 70 &&
            !unlockDialogShown.value) {
          unlockDialogShown.value = true;

          Future.delayed(const Duration(milliseconds: 400), () {
            _showUnlockDialog();
          });
        }
      }
    } catch (e) {
      showSnackbar('Error', 'Gagal mengirim jawaban');
    } finally {
      isSubmitting.value = false;
    }
  }

  void goToSoal(int index) {
    if (index < 0 || index >= soalList.length) {
      return;
    }

    currentIndex.value = index;
  }

  void nextSoal() => goToSoal(currentIndex.value + 1);

  void prevSoal() => goToSoal(currentIndex.value - 1);

  Future<void> retryMateri(int materiId) async {
    try {
      isLoading.value = true;

      final res = await http.delete(
        Uri.parse('$_baseUrl/api/jawaban/reset/$materiId'),
        headers: await _headers(),
      );

      if (res.statusCode != 200) {
        throw Exception('Reset gagal');
      }

      // reload quiz attempt baru
      await loadSoal(materiId);
    } catch (e) {
      showSnackbar('Error', 'Gagal mengulang materi');
    } finally {
      isLoading.value = false;
    }
  }

  void _showUnlockDialog() {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.divider),
          ),

          child: Padding(
            padding: const EdgeInsets.all(22),

            child: Column(
              mainAxisSize: MainAxisSize.min,

              children: [
                // ICON
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.12),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.amber.withOpacity(0.35)),
                  ),

                  child: const Icon(
                    Icons.lock_open_rounded,
                    color: Colors.amber,
                    size: 34,
                  ),
                ),

                const SizedBox(height: 18),

                const Text(
                  'Bab Baru Terbuka',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  'Kamu telah menyelesaikan seluruh pembahasan.\n\n'
                  'Nilai akhir: ${nilaiAkhir.value.toStringAsFixed(0)}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 13,
                    height: 1.6,
                  ),
                ),

                const SizedBox(height: 22),

                SizedBox(
                  width: double.infinity,

                  child: ElevatedButton(
                    onPressed: () {
                      Get.back();
                    },

                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: Colors.amber.withOpacity(0.12),

                      foregroundColor: Colors.amber,

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),

                        side: BorderSide(color: Colors.amber.withOpacity(0.3)),
                      ),

                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),

                    child: const Text(
                      'Lanjut',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      barrierDismissible: false,
    );
  }
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
