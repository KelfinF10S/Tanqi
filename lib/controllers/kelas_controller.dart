import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:tanqiy/core/const.dart';
import 'package:tanqiy/data/auth_local.dart';
import 'package:tanqiy/models/class_member_model.dart';

class KelasController extends GetxController {
  final String _baseUrl = AppConst.baseUrl;

  final anggota = <ClassMember>[].obs;

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
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    try {
      isLoading.value = true;

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

      anggota.value = users.map((e) => ClassMember.fromJson(e)).toList();
    } catch (e) {
      anggota.clear();

      Get.snackbar('Error', 'Gagal memuat daftar pengguna');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshUsers() async {
    await fetchUsers();
  }
}
