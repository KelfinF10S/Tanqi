import 'package:flutter/material.dart';
import 'package:tanqiy/core/colors.dart';

class GamesPage extends StatelessWidget {
  const GamesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBarEnd,
      appBar: AppBar(
        title: Column(
          children: [
            Text(
              'لعبة إلكترونية',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            Text('Permainan Digital', style: TextStyle(fontSize: 12)),
          ],
        ),
        centerTitle: true,
        backgroundColor: AppColors.appBarBg,
        elevation: 0,
        foregroundColor: AppColors.textP,
        actions: [],
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppColors.appBarGradient),
        ),
      ),
      body: Container(
         decoration: const BoxDecoration(gradient: AppColors.splashGradient),
      )
    );
  }
}
