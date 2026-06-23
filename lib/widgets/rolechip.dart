import 'package:flutter/material.dart';
import 'package:tanqiy/core/colors.dart';
import 'package:tanqiy/pages/kelas.dart';

Widget roleChip(member) {
    final isGuru = member.role == MemberRole.guru;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        gradient: isGuru ? AppColors.appBarGradient : null,
        color: isGuru ? null : AppColors.cardFillLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isGuru
              ? AppColors.appBarTitle.withOpacity(0.4)
              : AppColors.cardBorder,
        ),
      ),
      child: Text(
        isGuru ? '👑 Guru' : '📖 Murid',
        style: TextStyle(
          color: isGuru ? AppColors.appBarTitle : AppColors.textS,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }