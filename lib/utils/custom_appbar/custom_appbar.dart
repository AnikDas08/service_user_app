import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_colors.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final bool showBackButton;
  final bool showMessage;
  final bool showRightButton; // ✅ NEW
  final VoidCallback? onRightButtonTap; // ✅ NEW
  final IconData rightIcon; // ✅ NEW
  final Color backgroundColor;
  final Color titleColor;
  final Color iconColors;
  final double height;
  final TextStyle? textStyle;

  const CustomAppBar({
    super.key,
    this.title,
    this.showBackButton = true,
    this.showMessage = true,
    this.showRightButton = false, // ✅ Default false
    this.onRightButtonTap,
    this.rightIcon = Icons.more_vert, // ✅ Default Icon
    this.backgroundColor = Colors.transparent,
    this.titleColor = Colors.black,
    this.iconColors = Colors.black,
    this.height = 60,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      height: height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (showMessage)
            Center(
              child: Text(
                title!.tr,
                style: textStyle ??
                    GoogleFonts.poppins(
                      textStyle: TextStyle(
                        fontSize: 18,
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
              ),
            ),

          // Back button
          if (showBackButton)
            Positioned(
              left: 0,
              child: GestureDetector(
                onTap: () => Get.back(),
                child: _buildIconButton(Icons.arrow_back),
              ),
            ),

          // ✅ Right button
          if (showRightButton)
            Positioned(
              right: 0,
              child: GestureDetector(
                onTap: onRightButtonTap,
                child: _buildIconButton(rightIcon),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildIconButton(IconData icon) {
    return Container(
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 2,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Icon(icon, color: iconColors, size: 24),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height);
}
