// ─────────────────────────────────────────
//  COLOUR PALETTE & CONSTANTS
// ─────────────────────────────────────────
import 'dart:ui';

import 'package:flutter/material.dart';

class AppColors {
  static const bg         = Color(0xFF0F1923);
  static const surface    = Color(0xFF1A2535);
  static const card       = Color(0xFF1E2D40);
  static const gold       = Color(0xFFD4A843);
  static const goldLight  = Color(0xFFF0C96A);
  static const goldDark   = Color(0xFF9E7A2A);
  static const emerald    = Color(0xFF2ECC8B);
  static const emeraldDim = Color(0xFF1A7A53);
  static const rose       = Color(0xFFE57373);
  static const sky        = Color(0xFF64B5F6);
  static const textPrimary   = Color(0xFFF5EDD6);
  static const textSecondary = Color(0xFFAA9977);
  static const textMuted     = Color(0xFF5D7290);
  static const divider       = Color(0xFF243347);

  // ── Gradient Utama ─────────────────────────────────────
  static const Color gradientTop    = Color.fromARGB(255, 197, 112, 16);
  static const Color gradientMid    = Color.fromARGB(255, 168, 106, 88);
  static const Color gradientBottom = Color.fromARGB(255, 0, 0, 0);

  // ── AppBar ─────────────────────────────────────────────
  static const Color appBarStart    = Color.fromARGB(255, 197, 112, 16);
  static const Color appBarEnd      = Color.fromARGB(255, 168, 106, 88);
  static const Color appBarBg       = Color.fromARGB(255, 189, 108, 54);
  static const Color appBarTitle    = Color.fromARGB(255, 255, 208, 169);

  // ── Bottom Navigation ──────────────────────────────────
  static const Color bottomNavBg    = Color.fromARGB(255, 163, 77, 26);

  // ── Teks ──────────────────────────────────────────────
  static const Color textP    = Colors.white;
  static const Color textS  = Colors.white70;
  static const Color textHint       = Colors.white38;

  // ── Card / Glass ───────────────────────────────────────
  static const Color cardFill       = Colors.white24;
  static const Color cardFillLight  = Colors.white12;
  static const Color cardBorder     = Colors.white24;

  // ── Gradient List (siap pakai) ─────────────────────────
  static const LinearGradient bodyGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [gradientTop, gradientBottom],
  );

  static const LinearGradient appBarGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [appBarStart, appBarEnd],
  );

  static const LinearGradient splashGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [gradientTop, gradientMid, gradientBottom],
    stops: [0.0, 0.5, 1.0],
  );

}