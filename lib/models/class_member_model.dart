// class ClassMember {
//   final int id;
//   final String username;
//   final int level;
//   final int currentXP;
//   final int babSelesai;
//   final String role;

//   const ClassMember({
//     required this.id,
//     required this.username,
//     required this.level,
//     required this.currentXP,
//     required this.babSelesai,
//     required this.role
//   });

//   factory ClassMember.fromJson(Map<String, dynamic> json) {
//     return ClassMember(
//       id: json['id'],
//       username: json['username'],
//       level: json['level'] ?? 1,
//       currentXP: json['xp'] ?? 0,
//       babSelesai: json['bab_selesai'] ?? 0,
//       role: json['role'] ?? 'murid'
//     );
//   }

//   String get initials {
//     final parts = username.split(' ');

//     if (parts.length >= 2) {
//       return (parts[0][0] + parts[1][0]).toUpperCase();
//     }

//     return username.substring(0, username.length >= 2 ? 2 : 1).toUpperCase();
//   }
// }
