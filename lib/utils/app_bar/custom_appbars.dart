import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:haircutmen_user_app/utils/constants/app_colors.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final bool showBackButton;
  final bool showMessage;
  final Color backgroundColor;
  final Color titleColor;
  final Color iconColors;
  final double height;
  final TextStyle? textStyle; // Optional: user can provide custom TextStyle

  const CustomAppBar({
    super.key,
    this.title,
    this.showBackButton = true,
    this.backgroundColor = Colors.transparent,
    this.titleColor = Colors.black,
    this.height = 60,
    this.textStyle, // Optional
    this.iconColors = Colors.black,
    this.showMessage = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      height: height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Centered title
          if(showMessage)
          Center(
            child: Text(
              title!.tr,
              style: textStyle ?? GoogleFonts.poppins(
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
              child: Padding(
                padding: const EdgeInsets.only(),
                child: GestureDetector(
                  onTap: (){
                    Get.back();
                  },
                  child: Container(
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
                      ]
                    ),
                    child: Icon(Icons.arrow_back, color: iconColors,size: 24,),

                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height);
}
