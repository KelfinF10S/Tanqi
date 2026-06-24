import 'package:flutter/material.dart';
import 'package:tanqiy/core/colors.dart';
import 'package:tanqiy/widgets/custom_appbar.dart';

class GamesPage extends StatelessWidget {
  const GamesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBarEnd,
      appBar: CustomAppBar(
        arabicTitle: 'لعبة إلكترونية',
        title: 'Permainan Digital',
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.splashGradient),
      ),
    );
  }
}
