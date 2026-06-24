enum MemberRole {
  murid,
  guru,
}

class ClassMember {
  final int id;
  final String username;
  final int level;
  final int currentXP;
  final int babSelesai;

  final MemberRole role;

  const ClassMember({
    required this.id,
    required this.username,
    required this.level,
    required this.currentXP,
    required this.babSelesai,
    required this.role,
  });

  factory ClassMember.fromJson(
    Map<String, dynamic> json,
  ) {
    return ClassMember(
      id: json['id'],

      username:
          json['username'],

      level:
          json['level'] ?? 1,

      currentXP:
          json['xp'] ?? 0,

      babSelesai:
          json['bab_selesai'] ?? 0,

      role:
          json['role'] == 'guru'
              ? MemberRole.guru
              : MemberRole.murid,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'level': level,
      'xp': currentXP,
      'bab_selesai': babSelesai,

      'role':
          role.name,
    };
  }

  String get initials {
    final parts =
        username.trim().split(
          ' ',
        );

    if (parts.length >= 2) {
      return (
        parts[0][0] +
        parts[1][0]
      ).toUpperCase();
    }

    return username
        .substring(
          0,
          username.length >= 2
              ? 2
              : 1,
        )
        .toUpperCase();
  }

  bool get isGuru =>
      role ==
      MemberRole.guru;

  bool get isMurid =>
      role ==
      MemberRole.murid;
}