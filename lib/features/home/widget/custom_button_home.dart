import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../component/text/common_text.dart';
import '../../../utils/constants/app_colors.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isSmall;
  final Color? backgroundColor;
  final Color? textColor;
  final double height;
  final double fontSize;
  final double? weidth;

  const CustomButton({
    super.key,
    required this.text,
    required this.isSelected,
    required this.onTap,
    this.isSmall = false,
    this.backgroundColor,
    this.textColor,
    this.height=48,
    this.fontSize=18,
    this.weidth
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        width: weidth,
        padding: EdgeInsets.symmetric(
          horizontal: isSmall ? 10.w : 20.w,
          vertical: isSmall ? 0.h : 3.h,
        ),
        decoration: BoxDecoration(
          color: backgroundColor ?? (isSelected ? AppColors.primaryColor : Colors.white),
          borderRadius: BorderRadius.circular(4.r),
          border: Border.all(
            color: backgroundColor ?? (isSelected ? AppColors.primaryColor : AppColors.primaryColor),
          ),
        ),
        child: Center(
          child: CommonText(
            text: text,
            fontSize: isSmall ? 12.sp : fontSize,
            fontWeight: FontWeight.w500,
            color: textColor ?? (isSelected ? Colors.white : AppColors.primaryColor),
          ),
        ),
      ),
    );
  }
}