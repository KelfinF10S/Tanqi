// import 'dart:convert';

// import 'package:get/get.dart';
// import 'package:http/http.dart' as http;
// import 'package:tanqiy/core/const.dart';
// import 'package:tanqiy/data/auth_local.dart';
// import 'package:tanqiy/models/class_member_model.dart';

// final String _baseUrl = AppConst.baseUrl;

// class KelasController extends GetxController {
//   final anggota = <ClassMember>[].obs;

//   final isLoading = false.obs;

//   Future<Map<String, String>> _headers() async {
//     final token = await AuthStorage.getToken();

//     return {
//       'Content-Type': 'application/json',
//       'Authorization': 'Bearer $token',
//     };
//   }

//   @override
//   void onInit() {
//     super.onInit();
//     fetchUsers();
//   }

//   Future<void> fetchUsers() async {
//     try {
//       isLoading.value = true;

//       final res = await http.get(
//         Uri.parse('$_baseUrl/api/profile/users'),
//         headers: await _headers(),
//       );

//       if (res.statusCode != 200) {
//         throw Exception('API Error');
//       }

//       final body = jsonDecode(res.body);

//       anggota.value =
//           (body['data'] as List)
//               .map(
//                 (e) => ClassMember.fromJson(e),
//               )
//               .toList();
//     } finally {
//       isLoading.value = false;
//     }
//   }
// }