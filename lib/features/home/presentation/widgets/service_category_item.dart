import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../component/text/common_text.dart';
import '../../../../utils/constants/app_colors.dart';

class ServiceCategoryItem extends StatelessWidget {
  final String icon;
  final String label;
  final VoidCallback? onTap;

  const ServiceCategoryItem({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 54.w,
            height: 54.w,
            decoration: BoxDecoration(
              color: AppColors.red50,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: SvgPicture.asset(
                icon,
                height: 24,
                width: 24,
                color: AppColors.primaryColor,
              )
            ),
          ),
          SizedBox(height: 8.h),
          CommonText(
            text: label,
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.black300,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
