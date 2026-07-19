import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:tanqiy/core/const.dart';
import 'package:tanqiy/data/auth_local.dart';
import 'package:tanqiy/models/class_member_model.dart';

class LeaderboardController extends GetxController {
  final String _baseUrl = AppConst.baseUrl;

  final leaderboard = <ClassMember>[].obs;

  final isLoading = false.obs;

  Future<Map<String, String>> _headers() async {
    final token = await AuthStorage.getToken();

    return {
      'Content-Type': 'application/json',

      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  @override
  void onInit() {
    super.onInit();
    fetchLeaderboard();
  }

  Future<void> fetchLeaderboard({bool silent = false}) async {
    try {
      if (!silent) isLoading.value = true;

      final response = await http.get(
        Uri.parse('$_baseUrl/api/profile/users'),
        headers: await _headers(),
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Gagal mengambil data pengguna '
          '(${response.statusCode})',
        );
      }

      final body = jsonDecode(response.body);

      final users = body['data'] as List? ?? [];

      final parsed = users
          .map((e) => ClassMember.fromJson(e))
          .where((u) => u.role == MemberRole.murid)
          .toList();

      // urutkan dari XP tertinggi -> rank cukup dihitung dari index list
      parsed.sort((a, b) => b.currentXP.compareTo(a.currentXP));

      leaderboard.value = parsed;
    } catch (e) {
      if (!silent) leaderboard.clear();

      Get.snackbar('Error', 'Gagal memuat leaderboard');
    } finally {
      if (!silent) isLoading.value = false;
    }
  }

  // Dipakai oleh pull-to-refresh: tidak menyalakan isLoading supaya halaman
  // tidak berpindah ke tampilan full-screen spinner (yang bikin layar kelihatan
  // "hitam" sesaat), cukup spinner bawaan RefreshIndicator saja yang tampil.
  Future<void> refreshLeaderboard() async {
    await fetchLeaderboard(silent: true);
  }

  /// Rank user (1-based) berdasarkan username. null kalau tidak ketemu.
  int? rankOf(String username) {
    final index = leaderboard.indexWhere((u) => u.username == username);
    return index == -1 ? null : index + 1;
  }

  /// Data ClassMember milik username tertentu.
  ClassMember? memberOf(String username) {
    return leaderboard.firstWhereOrNull((u) => u.username == username);
  }
}