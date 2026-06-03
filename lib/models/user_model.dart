// lib/core/models/user_model.dart

class UserModel {
  final int? id;
  final String username;
  final int level;
  final int currentXP;
  final int maxXP;
  final int babSelesai;

  const UserModel({
    this.id,
    required this.username,
    this.level = 1,
    this.currentXP = 0,
    this.maxXP = 100,
    this.babSelesai = 0,
  });

  // ── Dari JSON API ─────────────────────────────────────
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id:         json['id'] as int?,
      username:   json['username'] as String? ?? '',
      level:      json['level'] as int? ?? 1,
      currentXP:  json['xp'] as int? ?? 0, 
      maxXP:      json['max_xp'] as int? ?? 100, // TODO: Update real time max xp
      babSelesai: json['bab_selesai'] as int? ?? 0,
    );
  }

  // ── Ke JSON ───────────────────────────────────────────
  Map<String, dynamic> toJson() {
    return {
      'id':          id,
      'username':    username,
      'level':       level,
      'xp':  currentXP,
      'max_xp':      maxXP,
      'bab_selesai': babSelesai,
    };
  }

  // ── Copy dengan perubahan sebagian ────────────────────
  UserModel copyWith({
    int? id,
    String? username,
    int? level,
    int? currentXP,
    int? maxXP,
    int? babSelesai,
    int? pencapaian,
    int? streak,
  }) {
    return UserModel(
      id:         id ?? this.id,
      username:   username ?? this.username,
      level:      level ?? this.level,
      currentXP:  currentXP ?? this.currentXP,
      maxXP:      maxXP ?? this.maxXP,
      babSelesai: babSelesai ?? this.babSelesai,

    );
  }

  // ── Helper ────────────────────────────────────────────
  String get initials {
    final name = username.trim();
    if (name.isEmpty) return '?';
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }

  double get xpProgress => maxXP > 0 ? currentXP / maxXP : 0.0;

  int get xpRemaining => maxXP - currentXP;

  bool get isMaxLevel => currentXP >= maxXP;

  @override
  String toString() =>
      'UserModel(id: $id, username: $username, level: $level, xp: $currentXP/$maxXP)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}