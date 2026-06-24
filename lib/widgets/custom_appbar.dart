import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tanqiy/core/colors.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String arabicTitle;
  final String title;

  final bool centerTitle;
  final bool showBackButton;

  final List<Widget>? actions;

  const CustomAppBar({
    super.key,
    required this.arabicTitle,
    required this.title,
    this.centerTitle = true,
    this.showBackButton = true,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: centerTitle,
      elevation: 0,
      backgroundColor: AppColors.appBarBg,
      foregroundColor: AppColors.textP,

      automaticallyImplyLeading: false,

      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: () => Get.back(),
            )
          : null,

      title: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            arabicTitle,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),

          Text(title, style: const TextStyle(fontSize: 12)),
        ],
      ),

      actions: actions,

      flexibleSpace: Container(
        decoration: const BoxDecoration(gradient: AppColors.appBarGradient),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
