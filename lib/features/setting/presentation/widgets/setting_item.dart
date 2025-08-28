import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../utils/constants/app_colors.dart';
import '../../../../component/text/common_text.dart';

class SettingItem extends StatelessWidget {
  const SettingItem({
    super.key,
    required this.title,
    required this.iconDate,
    this.iconColor,
    this.titleColor,
  });

  final String title;
  final IconData iconDate;
  final Color? iconColor;
  final Color? titleColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      margin: EdgeInsets.only(bottom: 15.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(color: AppColors.black50),
        boxShadow: [
          BoxShadow(
            color: Color(0x408E8E8E),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          /// show icon here
          Container(
            width: 40.w,
            height: 40.h,
            decoration: BoxDecoration(
              color: AppColors.black50,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Icon(iconDate, color: iconColor ?? AppColors.secondary),
          ),

          /// show Title here
          CommonText(
            text: title,
            color: titleColor ?? AppColors.secondary,
            left: 12,
          ),
        ],
      ),
    );
  }
}
