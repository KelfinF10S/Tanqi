import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:tanqiy/core/const.dart';
import 'package:tanqiy/data/auth_local.dart';
import 'package:tanqiy/models/bab_merged_model.dart';
import 'package:tanqiy/models/bab_model.dart';
import 'package:tanqiy/models/jawaban_model.dart';
import 'package:tanqiy/models/materibab_model.dart';
import 'package:tanqiy/models/soal_model.dart';

final String _baseUrl = AppConst.baseUrl;

// ──────────────────────────────────────────────────────────────────────────────
// BabController
// Mengelola list bab dari 2 sumber:
//   - MateriBAB  → JSON lokal  (selalu ada, menjadi kerangka utama)
//   - BabModel   → API/DB      (progress, locked, soal — di-merge by id)
//
// Output akhir: babList berisi List<BabMerged>
// ──────────────────────────────────────────────────────────────────────────────
class BabController extends GetxController {
  // ── State ────────────────────────────────────────────
  final babList = <BabMerged>[].obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  // ── Lifecycle ────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    fetchBab();
  }

  // ── Helper header ────────────────────────────────────
  Future<Map<String, String>> _headers() async {
    final token = await AuthStorage.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  // ── Load JSON lokal ──────────────────────────────────
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

      // Coba load lokal dulu sendiri
      final materiList = await _loadMateriLokal();
      debugPrint('[BabController] materiList: ${materiList.length}');

      // Coba API sendiri
      List<BabModel> quizList = [];
      try {
        quizList = await _fetchBabFromApi();
        debugPrint('[BabController] quizList: ${quizList.length}');
      } catch (e) {
        debugPrint('[BabController] API gagal (lanjut tanpa quiz): $e');
        // API gagal tidak masalah, lanjut pakai lokal saja
      }

      final quizMap = {for (final b in quizList) b.id.toString(): b};

      babList.value = materiList
          .map((m) => BabMerged(materi: m, quiz: quizMap[m.id]))
          .toList();

      debugPrint('[BabController] babList final: ${babList.length}');
    } catch (e) {
      debugPrint('[BabController] ERROR FATAL: $e');
      errorMessage.value = 'Gagal memuat bab: $e';
    } finally {
      isLoading.value = false;
    }
  }

  // ── Internal: GET /api/bab ───────────────────────────
  Future<List<BabModel>> _fetchBabFromApi() async {
    final res = await http.get(
      Uri.parse('$_baseUrl/bab/'),
      headers: await _headers(),
    );
    final body = jsonDecode(res.body);
    final list = body['data'] as List<dynamic>;
    return list
        .map((e) => BabModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ── Service: DELETE /api/jawaban/reset/<babId> ───────
  Future<void> resetBab(int babId) async {
    try {
      isLoading.value = true;

      final res = await http.delete(
        Uri.parse('$_baseUrl/jawaban/reset/$babId'),
        headers: await _headers(),
      );
      final body = jsonDecode(res.body);

      if (res.statusCode == 200) {
        await fetchBab(); // refresh + re-merge
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
        'Gagal reset bab: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// QuizController  (tidak berubah signifikan — hanya loadSoal menerima int babId)
// ──────────────────────────────────────────────────────────────────────────────
class QuizController extends GetxController {
  // ── State ────────────────────────────────────────────
  final soalList = <SoalModel>[].obs;
  final bab = Rxn<BabModel>();
  final isLoading = false.obs;
  final isSubmitting = false.obs;
  final errorMessage = ''.obs;

  final currentIndex = 0.obs;
  final opsiAcak = <Map<String, String>>[].obs;
  final selectedDbLabel = ''.obs;
  final hasil = Rxn<JawabanModel>();
  final status = 'idle'.obs; // 'idle' | 'answered'

  // ── Getter ───────────────────────────────────────────
  SoalModel? get soalAktif =>
      soalList.isNotEmpty ? soalList[currentIndex.value] : null;

  bool get isLastSoal => currentIndex.value == soalList.length - 1;

  // ── Helper header ────────────────────────────────────
  Future<Map<String, String>> _headers() async {
    final token = await AuthStorage.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  // ── Service: GET /api/bab/<id>/soal ─────────────────
  // Dipanggil dari view dengan: bab.id (String) di-parse ke int
  // Contoh: controller.loadSoal(int.parse(merged.id))
  Future<void> loadSoal(int babId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      currentIndex.value = 0;
      hasil.value = null;
      status.value = 'idle';
      selectedDbLabel.value = '';

      final res = await http.get(
        Uri.parse('$_baseUrl/bab/$babId/soal'),
        headers: await _headers(),
      );
      final body = jsonDecode(res.body);

      bab.value = BabModel.fromJson(body['bab'] as Map<String, dynamic>);

      final list = body['soal'] as List<dynamic>;
      soalList.value = list
          .map((e) => SoalModel.fromJson(e as Map<String, dynamic>))
          .toList();

      _acakOpsiSoalAktif();
    } catch (e) {
      errorMessage.value = 'Gagal memuat soal: $e';
    } finally {
      isLoading.value = false;
    }
  }

  // ── Service: POST /api/jawaban ───────────────────────
  Future<void> submitJawaban() async {
    if (selectedDbLabel.value.isEmpty || isSubmitting.value) return;

    try {
      isSubmitting.value = true;

      final res = await http.post(
        Uri.parse('$_baseUrl/jawaban/'),
        headers: await _headers(),
        body: jsonEncode({
          'soal_id': soalAktif!.id,
          'jawaban': selectedDbLabel.value,
        }),
      );
      final body = jsonDecode(res.body);

      if (res.statusCode == 409) {
        // Soal sudah dijawab sebelumnya — langsung tandai answered
        status.value = 'answered';
        return;
      }

      hasil.value = JawabanModel.fromJson(body);
      status.value = 'answered';
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

  // ── Pilih jawaban ────────────────────────────────────
  void pilihJawaban(String dbLabel) {
    if (status.value == 'answered') return;
    selectedDbLabel.value = dbLabel;
  }

  // ── Soal berikutnya ──────────────────────────────────
  void nextSoal() {
    if (isLastSoal) {
      Get.snackbar(
        'Selesai!',
        'Kamu telah menyelesaikan semua soal di bab ini',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    currentIndex.value = currentIndex.value + 1;
    selectedDbLabel.value = '';
    hasil.value = null;
    status.value = 'idle';
    _acakOpsiSoalAktif();
  }

  // ── Internal ─────────────────────────────────────────
  void _acakOpsiSoalAktif() {
    if (soalAktif != null) opsiAcak.value = soalAktif!.opsiAcak;
  }
}
