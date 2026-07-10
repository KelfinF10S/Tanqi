import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:tanqiy/core/colors.dart';
import 'package:tanqiy/core/const.dart';
import 'package:tanqiy/data/auth_local.dart';
import 'package:tanqiy/models/bab_merged_model.dart';
import 'package:tanqiy/models/bab_model.dart';
import 'package:tanqiy/models/kuis_baru/jawaban_kuis_model.dart';
import 'package:tanqiy/models/kuis_baru/kuis_meta_model.dart';
import 'package:tanqiy/models/kuis_baru/review_soal_kuis_model.dart';
import 'package:tanqiy/models/kuis_baru/soal_kuis_model.dart';
import 'package:tanqiy/models/materibab_model.dart';
import 'package:tanqiy/models/materi_model.dart';
import 'package:tanqiy/models/nahwu_node_model.dart';
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

    final result = <MateriBAB>[];

    for (final item in list) {
      try {
        final materi = MateriBAB.fromJson(item);
        print("Loaded id = ${materi.id}");
        result.add(materi);
      } catch (e, s) {
        print("ERROR PARSE:");
        print(e);
        print(s);
      }
    }

    return result;
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
      print("Materi lokal : ${materiList.length}");
      print("API : ${quizList.length}");
      print("Merged : ${babList.length}");
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

    print(res.body);

    if (res.statusCode != 200) throw Exception('API error ${res.statusCode}');
    final body = jsonDecode(res.body);
    final list = body['data'] as List<dynamic>;
    return list
        .map((e) => BabModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ── Pencarian node materi ──────────────────────────────────────────────

  MateriBAB? findBabById(String babId) {
    final merged = babList.firstWhereOrNull((b) => b.materi.id == babId);
    return merged?.materi;
  }

  NahwuNode? findMateriNode(String babId, String nodeId) {
    final bab = findBabById(babId);
    if (bab == null) return null;
    for (final node in bab.bab) {
      final found = node.findById(nodeId);
      if (found != null) return found;
    }
    return null;
  }

  List<NahwuNode> flattenBab(String babId) {
    final bab = findBabById(babId);
    if (bab == null) return [];
    return bab.bab.expand((node) => node.flatten()).toList();
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

  // Tandai materi sudah dibaca/dipelajari
  Future<void> selesaikanMateri(int materiId) async {
    try {
      final res = await http.post(
        Uri.parse('$_baseUrl/api/bab/materi/$materiId/selesai'),
        headers: await _headers(),
      );
      if (res.statusCode == 200) {
        final idx = materiList.indexWhere((m) => m.id == materiId);
        if (idx != -1) {
          materiList[idx] = materiList[idx].copyWith(isCompleted: true);
          materiList.refresh();
        }
      }
    } catch (e) {
      debugPrint('[MateriController] selesaikanMateri gagal: $e');
    }
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// QuizController — pengatur kuis per-bab, berurutan, feedback per soal
// ──────────────────────────────────────────────────────────────────────────────
class QuizController extends GetxController {
  final Rx<SoalKuisModel?> soalAktif = Rx<SoalKuisModel?>(null);
  final Rx<KuisMetaModel?> kuisMeta = Rx<KuisMetaModel?>(null);

  final isLoading = false.obs;
  final isSubmitting = false.obs;
  final errorMessage = ''.obs;

  final Rx<dynamic> jawabanDipilih = Rx<dynamic>(null);
  final Rx<JawabanKuisModel?> hasilAktif = Rx<JawabanKuisModel?>(null);

  final quizSelesai = false.obs;
  final babSelesai = false.obs;
  final nilaiAkhir = 0.0.obs;

  final showReview = false.obs;
  final unlockDialogShown = false.obs;

  final Map<int, List<String>> _urutanPilihanMC = {};
  final Map<int, List<String>> _urutanItemDD = {};
  final Map<int, List<String>> _urutanTargetDD = {};
  final Map<int, List<Map<String, dynamic>>> _urutanObjekTO = {};

  List<String> urutanPilihanMC(SoalKuisModel soal) {
    return _urutanPilihanMC.putIfAbsent(soal.id, () {
      final pilihan = Map<String, String>.from(soal.konten['pilihan'] ?? {});
      return pilihan.keys.toList()..shuffle(Random());
    });
  }

  List<String> urutanItemDD(SoalKuisModel soal) {
    return _urutanItemDD.putIfAbsent(soal.id, () {
      final items = List<String>.from(soal.konten['items'] ?? []);
      return items..shuffle(Random());
    });
  }

  List<String> urutanTargetDD(SoalKuisModel soal) {
    return _urutanTargetDD.putIfAbsent(soal.id, () {
      final targets = List<String>.from(soal.konten['targets'] ?? []);
      return targets..shuffle(Random());
    });
  }

  List<Map<String, dynamic>> urutanObjekTO(SoalKuisModel soal) {
    return _urutanObjekTO.putIfAbsent(soal.id, () {
      final objects = List<Map<String, dynamic>>.from(
        soal.konten['objects'] ?? [],
      );
      return objects..shuffle(Random());
    });
  }

  void _resetUrutanTampilan() {
    _urutanPilihanMC.clear();
    _urutanItemDD.clear();
    _urutanTargetDD.clear();
    _urutanObjekTO.clear();
  }

  int? _babId;

  Future<Map<String, String>> _headers() async {
    final token = await AuthStorage.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Future<void> loadKuis(int babId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      _babId = babId;

      jawabanDipilih.value = null;
      hasilAktif.value = null;
      quizSelesai.value = false;
      showReview.value = false;
      babSelesai.value = false;
      nilaiAkhir.value = 0;
      unlockDialogShown.value = false;

      final res = await http.get(
        Uri.parse('$_baseUrl/api/bab/$babId/kuis'),
        headers: await _headers(),
      );

      if (res.statusCode != 200) {
        throw Exception('API error ${res.statusCode}');
      }

      final body = jsonDecode(res.body);
      kuisMeta.value = KuisMetaModel.fromJson(body['kuis']);

      if (body['soal_aktif'] == null) {
        quizSelesai.value = true;
        babSelesai.value =
            kuisMeta.value!.nilai >= kuisMeta.value!.passingScore;
        nilaiAkhir.value = kuisMeta.value!.nilai;
        showReview.value = true;
        return;
      }

      soalAktif.value = SoalKuisModel.fromJson(body['soal_aktif']);
    } catch (e) {
      errorMessage.value = 'Gagal memuat kuis: $e';
    } finally {
      isLoading.value = false;
    }
  }

  void pilihJawaban(dynamic jawaban) {
    if (hasilAktif.value != null) return;
    jawabanDipilih.value = jawaban;
  }

  Future<void> submitJawaban() async {
    if (soalAktif.value == null ||
        jawabanDipilih.value == null ||
        isSubmitting.value ||
        hasilAktif.value != null) {
      return;
    }

    try {
      isSubmitting.value = true;

      final res = await http.post(
        Uri.parse('$_baseUrl/api/kuis/jawaban'),
        headers: await _headers(),
        body: jsonEncode({
          'soal_kuis_id': soalAktif.value!.id,
          'jawaban': jawabanDipilih.value,
        }),
      );

      final body = jsonDecode(res.body);

      if (res.statusCode == 409) {
        await _lanjutSoalBerikutnya();
        return;
      }

      if (res.statusCode != 201) {
        throw Exception(body['message'] ?? 'Gagal submit jawaban');
      }

      hasilAktif.value = JawabanKuisModel.fromJson(body);
    } catch (e) {
      showSnackbar('Error', 'Gagal mengirim jawaban');
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> lanjutSoal() async {
    final hasil = hasilAktif.value;
    if (hasil == null || _babId == null) return;

    if (hasil.kuisSelesai) {
      quizSelesai.value = true;
      babSelesai.value = hasil.babSelesai;
      nilaiAkhir.value = hasil.nilai;
      showReview.value = true;

      await Get.find<BabController>().fetchBab();

      if (babSelesai.value && !unlockDialogShown.value) {
        unlockDialogShown.value = true;
        Future.delayed(const Duration(milliseconds: 400), _showUnlockDialog);
      }
      return;
    }

    await _lanjutSoalBerikutnya();
  }

  Future<void> _lanjutSoalBerikutnya() async {
    jawabanDipilih.value = null;
    hasilAktif.value = null;
    await loadKuis(_babId!);
  }

  Future<void> retryKuis(int babId) async {
    try {
      isLoading.value = true;
      _resetUrutanTampilan();

      final res = await http.delete(
        Uri.parse('$_baseUrl/api/kuis/reset/$babId'),
        headers: await _headers(),
      );

      if (res.statusCode != 200) {
        throw Exception('Reset gagal');
      }

      await loadKuis(babId);
    } catch (e) {
      showSnackbar('Error', 'Gagal mengulang kuis');
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
                  'Kamu telah menyelesaikan kuis bab ini.\n\n'
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
                    onPressed: () => Get.back(),
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
// ReviewController — review kuis setelah bab selesai
// ──────────────────────────────────────────────────────────────────────────────
class ReviewController extends GetxController {
  final soalList = <ReviewSoalKuisModel>[].obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  final nilai = 0.0.obs;
  final attempt = 1.obs;

  Future<Map<String, String>> _headers() async {
    final token = await AuthStorage.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Future<void> loadReview(int babId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final res = await http.get(
        Uri.parse('$_baseUrl/api/bab/$babId/kuis/review'),
        headers: await _headers(),
      );
      if (res.statusCode != 200) throw Exception('API error ${res.statusCode}');

      final body = jsonDecode(res.body);
      final list = body['soal'] as List<dynamic>;
      final kuis = body['kuis'] as Map<String, dynamic>?;

      soalList.value = list
          .map((e) => ReviewSoalKuisModel.fromJson(e as Map<String, dynamic>))
          .toList();

      nilai.value = (kuis?['nilai'] ?? 0).toDouble();
      attempt.value = kuis?['attempt'] ?? 1;
    } catch (e) {
      errorMessage.value = 'Gagal memuat review: $e';
    } finally {
      isLoading.value = false;
    }
  }
}
